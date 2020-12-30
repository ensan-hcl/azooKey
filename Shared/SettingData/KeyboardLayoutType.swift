//
//  KeyboardType.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/02.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum InputStyle: String{
    ///常に入力された文字を直接入力するスタイル
    case direct = "direct"
    ///「ひらがな」タブの状態にあるときのみローマ字入力とし、そのほかでは`direct`と同様に動作するスタイル
    case roman = "roman"
}

enum KeyboardLayoutType: String, CaseIterable{
    ///フリック入力式のレイアウトで表示するスタイル
    case flick = "flick"
    ///ローマ字入力式のレイアウトで表示するスタイル
    case roman = "roman"
    
    var string: String {
        switch self{
        case .flick:
            return "フリック入力"
        case .roman:
            return "ローマ字入力"
        }
    }
    
    var id: Int {
        switch self{
        case .flick: return 0
        case .roman: return 1
        }
    }
}

extension KeyboardLayoutType: Savable {
    typealias SaveValue = String
    var saveValue: String {
        return self.rawValue
    }
    
    static func get(_ value: Any) -> KeyboardLayoutType? {
        if let string = value as? String{
            return self.init(rawValue: string)
        }
        return nil
    }
}
