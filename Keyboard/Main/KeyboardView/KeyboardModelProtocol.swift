//
//  KeyboardModelProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/09/23.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
protocol KeyboardModelProtocol {
    func setTabState(state: TabState)
    var enterKeyModel: EnterKeyModelProtocol {get}
    var aAKeyModel: AaKeyModelProtocol {get}
    var tabState: TabState {get}
}

protocol EnterKeyModelProtocol {
    func setKeyState(new state: EnterKeyState)
}

protocol AaKeyModelProtocol {
    func setKeyState(new state: AaKeyState)
}
