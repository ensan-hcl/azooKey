//
//  ApplicationSpecificKeyboardViewExtension.swift
//
//
//  Created by ensan on 2023/07/21.
//

import Foundation
import KeyboardThemes

public protocol ApplicationSpecificKeyboardViewExtension {
    associatedtype ThemeExtension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable
    associatedtype MessageProvider: ApplicationSpecificKeyboardViewMessageProvider
    associatedtype SettingProvider: ApplicationSpecificKeyboardViewSettingProvider
}

extension ApplicationSpecificKeyboardViewExtension {
    typealias Theme = ThemeData<ThemeExtension>
}

public protocol ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable: ApplicationSpecificTheme {
    /// レイアウトに依存したデフォルトテーマを返す
    static func `default`(layout: KeyboardLayout) -> ThemeData<Self>
}

public protocol ApplicationSpecificKeyboardViewMessageProvider {
    associatedtype MessageID: MessageIdentifierProtocol
    static var messages: [MessageData<MessageID>] { get }
    static var userDefaults: UserDefaults { get }
}
