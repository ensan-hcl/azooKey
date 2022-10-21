//
//  Message.swift
//  Keyboard
//
//  Created by β α on 2021/01/29.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

enum MessageIdentifier: String, Hashable, CaseIterable {
    case mock = "mock_alert_2022_09_16_03"
    case iOS15_4_new_emoji = "iOS_15_4_new_emoji"                    // MARK: frozen
    case ver1_9_user_dictionary_update = "ver1_9_user_dictionary_update_debug_10_21_00"

    // MARK: 過去にプロダクションで用いていたメッセージID
    // ver1_9_user_dictionary_updateが実行されれば不要になるので、この宣言は削除
    // case ver1_5_update_loudstxt = "ver1_5_update_loudstxt"           // MARK: frozen
    // iOS15_4_new_emojiが実行されれば不要になるので、この宣言は削除
    // case iOS14_5_new_emoji = "iOS_14_5_new_emoji_fixed_ver_1_6_1"    // MARK: frozen
    // 新機能の紹介も削除
    // case liveconversion_introduction = "liveconversion_introduction" // MARK: frozen
    // case ver1_8_autocomplete_introduction = "ver1_8_autocomplete_introduction" // MARK: frozen

    var key: String {
        return self.rawValue + "_status"
    }

    var needUsingContainerApp: Bool {
        switch self {
        case .ver1_9_user_dictionary_update:
            return true
        case .iOS15_4_new_emoji, .mock:
            return false
        }
    }
}

struct MessageData: Identifiable {
    /// Uniqueな識別子
    let id: MessageIdentifier

    /// タイトル
    let title: String

    /// 説明
    let description: String

    /// 左側のボタン
    let leftsideButton: MessageLeftButtonStyle

    /// 右側のボタン
    let rightsideButton: MessageRightButtonStyle

    /// メッセージを表示する前提条件
    let precondition: () -> Bool

    /// メッセージを表示せずにDoneにして良い条件
    let silentDoneCondition: () -> Bool

    /// 収容アプリがDoneにすべき条件
    let containerAppShouldMakeItDone: () -> Bool

    enum MessageLeftButtonStyle {
        /// 「詳細」と表示し、押した場合リンクにする
        case details(url: String)

        /// 「後で」と表示し、押した場合メッセージのステータスを完了に変更する
        case later

        /// 「了解」と表示し、押した場合メッセージのステータスを完了に変更する
        case OK
    }

    enum MessageRightButtonStyle {
        /// 指定した単語を表示し、押した場合収容アプリを開く
        case openContainer(text: String)

        /// 「了解」と表示し、押した場合メッセージのステータスを完了に変更する
        case OK
    }
}

struct MessageManager {
    func getMessagesContainerAppShouldMakeWhichDone() -> [MessageData] {
        necessaryMessages.filter {$0.containerAppShouldMakeItDone()}
    }
    static let doneFlag = "done"

    let necessaryMessages: [MessageData] = [
        MessageData(
            id: .iOS15_4_new_emoji,
            title: "お知らせ",
            description: "iOS15.4で新しい絵文字が追加されました。本体アプリを開き、データを更新しますか？",
            leftsideButton: .later,
            rightsideButton: .openContainer(text: "更新"),
            precondition: {
                if #available(iOS 15.4, *) {
                    return true
                } else {
                    return false
                }
            },
            silentDoneCondition: {
                // ダウンロードがv1.8以降の場合はDone
                if (SharedStore.initialAppVersion ?? .azooKey_v1_7_1) >= .azooKey_v1_8 {
                    return true
                }
                return false
            },
            containerAppShouldMakeItDone: { false }
        ),
        MessageData(
            id: .ver1_9_user_dictionary_update,
            title: "お願い",
            description: "内部データの更新のため本体アプリを開いてください。本体アプリを開くまで、一部の機能が制限されます。",
            leftsideButton: .later,
            rightsideButton: .openContainer(text: "更新"),
            precondition: {
                // ユーザ辞書に登録があるのが条件。
                let directoryPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
                let binaryFilePath = directoryPath.appendingPathComponent("user.louds", isDirectory: false).path
                return FileManager.default.fileExists(atPath: binaryFilePath)
            },
            silentDoneCondition: {
                // ダウンロードがv1.9以降の場合はDone
                if (SharedStore.initialAppVersion ?? .azooKey_v1_7_1) >= .azooKey_v1_9 {
                    return true
                }
                return false
            },
            containerAppShouldMakeItDone: {
                // ユーザ辞書に登録がない場合はDoneにして良い。
                let directoryPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
                let binaryFilePath = directoryPath.appendingPathComponent("user.louds", isDirectory: false).path
                return !FileManager.default.fileExists(atPath: binaryFilePath)
            }
        ),
    ]

    private var needShow: [MessageIdentifier: Bool]

    init() {
        self.needShow = necessaryMessages.reduce(into: [:]) {dict, value in
            if value.id.needUsingContainerApp {
                // 収容アプリでのみ完了にできる場合、共有のSelf.userDefaultsのみチェック
                dict[value.id] = value.precondition() && SharedStore.userDefaults.string(forKey: value.id.key) != Self.doneFlag
            } else {
                // 本体アプリでも完了にできる場合、共有のSelf.userDefaultsに加えて本体のみのUserDefaults.standardでもチェック
                dict[value.id] = value.precondition() && SharedStore.userDefaults.string(forKey: value.id.key) != Self.doneFlag && UserDefaults.standard.string(forKey: value.id.key) != Self.doneFlag
            }
        }
        // 勝手にDoneにしてしまって問題のないものについては、この段階でDoneにする。
        for item in necessaryMessages {
            if item.silentDoneCondition() {
                self.done(item.id)
            }
        }
    }

    func requireShow(_ id: MessageIdentifier) -> Bool {
        return needShow[id, default: false]
    }

    mutating func done(_ id: MessageIdentifier) {
        self.needShow[id] = false
        if id.needUsingContainerApp {
            // 収容アプリでのみ完了にできる場合、共有のSelf.userDefaultsのみチェック
            SharedStore.userDefaults.setValue(Self.doneFlag, forKey: id.key)
        } else {
            // 本体アプリでも完了にできる場合、共有のSelf.userDefaultsに加えて本体のみのUserDefaults.standardでもチェック
            SharedStore.userDefaults.setValue(Self.doneFlag, forKey: id.key)
            UserDefaults.standard.setValue(Self.doneFlag, forKey: id.key)
        }
    }
}
