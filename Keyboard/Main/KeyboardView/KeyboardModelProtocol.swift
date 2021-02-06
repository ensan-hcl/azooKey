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
    var tabState: TabState {get}
}
