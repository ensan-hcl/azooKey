//
//  SettingItemProtocol.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

protocol Savable{
    associatedtype SaveValue
    var saveValue: SaveValue {get}
    static func get(_ value: Any) -> Self?
}

extension Savable{
    static func get(_ value: Any) -> Self? {
        return value as? Self
    }
}

extension Bool: Savable {
    typealias SaveValue = Bool
    var saveValue: Bool{
        return self
    }
}


struct SettingItem <Value: Savable> {
    ///設定の名前
    var identifier: Setting
    var value: Value
    
    init(identifier: Setting, defaultValue: Value){
        self.identifier = identifier
        let userDefaults = UserDefaults(suiteName: SharedStore.appGroupKey)!
        if let __value = userDefaults.value(forKey: identifier.key), let _value = Value.get(__value){
            self.value = _value
        }else{
            self.value = defaultValue
            userDefaults.setValue(defaultValue.saveValue, forKey: identifier.key)
        }
    }

    var description: LocalizedStringKey {
        identifier.explanation
    }

    func save(_ value: Value){
        let userDefaults = UserDefaults(suiteName: SharedStore.appGroupKey)!
        userDefaults.set(value.saveValue, forKey: identifier.key)
    }
}

final class SettingItemViewModel<Value: Savable>: ObservableObject{
    let item: SettingItem<Value>
    @Published var value: Value{
        didSet {
            self.item.save(value)
        }
    }
    
    init(_ item: SettingItem<Value>){
        self.item = item
        self.value = item.value
    }
}
