//
//  Message.swift
//  Keyboard
//
//  Created by β α on 2021/01/29.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

enum MessageIdentifier: String, Hashable{
    case mock = "mock_alert"
    case ver1_5_update_loudstxt = "ver1_5_update_loudstxt"

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
}

struct MessageManager{
    static let userDefaults = UserDefaults.init(suiteName: SharedStore.appGroupKey)!
    let necessaryMessages: [MessageData] = [
        MessageData(
            id: .ver1_5_update_loudstxt,
            title: "お願い",
            description: "内部データの更新のため本体アプリを開きます。よろしいですか？",
            needOpenContainer: true,
            detailsURL: "https://azookey.netlify.app/messages/ver1_5"
        ),
        /*
        MessageData(
            id: .mock,
            title: "お知らせ",
            description: "本体アプリを開きます。よろしいですか？",
            needOpenContainer: true,
            detailsURL: "https://azookey.netlify.app/"
        )*/

    ]

    private var needShow: [MessageIdentifier: Bool]

    init(){
        self.needShow = necessaryMessages.reduce(into: [:]){dict, value in
            dict[value.id] = Self.userDefaults.string(forKey: value.id.key) != "done"
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
