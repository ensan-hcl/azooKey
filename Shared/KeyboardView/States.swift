//
//  EnvironmentValue.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum KeyboardLayout: String, CaseIterable{
    ///フリック入力式のレイアウトで表示するスタイル
    case flick = "flick"
    ///qwerty入力式のレイアウトで表示するスタイル
    case qwerty = "roman"
}

extension KeyboardLayout: Savable {
    typealias SaveValue = String
    var saveValue: String {
        return self.rawValue
    }

    static func get(_ value: Any) -> KeyboardLayout? {
        if let string = value as? String{
            return self.init(rawValue: string)
        }
        return nil
    }
}

enum InputStyle: String{
    ///入力された文字を直接入力するスタイル
    case direct = "direct"
    ///ローマ字日本語入力とするスタイル
    case roman2kana = "roman"
}

enum KeyboardLanguage: String, Codable {
    case en_US
    case ja_JP
    case el_GR
    case none

    var symbol: String{
        switch self{
        case .en_US:
            return "A"
        case .el_GR:
            return "Ω"
        case .ja_JP:
            return "あ"
        case .none:
            return ""
        }
    }
}

enum KeyboardOrientation{
    case vertical       //width<height
    case horizontal     //height<width
}

enum EnterKeyState{
    case complete   //決定
    case `return`(UIReturnKeyType)   //改行
    case edit       //編集
}

enum AaKeyState{
    case normal
    case capslock
}

///実行中変更されない値。収容アプリでも共有できる形にすること。
final class SemiStaticStates{
    static let shared = SemiStaticStates()
    private init(){}

    private(set) var needsInputModeSwitchKey = true //端末が変化しない限り変更が必要ない
    func setNeedsInputModeSwitchKeyMode(_ bool: Bool){
        self.needsInputModeSwitchKey = bool
    }

    /// - do not  consider using screenHeight
    private(set) var screenWidth: CGFloat = .zero
    func setScreenSize(size: CGSize){
        if self.screenWidth == size.width{
            return
        }
        self.screenWidth = size.width
        VariableStates.shared.setOrientation(size.width<size.height ? .vertical : .horizontal)
    }
}
