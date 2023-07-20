//
//  KeyboardEnvironments.swift
//  azooKey
//
//  Created by ensan on 2023/03/23.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

struct ThemeEnvironmentKey: EnvironmentKey {
    typealias Value = AzooKeyTheme

    static var defaultValue: AzooKeyTheme = .default(layout: .flick)
}

extension EnvironmentValues {
    var themeEnvironment: AzooKeyTheme {
        get {
            self[ThemeEnvironmentKey.self]
        }
        set {
            self[ThemeEnvironmentKey.self] = newValue
        }
    }
}

struct MessageEnvironmentKey: EnvironmentKey {
    typealias Value = Bool

    static var defaultValue = true
}

extension EnvironmentValues {
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

extension EnvironmentValues {
    var userActionManager: UserActionManager {
        get {
            self[UserActionManagerEnvironmentKey.self]
        }
        set {
            self[UserActionManagerEnvironmentKey.self] = newValue
        }
    }
}
