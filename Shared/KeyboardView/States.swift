//
//  EnvironmentValue.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum KeyboardLanguage {
    case english
    case japanese
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

//キーボードの状態管理
enum TabState: Equatable{
    case hira
    case abc
    case number
    case other(String)

    static func ==(lhs: TabState, rhs: TabState) -> Bool {
        switch (lhs, rhs) {
        case (.hira, .hira), (.abc, .abc), (.number, .number): return true
        case let (.other(ls), .other(rs)): return ls == rs
        default:
            return false
        }
    }
}

///実行中変更されない値。収容アプリでも共有できる形にすること。
final class SemiStaticStates{
    static let shared = SemiStaticStates()
    private init(){}

    private(set) var needsInputModeSwitchKey = true //端末が変化しない限り変更が必要ない
    func setNeedsInputModeSwitchKeyMode(_ bool: Bool){
        self.needsInputModeSwitchKey = bool
    }
}
