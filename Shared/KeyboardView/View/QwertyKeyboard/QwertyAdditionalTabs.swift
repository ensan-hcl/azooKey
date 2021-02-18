//
//  QwertyAdditionalTabs.swift
//  Keyboard
//
//  Created by β α on 2020/10/13.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
enum QwertyAdditionalTabs{
    case symbols
    var identifier: String {
        switch self {
        case .symbols:
            return "symbols"
        }
    }
}
