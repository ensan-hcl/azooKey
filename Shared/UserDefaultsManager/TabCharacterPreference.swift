//
//  TabCharacterPreference.swift
//  azooKey
//
//  Created by ensan on 2023/03/18.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation

/// 絵文字等のタブで、表示する文字に関する設定を記述する
struct TabCharacterPreference: Codable, KeyboardInternalSettingValue {
    static let initialValue = Self()
    private var preferences: [PreferenceItem] = []
    /// - note: Valueの配列は常にソートした状態にする
    /// - note: 上位70件くらいまでを保存しておく
    private var recentlyUsedItems: [TabIdentifier: [RecentlyUsedItem]] = [:]

    func getPreferences(for tab: TabIdentifier) -> [String: String] {
        let replacements: [String: String] = preferences.reduce(into: [:]) { (dict, item) in
            if item.tab == tab {
                dict[item.base] = item.replace
            }
        }
        return replacements
    }

    func getRecentlyUsed(for tab: TabIdentifier, count: Int = 30) -> [String] {
        let histories: [RecentlyUsedItem] = recentlyUsedItems[tab, default: []]
        return histories.prefix(count).map {$0.base}
    }

    mutating func setUsed(base: String, for tab: TabIdentifier) {
        var items = recentlyUsedItems[tab, default: []]
        if let index = items.firstIndex(where: {$0.base == base}) {
            items[index].history.append(.now)
        } else {
            let newItem = RecentlyUsedItem(base: base, history: [.now])
            items.append(newItem)
        }
        // 最後に使った日から現在までの経過時間を、利用回数(history.count)で割ったものでソートする
        items = items.sorted { lhs, rhs in
            lhs.score() < rhs.score()
        }
        if items.count > 70 {
            items.removeLast(items.count - 70)
        }
        self.recentlyUsedItems[tab] = items
    }

    mutating func setPreference(base: String, replace: String, for tab: TabIdentifier) {
        if let index = self.preferences.firstIndex(where: {$0.tab == tab && $0.base == base}) {
            self.preferences[index].replace = replace
            self.preferences[index].lastUpdate = .now
        } else {
            self.preferences.append(.init(tab: tab, base: base, replace: replace, lastUpdate: .now))
        }
    }

    struct RecentlyUsedItem: Codable {
        var base: String
        var history: [Date]

        /// 小さいほど良い
        func score() -> Double {
            guard !self.history.isEmpty else {
                return .infinity
            }
            // (最近ほど小さい) / (使われるほど大きい)
            // 差分10000を加える
            return (-self.history.last!.timeIntervalSinceNow + 10000) / Double(self.history.count)
        }
    }

    struct PreferenceItem: Codable {
        var tab: TabIdentifier
        var base: String
        var replace: String
        var lastUpdate: Date
    }

    enum TabIdentifier: Codable, Equatable, Hashable {
        /// システムのタブの設定
        case system(SystemTab)

        enum SystemTab: String, Codable {
            case emoji
        }
    }
}
