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
    case none
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
