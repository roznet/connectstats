# ConnectStats Service Integrations

> Garmin, Strava, HealthKit, and ConnectStats Server sync architecture

## Overview

ConnectStats integrates with four data sources, each with different authentication and sync mechanisms.

```
┌─────────────────────────────────────────────────────────────────┐
│                        GCWebConnect                              │
│              Central Request Queue & Status Tracking             │
├─────────────┬─────────────┬─────────────────┬──────────────────┤
│   Garmin    │   Strava    │  ConnectStats   │    HealthKit     │
│   SSO Auth  │  OAuth 2.0  │   OAuth 1.0a    │   Native API     │
└─────────────┴─────────────┴─────────────────┴──────────────────┘
```

## GCWebConnect - Request Coordinator

**Location:** `ConnectStats/src/GCWebConnect.{h,m}`

### Request Flow

1. Requests added via `addRequest:` method
2. Duplicate check via `isSameAsRequest:`
3. Priority requests inserted at front
4. Sequential processing via `next()` method
5. Per-service status tracking

### Status States

```objc
typedef NS_ENUM(NSUInteger, GCWebStatus) {
    GCWebStatusOK,              // Success
    GCWebStatusAccessDenied,    // 401/403/500
    GCWebStatusLoginFailed,     // Invalid credentials
    GCWebStatusParsingFailed,   // Parse error
    GCWebStatusTempUnavailable, // 429/503 (rate limited)
    GCWebStatusResourceNotFound,// 404
    GCWebStatusConnectionError, // Network error
    GCWebStatusRequireModern,   // Garmin version requirement
    GCWebStatusAccountLocked,   // Account locked
};
```

### Error Handling & Retry

When an error occurs and a `remediationReq` is available:

1. Original request re-queued at priority
2. Remediation request (e.g., re-auth) queued first
3. `secondTry` flag set to prevent infinite loops
4. Status reset to continue processing

```objc
// Example: Garmin access denied triggers re-auth
- (GCWebRequest*)remediationReq {
    if (self.status == GCWebStatusAccessDenied && !self.secondTry) {
        return [[GCGarminLoginSSORequest alloc] init];
    }
    return nil;
}
```

---

## Garmin Connect Integration

**Files:** `ConnectStats/src/GCGarmin*.{h,m,swift}`

### Authentication: Garmin SSO

**File:** `GCGarminLoginSSO.swift`

Three-step authentication flow:

```
Step 1: Pre-Start
    GET https://sso.garmin.com/sso/signin
    Headers: nk: NT (anti-bot)
    Params: service, clientId, gauthHost, consumeServiceTicket
    → Establishes session cookies

Step 2: Login
    POST https://sso.garmin.com/sso/signin
    Body: username, password, _eventId=submit, embed=true
    → Parse response for errors:
       - sendEvent('FAIL') → LoginFailed
       - sendEvent('ACCOUNT_LOCK') → AccountLocked
       - renewPassword → RequirePasswordRenew

Step 3: Cookie
    GET https://connect.garmin.com/modern
    → Establishes Garmin Connect session cookies
```

### Request Classes

**GCGarminRequestModernSearch** - Activity list pagination:
```objc
// Fetches 20 activities per page
URL: GCWebModernSearchURL(start, count)
// Chains via initNextWith: for pagination
```

**GCGarminRequestActivityReload** - Single activity details:
```objc
URL: GCWebActivityURLSummary(activityId)
// Three stages: Download → Parse → Save
```

**GCGarminActivityTrack13Request** (Swift) - Track data download.

### HTTP Status Mapping

```objc
200        → OK
401/403/500→ AccessDenied (triggers re-auth)
404        → ResourceNotFound
429/503    → TempUnavailable (rate limited)
Other      → ServiceLogicError
```

### Kill Switch

Config `CONFIG_GARMIN_KILL_SWITCH` can disable Garmin requests remotely without app update:

```objc
if ([GCAppGlobal configGetBool:CONFIG_GARMIN_KILL_SWITCH defaultValue:true]) {
    return GCWebStatusAccessDenied;  // Block all Garmin requests
}
```

---

## Strava Integration

**Files:** `ConnectStats/src/GCStrava*.swift`

### Authentication: OAuth 2.0

**File:** `GCStravaRequestBase.swift`

Uses OAuthSwift library with SafariViewController flow:

```swift
// OAuth Configuration
authorize_url: credentials["authenticate_url"]
access_token_url: credentials["access_token_url"]
scope: "activity:read_all,read_all"

// Token Storage
oauthToken → profile login name
oauthTokenSecret, oauthRefreshToken → keychain
```

### Authentication Flow

```
1. Check retrieveCredential() for existing token
2. If not signed in:
   - Launch SafariViewController
   - User authorizes app
   - Receive callback with code
   - Exchange code for tokens
3. Store credentials securely
4. Proceed with request
```

### Automatic Token Refresh

On 401 (Expired Token):
```swift
// Automatic refresh
oauthSwift.renewAccessToken(withRefreshToken: refreshToken) { result in
    switch result {
    case .success(let newTokens):
        // Store new tokens
        // Retry original request
    case .failure(let error):
        // Return error status
    }
}
```

