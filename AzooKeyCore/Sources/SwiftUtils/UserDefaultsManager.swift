//
//  UserDefaultsManager.swift
//
//
//  Created by ensan on 2023/07/21.
//

import Foundation

public protocol UserDefaultsKeys: RawRepresentable where RawValue == String {
    associatedtype Manager: UserDefaultsManager
    init(keyPath: PartialKeyPath<Manager>)
}

public protocol UserDefaultsManager {
    associatedtype Keys: UserDefaultsKeys where Keys.Manager == Self
    var userDefaults: UserDefaults { get }
    mutating func update<T: Codable>(_ value: KeyPath<Self, T>, newValue: T)
    mutating func update<T: Codable>(_ value: KeyPath<Self, T>, process: (inout T) -> Void)
}

public extension UserDefaultsManager {
    mutating func update<T: Codable>(_ value: KeyPath<Self, T>, newValue: T) {
        if let value = value as? WritableKeyPath {
            self[keyPath: value] = newValue
            update(value: value)
        }
    }

    mutating func update<T: Codable>(_ value: KeyPath<Self, T>, process: (inout T) -> Void) {
        if let value = value as? WritableKeyPath {
            process(&self[keyPath: value])
            update(value: value)
        }
    }
}

public extension UserDefaultsManager {
    mutating func update(value: WritableKeyPath<Self, some Codable>) {
        do {
            let data = try JSONEncoder().encode(self[keyPath: value])
            let key = Keys(keyPath: value)
            userDefaults.set(data, forKey: key.rawValue)
        } catch {
            debug(error)
        }
    }

    static func load<T: StaticInitialValueAvailable>(key: Keys, userDefaults: UserDefaults) -> T {
        if let value = userDefaults.data(forKey: key.rawValue) {
            do {
                let value = try JSONDecoder().decode(T.self, from: value)
                return value
            } catch {
                debug(error)
            }
        }
        return T.initialValue
    }
}

public protocol StaticInitialValueAvailable: Codable {
    static var initialValue: Self {get}
}
