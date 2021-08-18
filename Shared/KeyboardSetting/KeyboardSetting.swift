//
//  KeyboardSetting.swift
//  KeyboardSetting
//
//  Created by β α on 2021/08/10.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

protocol Savable {
    associatedtype SaveValue
    var saveValue: SaveValue {get}
    static func get(_ value: Any) -> Self?
}

@propertyWrapper
struct KeyboardSetting<T: KeyboardSettingKey> {
    init(_ key: T) {}
    var wrappedValue: T.Value {
        get {
            T.value
        }
        set {
            T.value = newValue
        }
    }
}

protocol KeyboardSettingKey {
    associatedtype Value
    static var defaultValue: Value { get }
    static var title: LocalizedStringKey { get }
    static var explanation: LocalizedStringKey { get }
    static var value: Value { get set }
}

protocol StoredInUserDefault {
    associatedtype Value
    static var key: String { get }
}
