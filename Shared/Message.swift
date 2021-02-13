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

    var key: String {
        return self.rawValue + "_status"
    }
}

struct MessageData: Identifiable{
    ///Uniqueな識別子
    let id: MessageIdentifier

    ///タイトル
    let title: String

    ///説明
    let description: String

    ///収容アプリを開く必要があるか
    let needOpenContainer: Bool

    ///詳細な情報の説明リンク
    let detailsURL: String?

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

    let necessaryMessages: [MessageData] = [
        MessageData(
            id: .ver1_5_update_loudstxt,
            title: "お願い",
            description: "内部データの更新のため本体アプリを開く必要があります。よろしいですか？",
            needOpenContainer: true,
            detailsURL: "https://azookey.netlify.app/messages/ver1_5",
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
        /*
        MessageData(
            id: .mock,
            title: "お願い",
            description: "内部データの更新のため本体アプリを開く必要があります。よろしいですか？",
            needOpenContainer: true,
            detailsURL: "https://azookey.netlify.app/",
            precondition: { true },
            containerAppShouldMakeItDone: { false }
        )*/

    ]

    private var needShow: [MessageIdentifier: Bool]

    init(){
        self.needShow = necessaryMessages.reduce(into: [:]){dict, value in
            dict[value.id] = value.precondition() && Self.userDefaults.string(forKey: value.id.key) != "done"
        }
    }

    func requireShow(_ id: MessageIdentifier) -> Bool {
        return needShow[id, default: false]
    }

    mutating func done(_ id: MessageIdentifier){
        self.needShow[id] = false
        Self.userDefaults.setValue("done", forKey: id.key)
    }
}
