//
//  Message.swift
//  Keyboard
//
//  Created by β α on 2021/01/29.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

enum MessageIdentifier: String, Hashable, CaseIterable{
    case mock = "mock_alert0"
    case ver1_5_update_loudstxt = "ver1_5_update_loudstxt"  //frozen
    case iOS14_5_new_emoji = "iOS_14_5_new_emoji"

    var key: String {
        return self.rawValue + "_status"
    }

    var needUsingContainerApp: Bool {
        switch self{
        case .ver1_5_update_loudstxt:
            return true
        case .iOS14_5_new_emoji, .mock:
            return false
        }
    }

}

enum MessageLeftButtonStyle{
    ///「詳細」と表示し、押した場合リンクにする
    case details(url: String)

    ///「後で」と表示し、押した場合メッセージのステータスを完了に変更する
    case later
}

enum MessageRightButtonStyle{
    ///指定した単語を表示し、押した場合収容アプリを開く
    case openContainer(text: String)

    ///「了解」と表示し、押した場合メッセージのステータスを完了に変更する
    case OK
}

struct MessageData: Identifiable{
    ///Uniqueな識別子
    let id: MessageIdentifier

    ///タイトル
    let title: String

    ///説明
    let description: String

    ///左側のボタン
    let leftsideButton: MessageLeftButtonStyle

    ///右側のボタン
    let rightsideButton: MessageRightButtonStyle

    ///メッセージを表示する前提条件
    let precondition: () -> Bool

    ///収容アプリがDoneにすべき条件
    let containerAppShouldMakeItDone: () -> Bool
}

struct MessageManager{
    static let userDefaults = UserDefaults.init(suiteName: SharedStore.appGroupKey)!
    func getMessagesContainerAppShouldMakeWhichDone() -> [MessageData] {
        necessaryMessages.filter{$0.containerAppShouldMakeItDone()}
    }
    static let doneFlag = "done"

    let necessaryMessages: [MessageData] = [
        MessageData(
            id: .ver1_5_update_loudstxt,
            title: "お願い",
            description: "内部データの更新のため本体アプリを開く必要があります。よろしいですか？",
            leftsideButton: .details(url: "https://azookey.netlify.app/messages/ver1_5"),
            rightsideButton: .openContainer(text: "更新"),
            precondition: {
                //ユーザ辞書に登録があるのが条件。
                let directoryPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
                let binaryFilePath = directoryPath.appendingPathComponent("user.louds").path
                return FileManager.default.fileExists(atPath: binaryFilePath)
            },
            containerAppShouldMakeItDone: {
                //ユーザ辞書に登録がない場合はDoneにして良い。
                let directoryPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
                let binaryFilePath = directoryPath.appendingPathComponent("user.louds").path
                return !FileManager.default.fileExists(atPath: binaryFilePath)
            }
        ),

        MessageData(
            id: .iOS14_5_new_emoji,
            title: "お知らせ",
            description: "iOS14.5で新しい絵文字が追加されました。本体アプリを開き、データを更新しますか？",
            leftsideButton: .later,
            rightsideButton: .openContainer(text: "更新"),
            precondition: {
                if #available(iOS 14.5, *){
                    return true
                }else{
                    return false
                }
            },
            containerAppShouldMakeItDone: { false }
        ),
    ]

    private var needShow: [MessageIdentifier: Bool]

    init(){
        self.needShow = necessaryMessages.reduce(into: [:]){dict, value in
            if value.id.needUsingContainerApp{
                //収容アプリでのみ完了にできる場合、共有のSelf.userDefaultsのみチェック
                dict[value.id] = value.precondition() && Self.userDefaults.string(forKey: value.id.key) != Self.doneFlag
            }else{
                //本体アプリでも完了にできる場合、共有のSelf.userDefaultsに加えて本体のみのUserDefaults.standardでもチェック
                dict[value.id] = value.precondition() && Self.userDefaults.string(forKey: value.id.key) != Self.doneFlag && UserDefaults.standard.string(forKey: value.id.key) != Self.doneFlag
            }
        }
    }

    func requireShow(_ id: MessageIdentifier) -> Bool {
        return needShow[id, default: false]
    }

    mutating func done(_ id: MessageIdentifier){
        self.needShow[id] = false
        if id.needUsingContainerApp{
            //収容アプリでのみ完了にできる場合、共有のSelf.userDefaultsのみチェック
            Self.userDefaults.setValue(Self.doneFlag, forKey: id.key)
        }else{
            //本体アプリでも完了にできる場合、共有のSelf.userDefaultsに加えて本体のみのUserDefaults.standardでもチェック
            Self.userDefaults.setValue(Self.doneFlag, forKey: id.key)
            UserDefaults.standard.setValue(Self.doneFlag, forKey: id.key)
        }
    }
}
