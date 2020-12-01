//
//  KeyboardType.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/02.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum KeyboardType: String, CaseIterable{
    case flick = "flick"
    case roman = "roman"
    
    var string: String {
        switch self{
        case .flick:
            return "フリック入力"
        case .roman:
            return "ローマ字入力"
        }
    }
    
    var imageName: String {
        switch self{
        case .flick: return "flickKeyboardImage"
        case .roman: return "romanKeyboardImage"
        }
    }

    var id: Int {
        switch self{
        case .flick: return 0
        case .roman: return 1
        }
    }
}

extension KeyboardType: Savable {
    typealias SaveValue = String
    var saveValue: String {
        return self.rawValue
    }
    
    static func get(_ value: Any) -> KeyboardType? {
        if let string = value as? String{
            return self.init(rawValue: string)
        }
        return nil
    }
}
