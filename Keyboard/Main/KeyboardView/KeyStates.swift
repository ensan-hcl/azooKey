//
//  States.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum EnterKeyState{
    case complete   //決定
    case `return`(UIReturnKeyType)   //改行
    case edit       //編集
}

enum AaKeyState{
    case normal
    case capslock
}
