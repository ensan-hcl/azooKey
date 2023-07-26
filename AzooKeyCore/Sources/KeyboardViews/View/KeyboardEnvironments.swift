//
//  KeyboardEnvironments.swift
//  azooKey
//
//  Created by ensan on 2023/03/23.
//  Copyright © 2023 ensan. All rights reserved.
//

import KeyboardThemes
import SwiftUI

struct GenericThemeEnvironmentKey<Extension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>: EnvironmentKey {
    typealias Value = ThemeData<Extension>

    static var defaultValue: Value { Extension.default(layout: .flick) }
}

struct ExtensionSpecifier<Extension: ApplicationSpecificTheme>: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: ThemeData<Extension>.self))
    }
}

extension EnvironmentValues {
    subscript<Extension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>(themeType _: ExtensionSpecifier<Extension>) -> ThemeData<Extension> {
        get {
            self[GenericThemeEnvironmentKey<Extension>.self]
        }
        set {
            self[GenericThemeEnvironmentKey<Extension>.self] = newValue
        }
    }
}

extension Environment {
    init<Extension: ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>(_ type: ThemeData<Extension>.Type) where Value == ThemeData<Extension> {
        self.init(\.[themeType: ExtensionSpecifier()])
    }
}

public extension View {
    func themeEnvironment(_ value: ThemeData<some ApplicationSpecificKeyboardViewExtensionLayoutDependentDefaultThemeProvidable>) -> some View {
        self.environment(\.[themeType: ExtensionSpecifier()], value)
    }
}

struct MessageEnvironmentKey: EnvironmentKey {
    typealias Value = Bool

    static var defaultValue = true
}

public extension EnvironmentValues {
    var showMessage: Bool {
        get {
            self[MessageEnvironmentKey.self]
        }
        set {
            self[MessageEnvironmentKey.self] = newValue
        }
    }
}

struct UserActionManagerEnvironmentKey: EnvironmentKey {
    typealias Value = UserActionManager

    static var defaultValue = UserActionManager()
}

public extension EnvironmentValues {
    var userActionManager: UserActionManager {
        get {
            self[UserActionManagerEnvironmentKey.self]
        }
        set {
            self[UserActionManagerEnvironmentKey.self] = newValue
        }
    }
}
