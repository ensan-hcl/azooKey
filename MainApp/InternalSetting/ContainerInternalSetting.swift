//
//  KeyboardInternalSetting.swift
//  azooKey
//
//  Created by ensan on 2021/03/12.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUtils

struct ContainerInternalSetting: UserDefaultsManager {
    static var shared = Self()

    enum Keys: String, UserDefaultsKeys {
        typealias Manager = ContainerInternalSetting
        case walkthrough_state

        init(keyPath: PartialKeyPath<Manager>) {
            switch keyPath {
            case \Manager.walkthroughState:
                self = .walkthrough_state
            default:
                fatalError("Unknown Key Path: \(keyPath)")
            }
        }
    }

    private(set) var walkthroughState: WalkthroughInformation = Self.load(key: .walkthrough_state)
}
