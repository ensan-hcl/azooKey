//
//  KeyFlickSetting.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum CustomizableFlickKey: String, Codable{
    case kogana = "kogana"
    case kanaSymbols = "kana_symbols"

    var identifier: String {
        return self.rawValue
    }

    var defaultSetting: KeyFlickSetting {
        switch self{
        case .kogana:
            return KeyFlickSetting(
                identifier: self,
                center: FlickCustomKey(input: "", label: "小ﾞﾟ"),
                left: FlickCustomKey(input: "", label: ""),
                top: FlickCustomKey(input: "", label: ""),
                right: FlickCustomKey(input: "", label: ""),
                bottom: FlickCustomKey(input: "", label: "")
            )
        case .kanaSymbols:
            return KeyFlickSetting(
                identifier: self,
                center: FlickCustomKey(input: "、", label: "､｡?!"),
                left: FlickCustomKey(input: "。", label: "。"),
                top: FlickCustomKey(input: "？", label: "？"),
                right: FlickCustomKey(input: "！", label: "！"),
                bottom: FlickCustomKey(input: "", label: "")
            )
        }
    }

    var ablePosition: [FlickKeyPosition] {
        switch self {
        case .kogana:
            return [.left, .top, .right]
        case .kanaSymbols:
            return [.center, .left, .top, .right]
        }
    }

    var defaultInput: [FlickKeyPosition: String] {
        switch self {
        case .kogana:
            return [
                .left: "",
                .top: "",
                .right: "",
                .bottom: "",
                .center: "",
            ]
        case .kanaSymbols:
            return [
                .left: "。",
                .top: "？",
                .right: "！",
                .bottom: "",
                .center: "、",
            ]
        }

    }

    var defaultLabel: [FlickKeyPosition: String] {
        switch self {
        case .kogana:
            return [
                .left: "",
                .top: "",
                .right: "",
                .bottom: "",
                .center: "小ﾞﾟ",
            ]
        case .kanaSymbols:
            return [
                .left: "。",
                .top: "？",
                .right: "！",
                .bottom: "",
                .center: "､｡?!",
            ]
        }
    }
}

enum FlickKeyPosition: String, Codable{
    case left = "left"
    case top = "top"
    case right = "right"
    case bottom = "bottom"
    case center = "center"
}

struct FlickCustomKey: Codable{
    var input: String
    var label: String
}

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

    enum CodingKeys: String, CodingKey {
        case targetKeyIdentifier

        case left
        case top
        case right
        case bottom
        case center
        case identifier
    }


    let targetKeyIdentifier: String //レガシー
    var left: FlickCustomKey
    var top: FlickCustomKey
    var right: FlickCustomKey
    var bottom: FlickCustomKey
    var center: FlickCustomKey

    let identifier: CustomizableFlickKey
    
    init(targetKeyIdentifier: String, left: String = "", top: String = "", right: String = "", bottom: String = "", center: String = "") {
        self.identifier = CustomizableFlickKey(rawValue: targetKeyIdentifier) ?? .kogana
        self.left = FlickCustomKey(input: left, label: left)
        self.top = FlickCustomKey(input: top, label: top)
        self.right = FlickCustomKey(input: right, label: right)
        self.bottom = FlickCustomKey(input: bottom, label: bottom)
        self.center = FlickCustomKey(input: "", label: "")
        //レガシー
        self.targetKeyIdentifier = self.identifier.identifier
    }

    init(identifier: CustomizableFlickKey, center: FlickCustomKey, left: FlickCustomKey, top: FlickCustomKey, right: FlickCustomKey, bottom: FlickCustomKey){
        self.identifier = identifier
        self.center = center
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom

        self.targetKeyIdentifier = identifier.rawValue
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let targetKeyIdentifier = try? values.decode(String.self, forKey: .targetKeyIdentifier),
           let left = try? values.decode(String.self, forKey: .left),
           let top = try? values.decode(String.self, forKey: .top),
           let right = try? values.decode(String.self, forKey: .right),
           let bottom = try? values.decode(String.self, forKey: .bottom){
            self.targetKeyIdentifier = targetKeyIdentifier
            self.identifier = CustomizableFlickKey(rawValue: targetKeyIdentifier) ?? .kogana
            self.left = FlickCustomKey(input: left, label: left)
            self.top = FlickCustomKey(input: top, label: top)
            self.right = FlickCustomKey(input: right, label: right)
            self.bottom = FlickCustomKey(input: bottom, label: bottom)
            self.center = FlickCustomKey(input: "", label: "")
            return
        }

        self.identifier = try values.decode(CustomizableFlickKey.self, forKey: .identifier)
        self.left = try values.decode(FlickCustomKey.self, forKey: .left)
        self.top = try values.decode(FlickCustomKey.self, forKey: .top)
        self.right = try values.decode(FlickCustomKey.self, forKey: .right)
        self.bottom = try values.decode(FlickCustomKey.self, forKey: .bottom)
        self.center = try values.decode(FlickCustomKey.self, forKey: .center)

        self.targetKeyIdentifier = identifier.identifier
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

