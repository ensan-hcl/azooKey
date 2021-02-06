//
//  EnvironmentValue.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum KeyboardLanguage {
    case english
    case japanese
}
/*
struct LanguageEnvironmentKey: EnvironmentKey {
    typealias Value = KeyboardLanguage
    static var defaultValue: KeyboardLanguage = .japanese
}

extension EnvironmentValues {
    var keyboardLanguage: KeyboardLanguage {
        get {
            return self[LanguageEnvironmentKey.self]
        }
        set {
            self[LanguageEnvironmentKey.self] = newValue
        }
    }
}

*/
