//  MIT Licence
//
//  Created on 01/03/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

#import "GCWebConnect.h"

@class GCActivity;

@interface GCWebConnect (Requests)


// Global Process
-(void)servicesSearchActivitiesFrom:(NSUInteger)aStart reloadAll:(BOOL)rAll;
-(void)servicesSearchRecentActivities;
-(void)servicesSearchAllActivities;

-(void)servicesResetLogin; // when profile switch
-(void)servicesLogin; // add necessary login requests

-(void)downloadMissingActivityDetails:(NSUInteger)n;

// Withings
-(void)withingsUpdate;
-(void)withingsChangeUser:(NSString*)shortname;

// Garmin
-(void)garminDownloadActivityTrackPoints13:(GCActivity*)act;
-(void)garminDownloadActivitySummary:(NSString*)aId;
-(void)garminDownloadWeather:(GCActivity*)activity;

// ConnectStats
-(void)connectStatsDownloadActivityTrackpoints:(GCActivity*)act;

// Strava
-(void)stravaDownloadActivityTrackPoints:(GCActivity*)act;

// Babolat
-(void)babolatDownloadTennisActivityDetails:(NSString*)aId;

// sporttracks
-(void)sportTracksDownloadActivityTrackPoints:(NSString*)aId withUri:(NSString*)uri;

// GarminLogin
-(void)garminTestLogin;// should not use only for testing
-(void)garminLogin;
-(void)garminLogout;

// FitBit
-(void)fitBitUpdate;
-(void)fitBitUpdateFromDate:(NSDate*)date;

// HealthKti
-(void)healthStoreExportActivity:(GCActivity*)act;
-(void)healthStoreDayDetails:(NSDate * )day;
-(void)healthStoreCheckSource;

//Derived
-(void)derivedComputations:(NSUInteger)n;

@end
