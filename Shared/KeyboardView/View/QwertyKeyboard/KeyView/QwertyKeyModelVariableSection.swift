//
//  QwertyKeyModelVariableSection.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum QwertyKeyPressState {
    case unpressed
    case started(Date)
    case longPressed
    case variations

    var isActive: Bool {
        switch self {
        case .unpressed:
            return false
        default:
            return true
        }
    }

    var needVariationsView: Bool {
        switch self {
        case .variations:
            return true
        default:
            return false
        }
    }

}

final class QwertyKeyModelVariableSection: ObservableObject {
    @Published var pressState: QwertyKeyPressState = .unpressed
}