### Request Classes

**GCStravaRequestActivityList** - Paginated activity list:
```swift
URL: https://www.strava.com/api/v3/athlete/activities
Params: page, per_page (20 default, 120 for full reload)
```

**GCStravaRequestStreams** - Detailed activity stream data.

---

## ConnectStats Server Integration

**Files:** `ConnectStats/src/GCConnectStats*.{h,m,swift}`

### Authentication: OAuth 1.0a

**File:** `GCConnectStatsRequest.{h,m}`

Token storage:
```objc
// Config keys
CONFIG_CONNECTSTATS_TOKEN      // OAuth token
CONFIG_CONNECTSTATS_USER_ID    // User ID
CONFIG_CONNECTSTATS_TOKEN_ID   // Token ID

// Keychain
gcServiceConnectStats password // Token secret
```

### Login Flow

1. If navigation controller available → Web-based OAuth flow
2. After login → Validate user request:
```objc
POST GCWebConnectStatsValidateUser()
Params: token_id, notification_device_token, notification_enabled
```

### Request Classes

**GCConnectStatsRequestSearch** - Activity list with pagination:
```objc
URL: GCWebConnectStatsSearch() (OAuth-signed)
Params: token_id, start, limit (20 per page)
```

**GCConnectStatsRequestFitFile** - FIT file download:
```objc
// Primary: ConnectStats server
// Fallback: Garmin if external_service_id available
```

**GCConnectStatsRequestBackgroundSearch** (Swift) - Background sync:
```swift
Two modes:
- downloadAndProcess: Immediate processing when organizer loaded
- downloadAndCache: Store in DB for later processing

Cache System:
- GCWebRequestCache stores JSON responses to database
- Keyed by class name and page number
- Persists across app launches
```

### FIT File Fallback Logic

If ConnectStats server doesn't have the FIT file:
```objc
- (BOOL)validAlternativeService {
    // Check if Garmin enabled and activity has external service ID
    return garminEnabled && externalServiceActivityId != nil;
}
```

---

## HealthKit Integration

**Files:** `ConnectStats/src/GCHealthKit*.{h,m}`

### Native API Access

Uses Apple's HKHealthStore directly:

```objc
// Request authorization
HKHealthStore *store = [GCAppGlobal healthKitStore];
[store requestAuthorizationToShareTypes:nil
                             readTypes:workoutTypes
                            completion:...];
```

### Request Classes

**GCHealthKitActivityRequest** - Fetch workouts:
```objc
// Query HKWorkout objects
// Convert to GCActivity via GCHealthKitActivityParser
```

### Activity Conversion

HealthKit workouts mapped to ConnectStats model:
```objc
// GCActivity+Import
- (instancetype)initWithId:(NSString*)aId
          andHealthKitWorkout:(HKWorkout*)workout
                  withSamples:(NSArray*)samples;
```

---

## Sync Status Tracking

**File:** `GCService.{h,m}`

### Database Table

```sql
CREATE TABLE gc_activities_sync (
    activityId TEXT,
    date REAL,
    service INTEGER
);
```

### Service Enumeration

```objc
typedef NS_ENUM(NSUInteger, gcService) {
    gcServiceGarmin = 0,
    gcServiceStrava = 1,
    gcServiceHealthStore = 2,
    gcServiceConnectStats = 3,
    gcServiceEnd
};
```

### Sync Recording

```objc
// Record sync timestamp
[GCService recordSync:activityId forService:gcServiceGarmin];

// Query last sync
NSDate *lastSync = [GCService lastSync:activityId forService:gcServiceStrava];
```

---

## Background Sync

### Background Fetch

**File:** `GCAppDelegate.m`

Background fetch triggers `GCConnectStatsRequestBackgroundSearch` which:
1. Downloads new activities
2. Caches to database if organizer not loaded
3. Main app retrieves from cache on launch

### Cache System

```swift
// Store response
GCWebRequestCache.cache(data, forClass: Self.self, page: page)

// Retrieve cached
GCWebRequestCache.cached(forClass: Self.self, page: page)
```

---

## Error Recovery Summary

| Service | Auth Error | Rate Limit | Network Error |
|---------|------------|------------|---------------|
| Garmin | Re-auth via SSO | Wait/retry | Retry later |
| Strava | Auto token refresh | Wait/retry | Retry later |
| ConnectStats | Web re-auth | Wait/retry | Retry later |
| HealthKit | Re-request permissions | N/A | Retry later |

---

## Known Issues & Considerations

### Garmin SSO Fragility

Garmin's SSO flow is undocumented and changes periodically. The `nk: NT` header and multi-step flow may break with Garmin updates.

### Strava Rate Limits

Strava has strict rate limits. The app uses:
- 20 activities per page normally
- 120 per page during full reload (fewer requests)

### ConnectStats Server Dependency

FIT file access often requires the ConnectStats server. When unavailable, falls back to Garmin direct (if enabled).

### Token Storage

- Garmin: Session cookies (temporary)
- Strava: Keychain (OAuth tokens)
- ConnectStats: Config + Keychain (OAuth 1.0a)
