//
//  KeyboardSetting.swift
//  KeyboardSetting
//
//  Created by ensan on 2021/08/10.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

protocol Savable {
    associatedtype SaveValue
    var saveValue: SaveValue {get}
    static func get(_ value: Any) -> Self?
}

@propertyWrapper
@MainActor
public struct KeyboardSetting<T: KeyboardSettingKey> {
    public init(_ key: T) {}
    public var wrappedValue: T.Value {
        get {
            T.value
        }
        set {
            T.value = newValue
        }
    }
}

/// 生の`SettingKey`の値を`@State`で宣言した場合、更新の反映ができない。
/// `SettingUpdater`で包むことで、設定の更新を行いつつUIの更新も行われるようにできる。
@MainActor public struct SettingUpdater<Wrapped: KeyboardSettingKey> {
     public var value: Wrapped.Value {
        didSet {
            let newValue = value
            Wrapped.value = newValue
        }
    }

    public init() {
        self.value = Wrapped.value
    }

    public mutating func reload() {
        self.value = Wrapped.value
    }
}

public protocol KeyboardSettingKey {
    associatedtype Value: Sendable
    static var defaultValue: Value { get }
    static var title: LocalizedStringKey { get }
    static var explanation: LocalizedStringKey { get }
    @MainActor static var value: Value { get set }
    static var requireFullAccess: Bool { get }
}

public protocol StoredInUserDefault {
    associatedtype Value
    static var key: String { get }
}

public extension KeyboardSettingKey {
    static var requireFullAccess: Bool {
        false
    }
}
