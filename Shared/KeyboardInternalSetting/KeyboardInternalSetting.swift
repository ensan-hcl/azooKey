//
//  KeyboardInternalSetting.swift
//  KanaKanjier
//
//  Created by β α on 2021/03/12.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

private enum UserDefaultKeys: String {
    case one_handed_mode_setting

    init?(keyPath: PartialKeyPath<KeyboardInternalSetting>){
        switch keyPath{
        case \KeyboardInternalSetting.oneHandedModeSetting:
            self = .one_handed_mode_setting
        default:
            return nil
        }
    }

    init?<T>(keyPath: WritableKeyPath<KeyboardInternalSetting, T>){
        let partialKeyPath = keyPath as PartialKeyPath
        self.init(keyPath: partialKeyPath)
    }
}

protocol KeyboardInternalSettingProtocol {
    static var initialValue: Self {get}
}

struct KeyboardInternalSetting{
    static var shared = Self()

    var oneHandedModeSetting: OneHandedModeSetting = Self.load(key: .one_handed_mode_setting)

    mutating func update<T: Codable>(value: WritableKeyPath<Self, T>, newValue: T){
        self[keyPath: value] = newValue
        update(value: value)
    }

    mutating func update<T: Codable>(_ value: WritableKeyPath<Self, T>, process: (inout T) -> ()){
        process(&self[keyPath: value])
        update(value: value)
    }

    private mutating func update<T: Codable>(value: WritableKeyPath<Self, T>){
        do{
            let data = try JSONEncoder().encode(self[keyPath: value])
            if let key = UserDefaultKeys.init(keyPath: value){
                UserDefaults.standard.set(data, forKey: key.rawValue)
            }
        }catch{
            debug(error)
        }
    }

    private static func load<T: Codable&KeyboardInternalSettingProtocol>(key: UserDefaultKeys) -> T {
        if let value = UserDefaults.standard.data(forKey: key.rawValue){
            do{
                let value = try JSONDecoder().decode(T.self, from: value)
                return value
            }catch{
                debug(error)
            }
        }
        return T.initialValue
    }
}
