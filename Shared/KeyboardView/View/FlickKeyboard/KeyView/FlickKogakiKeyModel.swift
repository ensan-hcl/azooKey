//
//  KogakiKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/10/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
import CustardKit

struct FlickKogakiKeyModel: FlickKeyModelProtocol {
    let needSuggestView: Bool = true

    static let shared = FlickKogakiKeyModel()

    let pressActions: [ActionType] = [.changeCharacterType]
    var longPressActions: LongpressActionType = .none

    let labelType: KeyLabelType = .text("小ﾞﾟ")

    @KeyboardSetting(.koganaFlickCustomKey) private var customKey
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        customKey.compiled().flick
    }

    var suggestModel: SuggestModel = SuggestModel(keyType: .custom(.kogana))

    private init() {}

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(self.labelType, width: width)
    }

    func flickSensitivity(to direction: FlickDirection) -> CGFloat {
        @KeyboardSetting<FlickSensitivitySettingKey>(.flickSensitivity) var flickSensitivity
        switch direction {
        case .left, .bottom:
            return 25 / flickSensitivity
        case .top:
            return 50 / flickSensitivity
        case .right:
            return 70 / flickSensitivity
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }
}
