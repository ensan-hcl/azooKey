//
//  SharedStore.swift
//  azooKey
//
//  Created by ensan on 2020/11/20.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUtils

public enum SharedStore {
    @MainActor static let userDefaults = UserDefaults(suiteName: Self.appGroupKey)!
    public static let bundleName = "DevEn3.azooKey.keyboard"
    public static let appGroupKey = "group.com.azooKey.keyboard"

    private static var appVersionString: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    private static let initialAppVersionKey = "InitialAppVersion"
    private static let lastAppVersionKey = "LastAppVersion"
    public static var currentAppVersion: AppVersion? {
        if let appVersionString = appVersionString {
            return AppVersion(appVersionString)
        }
        return nil
    }
    // this value will be 1.7.1 at minimum
    @MainActor public static var initialAppVersion: AppVersion? {
        if let appVersionString = userDefaults.string(forKey: initialAppVersionKey) {
            return AppVersion(appVersionString)
        }
        return nil
    }

    // this value will be 2.0.0 at minimum
    @MainActor public static var lastAppVersion: AppVersion? {
        if let appVersionString = userDefaults.string(forKey: lastAppVersionKey) {
            return AppVersion(appVersionString)
        }
        return nil
    }

    @MainActor public static func setInitialAppVersion() {
        if initialAppVersion == nil, let appVersionString = appVersionString {
            SharedStore.userDefaults.set(appVersionString, forKey: initialAppVersionKey)
        }
    }

    @MainActor public static func setLastAppVersion() {
        if let appVersionString = appVersionString {
            SharedStore.userDefaults.set(appVersionString, forKey: lastAppVersionKey)
        }
    }

    public enum ShareThisWordOptions: String {
        case 人・動物・会社などの名前
        case 場所・建物などの名前
        case 五段活用
    }

    public static func sendSharedWord(word: String, ruby: String, options: [ShareThisWordOptions]) async -> Bool {
        let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLScrNWRx2DBb1fCbfcHenyO4myrD4e85WlhIJrkyEnEF0zCD1A/formResponse")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("no-cors", forHTTPHeaderField: "mode")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var parameters = "entry.879616659=\(word)&entry.1030786153=\(ruby)"
        for option in options {
            parameters += "&entry.1819903648=\(option.rawValue)"
        }
        request.httpBody = parameters
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .data(using: .utf8) ?? Data()
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            debug("sendSharedWord response", response)
            return true
        } catch {
            debug("sendSharedWord error", error)
            return false
        }
    }
}

public extension AppVersion {
    static let azooKey_v2_0_2 = AppVersion("2.0.2")!
    static let azooKey_v1_9 = AppVersion("1.9")!
    static let azooKey_v1_8_1 = AppVersion("1.8.1")!
    static let azooKey_v1_8 = AppVersion("1.8")!
    static let azooKey_v1_7_2 = AppVersion("1.7.2")!
    static let azooKey_v1_7_1 = AppVersion("1.7.1")!
}
