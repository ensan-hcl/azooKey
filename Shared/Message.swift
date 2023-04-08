//
//  Message.swift
//  Keyboard
//
//  Created by ensan on 2021/01/29.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

enum MessageIdentifier: String, Hashable, CaseIterable {
    case mock = "mock_alert_2022_09_16_03"
    case iOS15_4_new_emoji = "iOS_15_4_new_emoji"                    // MARK: frozen
    case iOS16_4_new_emoji = "iOS_16_4_new_emoji_commit"                    // MARK: frozen
    case ver1_9_user_dictionary_update = "ver1_9_user_dictionary_update_release" // MARK: frozen
    case ver2_1_emoji_tab = "ver2_1_emoji_tab"

    // MARK: 過去にプロダクションで用いていたメッセージID
    // ver1_9_user_dictionary_updateが実行されれば不要になるので、この宣言は削除
    // case ver1_5_update_loudstxt = "ver1_5_update_loudstxt"           // MARK: frozen
    // iOS15_4_new_emojiが実行されれば不要になるので、この宣言は削除
    // case iOS14_5_new_emoji = "iOS_14_5_new_emoji_fixed_ver_1_6_1"    // MARK: frozen
    // 新機能の紹介も削除
    // case liveconversion_introduction = "liveconversion_introduction" // MARK: frozen
    // case ver1_8_autocomplete_introduction = "ver1_8_autocomplete_introduction" // MARK: frozen

    var key: String {
        self.rawValue + "_status"
    }

    var needUsingContainerApp: Bool {
        switch self {
        case .ver1_9_user_dictionary_update, .ver2_1_emoji_tab:
            return true
        case .iOS15_4_new_emoji, .iOS16_4_new_emoji, .mock:
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

    /// ボタン
    let button: MessageButtonStyle

    /// メッセージを表示する前提条件
    let precondition: () -> Bool

    /// メッセージを表示せずにDoneにして良い条件
    let silentDoneCondition: () -> Bool

    /// 収容アプリがDoneにすべき条件
    let containerAppShouldMakeItDone: () -> Bool

    enum MessageButtonStyle {
        case one(MessagePrimaryButtonStyle)
        case two(primary: MessagePrimaryButtonStyle, secondary: MessageSecondaryButtonStyle)
    }

    enum MessageSecondaryButtonStyle {
        /// 「詳細」と表示し、押した場合リンクにする
        case details(url: String)

        /// 「後で」と表示し、押した場合メッセージのステータスを完了に変更する
        case later

        /// 「了解」と表示し、押した場合メッセージのステータスを完了に変更する
        case OK
    }

    enum MessagePrimaryButtonStyle {
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
            button: .two(primary: .openContainer(text: "更新"), secondary: .later),
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
                // .iOS16_4の方が終わっていたらDone
                if Self.checkDone(.iOS16_4_new_emoji) {
                    return true
                }
                return false
            },
            containerAppShouldMakeItDone: { false }
        ),
        MessageData(
            id: .iOS16_4_new_emoji,
            title: "お知らせ",
            description: "iOS16.4で「🫨 (震える顔)」「🩵 (水色のハート)」「🪽 (羽)」などの新しい絵文字が追加されました。本体アプリを開き、データを更新しますか？",
            button: .two(primary: .openContainer(text: "更新"), secondary: .later),
            precondition: {
                if #available(iOS 16.4, *) {
                    return true
                } else {
                    return false
                }
            },
            silentDoneCondition: {
                // ダウンロードがv2.0.2以降の場合はDone
                if (SharedStore.initialAppVersion ?? .azooKey_v1_7_1) >= .azooKey_v2_0_2 {
                    return true
                }
                return false
            },
            containerAppShouldMakeItDone: { false }
        ),
        MessageData(
            id: .ver1_9_user_dictionary_update,
            title: "お願い",
            description: "内部データの更新のため本体アプリを開いてください。\n更新は数秒で終わります。",
            button: .one(.openContainer(text: "更新")),
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
        MessageData(
            id: .ver2_1_emoji_tab,
            title: "お知らせ",
            description: "azooKeyで絵文字タブが使えるようになりました。本体アプリを開き、タブバーに絵文字タブを追加しますか？",
            button: .two(primary: .openContainer(text: "追加"), secondary: .later),
            precondition: {
                true
            },
            silentDoneCondition: {
                if (try? CustardManager.load().tabbar(identifier: 0))?.items.contains(where: {$0.actions.contains(.moveTab(.system(.emoji_tab)))}) == true {
                    return true
                }
                return false
            },
            containerAppShouldMakeItDone: { true }
        )
    ]

    private var needShow: [MessageIdentifier: Bool]

    init() {
        self.needShow = necessaryMessages.reduce(into: [:]) {dict, value in
            dict[value.id] = value.precondition() && Self.checkDone(value.id)
        }
        // 勝手にDoneにしてしまって問題のないものについては、この段階でDoneにする。
        for item in necessaryMessages {
            if item.silentDoneCondition() {
                self.done(item.id)
            }
        }
    }

    func requireShow(_ id: MessageIdentifier) -> Bool {
        needShow[id, default: false]
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

    /// `Done`か否かを判定する
    static func checkDone(_ id: MessageIdentifier) -> Bool {
        if id.needUsingContainerApp {
            // 収容アプリでのみ完了にできる場合、共有のSelf.userDefaultsのみチェック
            return SharedStore.userDefaults.string(forKey: id.key) != Self.doneFlag
        } else {
            // 本体アプリでも完了にできる場合、共有のSelf.userDefaultsに加えて本体のみのUserDefaults.standardでもチェック
            return SharedStore.userDefaults.string(forKey: id.key) != Self.doneFlag && UserDefaults.standard.string(forKey: id.key) != Self.doneFlag
        }
    }
}

enum TemporalMessage {
    case doneForgetCandidate
    case doneReportWrongConversion
    case failedReportWrongConversion

    var title: LocalizedStringKey {
        switch self {
        case .doneForgetCandidate:
            return "候補の学習をリセットしました"
        case .doneReportWrongConversion:
            return "誤変換を報告しました"
        case .failedReportWrongConversion:
            return "誤変換の報告に失敗しました"
        }
    }

    enum DismissCondition {
        case auto
        case ok
    }
    var dismissCondition: DismissCondition {
        switch self {
        case .doneForgetCandidate, .doneReportWrongConversion, .failedReportWrongConversion: return .auto
        }
    }
}
