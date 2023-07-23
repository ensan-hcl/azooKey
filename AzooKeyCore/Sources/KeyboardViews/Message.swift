//
//  Message.swift
//  Keyboard
//
//  Created by ensan on 2021/01/29.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUtils

public protocol MessageIdentifierProtocol: Hashable, Identifiable {
    var needUsingContainerApp: Bool { get }
    var key: String { get }
}

public struct MessageData<ID: MessageIdentifierProtocol> {
    public init(id: ID, title: String, description: String, button: MessageData<ID>.MessageButtonStyle, precondition: @escaping () -> Bool, silentDoneCondition: @escaping @MainActor () -> Bool, containerAppShouldMakeItDone: @escaping () -> Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.button = button
        self.precondition = precondition
        self.silentDoneCondition = silentDoneCondition
        self.containerAppShouldMakeItDone = containerAppShouldMakeItDone
    }

    /// Uniqueな識別子
    public let id: ID

    /// タイトル
    let title: String

    /// 説明
    let description: String

    /// ボタン
    let button: MessageButtonStyle

    /// メッセージを表示する前提条件
    let precondition: () -> Bool

    /// メッセージを表示せずにDoneにして良い条件
    let silentDoneCondition: @MainActor () -> Bool

    /// 収容アプリがDoneにすべき条件
    let containerAppShouldMakeItDone: () -> Bool

    public enum MessageButtonStyle {
        case one(MessagePrimaryButtonStyle)
        case two(primary: MessagePrimaryButtonStyle, secondary: MessageSecondaryButtonStyle)
    }

    public enum MessageSecondaryButtonStyle {
        /// 「詳細」と表示し、押した場合リンクにする
        case details(url: String)

        /// 「後で」と表示し、押した場合メッセージのステータスを完了に変更する
        case later

        /// 「了解」と表示し、押した場合メッセージのステータスを完了に変更する
        case OK
    }

    public enum MessagePrimaryButtonStyle {
        /// 指定した単語を表示し、押した場合収容アプリを開く
        case openContainer(text: String)

        /// 「了解」と表示し、押した場合メッセージのステータスを完了に変更する
        case OK
    }
}

public struct MessageManager<ID: MessageIdentifierProtocol> {
    public func getMessagesContainerAppShouldMakeWhichDone() -> [MessageData<ID>] {
        necessaryMessages.filter {$0.containerAppShouldMakeItDone()}
    }
    static var doneFlag: String { "done" }
    private var needShow: [ID: Bool]
    public let necessaryMessages: [MessageData<ID>]
    let userDefaults: UserDefaults

    @MainActor public init(necessaryMessages: [MessageData<ID>], userDefaults: UserDefaults) {
        self.necessaryMessages = necessaryMessages
        self.userDefaults = userDefaults
        self.needShow = necessaryMessages.reduce(into: [:]) {dict, value in
            dict[value.id] = value.precondition() && Self.checkDone(value.id, userDefaults: userDefaults)
        }
        // 勝手にDoneにしてしまって問題のないものについては、この段階でDoneにする。
        for item in necessaryMessages {
            if item.silentDoneCondition() {
                self.done(item.id)
            }
        }
    }

    public func requireShow(_ id: ID) -> Bool {
        needShow[id, default: false]
    }

    public mutating func done(_ id: ID) {
        self.needShow[id] = false
        if id.needUsingContainerApp {
            // 収容アプリでのみ完了にできる場合、共有のSelf.userDefaultsのみチェック
            userDefaults.setValue(Self.doneFlag, forKey: id.key)
        } else {
            // 本体アプリでも完了にできる場合、共有のSelf.userDefaultsに加えて本体のみのUserDefaults.standardでもチェック
            userDefaults.setValue(Self.doneFlag, forKey: id.key)
            UserDefaults.standard.setValue(Self.doneFlag, forKey: id.key)
        }
    }

    /// `Done`か否かを判定する
    public static func checkDone(_ id: ID, userDefaults: UserDefaults) -> Bool {
        if id.needUsingContainerApp {
            // 収容アプリでのみ完了にできる場合、共有のSelf.userDefaultsのみチェック
            return userDefaults.string(forKey: id.key) != Self.doneFlag
        } else {
            // 本体アプリでも完了にできる場合、共有のSelf.userDefaultsに加えて本体のみのUserDefaults.standardでもチェック
            return userDefaults.string(forKey: id.key) != Self.doneFlag && UserDefaults.standard.string(forKey: id.key) != Self.doneFlag
        }
    }
}
