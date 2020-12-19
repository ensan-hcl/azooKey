//
//  KeyFlickSetting.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

struct KeyFlickSetting: Savable, Codable {
    typealias SaveValue = Data
    var saveValue: Data {
        let encoder = JSONEncoder()
        if let encodedValue = try? encoder.encode(self) {
            return encodedValue
        }else{
            return Data()
        }
    }

    let targetKeyIdentifier: String
    var left: String
    var top: String
    var right: String
    var bottom: String
    
    init(targetKeyIdentifier: String, left: String = "", top: String = "", right: String = "", bottom: String = "") {
        self.targetKeyIdentifier = targetKeyIdentifier
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }

    /*
     これに由来する
     var saveValue: [String: String] {
     return [
     "identifier":targetKeyIdentifier,
     "left":left,
     "top":top,
     "right":right,
     "bottom":bottom
     ]
     }*/

    static func get(_ value: Any) -> KeyFlickSetting? {
        if let dict = value as? [String: String]{
            if let identifier = dict["identifier"],
               let left = dict["left"],
               let top = dict["top"],
               let right = dict["right"],
               let bottom = dict["bottom"]{
                return KeyFlickSetting(targetKeyIdentifier: identifier, left: left, top: top, right: right, bottom: bottom)
            }
        }
        if let value = value as? Data{
            let decoder = JSONDecoder()
            if let data = try? decoder.decode(KeyFlickSetting.self, from: value) {
                return data
            }

        }
        return nil
    }
}
