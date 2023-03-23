//
//  SuggestModel.swift
//  Keyboard
//
//  Created by ensan on 2020/09/05.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

enum SuggestModelKeyType {
    case normal
    case enter(Int)
    case custom(CustomizableFlickKey)
    case aA
    case changeKeyboard
}

struct SuggestModel {
    private let keyType: SuggestModelKeyType
    private let _flickModels: [FlickDirection: FlickedKeyModel]
    var flickModels: [FlickDirection: FlickedKeyModel] {
        switch self.keyType {
        case .normal, .enter:
            return _flickModels
        case let .custom(setting):
            return setting.get().flick
        case .aA:
            return FlickAaKeyModel.shared.flickKeys
        case .changeKeyboard:
            return FlickChangeKeyboardModel.shared.flickKeys
        }
    }

    init(_ flickModels: [FlickDirection: FlickedKeyModel] = [:], keyType: SuggestModelKeyType = .normal) {
        self._flickModels = flickModels
        self.keyType = keyType
    }
}
