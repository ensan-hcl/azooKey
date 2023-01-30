//
//  SharedStore.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum SharedStore {
    static let userDefaults = UserDefaults(suiteName: Self.appGroupKey)!
    static let bundleName = "DevEn3.azooKey.keyboard"
    static let appGroupKey = "group.com.azooKey.keyboard"

    private static var appVersionString: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    private static let initialAppVersionKey = "InitialAppVersion"
    static var currentAppVersion: AppVersion? {
        if let appVersionString = appVersionString {
            return AppVersion(appVersionString)
        }
        return nil
    }
    // this value will be 1.7.1 at minimum
    static var initialAppVersion: AppVersion? {
        if let appVersionString = userDefaults.string(forKey: initialAppVersionKey) {
            return AppVersion(appVersionString)
        }
        return nil
    }

    static func setInitialAppVersion() {
        if initialAppVersion == nil, let appVersionString = appVersionString {
            SharedStore.userDefaults.set(appVersionString, forKey: initialAppVersionKey)
        }
    }
}

extension AppVersion {
    static let azooKey_v1_9 = AppVersion("1.9")!
    static let azooKey_v1_8_1 = AppVersion("1.8.1")!
    static let azooKey_v1_8 = AppVersion("1.8")!
    static let azooKey_v1_7_2 = AppVersion("1.7.2")!
    static let azooKey_v1_7_1 = AppVersion("1.7.1")!
}
