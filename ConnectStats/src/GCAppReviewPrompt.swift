//  MIT License
//
//  Created on 06/11/2026 for ConnectStats
//
//  Copyright (c) 2026 Brice Rosenzweig
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

import Foundation

/// Decides when to ask StoreKit for an App Store review (replaces the Armchair pod).
///
/// A review is requested once the app has been used `usesUntilPrompt` times and
/// `daysUntilPrompt` days have passed since the first use, and at most once per
/// app version. The system applies its own throttling on top of this, and may
/// decide not to show anything.
struct GCAppReviewPrompt {
    let daysUntilPrompt: Int
    let usesUntilPrompt: Int
    var defaults: UserDefaults = .standard

    private enum Key {
        static let firstUse = "review_prompt_first_use"
        static let useCount = "review_prompt_use_count"
        static let lastPromptedVersion = "review_prompt_last_version"
    }

    static var currentVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    /// Call once per launch.
    func recordUse(now: Date = Date()) {
        if defaults.object(forKey: Key.firstUse) == nil {
            defaults.set(now, forKey: Key.firstUse)
        }
        defaults.set(defaults.integer(forKey: Key.useCount) + 1, forKey: Key.useCount)
    }

    func shouldPrompt(now: Date = Date(), version: String = GCAppReviewPrompt.currentVersion) -> Bool {
        guard defaults.string(forKey: Key.lastPromptedVersion) != version else { return false }
        guard defaults.integer(forKey: Key.useCount) >= usesUntilPrompt else { return false }
        guard let firstUse = defaults.object(forKey: Key.firstUse) as? Date else { return false }
        let days = Calendar.current.dateComponents([.day], from: firstUse, to: now).day ?? 0
        return days >= daysUntilPrompt
    }

    func markPrompted(version: String = GCAppReviewPrompt.currentVersion) {
        defaults.set(version, forKey: Key.lastPromptedVersion)
    }
}
