//
//  EnvironmentValue.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum KeyboardLayout: String, CaseIterable {
    /// フリック入力式のレイアウトで表示するスタイル
    case flick = "flick"
    /// qwerty入力式のレイアウトで表示するスタイル
    case qwerty = "roman"
}

extension KeyboardLayout: Savable {
    typealias SaveValue = String
    var saveValue: String {
        return self.rawValue
    }

    static func get(_ value: Any) -> KeyboardLayout? {
        if let string = value as? String {
            return self.init(rawValue: string)
        }
        return nil
    }
}

enum InputStyle: String {
    /// 入力された文字を直接入力するスタイル
    case direct = "direct"
    /// ローマ字日本語入力とするスタイル
    case roman2kana = "roman"
}

enum KeyboardLanguage: String, Codable {
    case en_US
    case ja_JP
    case el_GR
    case none

    var symbol: String {
        switch self {
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

enum ResizingState {
    case fullwidth // 両手モードの利用
    case onehanded // 片手モードの利用
    case resizing  // 編集モード
}

enum KeyboardOrientation {
    case vertical       // width<height
    case horizontal     // height<width
}

enum EnterKeyState {
    case complete   // 決定
    case `return`(UIReturnKeyType)   // 改行
    case edit       // 編集
}

enum AaKeyState {
    case normal
    case capsLock
}

/// 実行しないと値が確定しないが、実行されれば全く変更されない値。収容アプリでも共有できる形にすること。
final class SemiStaticStates {
    static let shared = SemiStaticStates()
    private init() {}

    private(set) var needsInputModeSwitchKey = true // 端末が変化しない限り変更が必要ない
    func setNeedsInputModeSwitchKeyMode(_ bool: Bool) {
        self.needsInputModeSwitchKey = bool
    }

    /// - do not  consider using screenHeight
    private(set) var screenWidth: CGFloat = .zero
    private(set) var screenHeight: CGFloat = .zero
    func setScreenSize(size: CGSize) {
        if self.screenWidth == size.width {
            return
        }
        VariableStates.shared.setOrientation(size.width<size.height ? .vertical : .horizontal)
        let width = size.width
        let height = Design.shared.keyboardHeight(screenWidth: width)
        self.screenWidth = width
        self.screenHeight = height
        let (layout, orientation) = (layout: VariableStates.shared.keyboardLayout, orientation: VariableStates.shared.keyboardOrientation)
        KeyboardInternalSetting.shared.update(\.oneHandedModeSetting) {value in
            value.setIfFirst(layout: layout, orientation: orientation, size: .init(width: width, height: height), position: .zero)
        }
        switch VariableStates.shared.resizingState {
        case .fullwidth:
            VariableStates.shared.interfaceSize = CGSize(width: width, height: height)
        case .onehanded, .resizing:
            let item = KeyboardInternalSetting.shared.oneHandedModeSetting.item(layout: layout, orientation: orientation)
            VariableStates.shared.interfaceSize = item.size
            VariableStates.shared.interfacePosition = item.position
        }
    }
}
