//
//  KeyFlickSetting.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

struct KeyFlickSetting: Savable {
    typealias SaveValue = [String: String]
    var saveValue: [String: String] {
        return [
            "identifier":targetKeyIdentifier,
            "left":left,
            "top":top,
            "right":right,
            "bottom":bottom
        ]
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
    
    static func get(_ value: Any) -> KeyFlickSetting? {
        if let dict = value as? SaveValue{
            if let identifier = dict["identifier"],
               let left = dict["left"],
               let top = dict["top"],
               let right = dict["right"],
               let bottom = dict["bottom"]{
                return KeyFlickSetting(targetKeyIdentifier: identifier, left: left, top: top, right: right, bottom: bottom)
            }
        }
        return nil
    }
}
