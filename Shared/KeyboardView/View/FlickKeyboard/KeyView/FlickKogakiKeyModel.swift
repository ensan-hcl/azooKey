//
//  KogakiKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/10/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
struct FlickKogakiKeyModel: FlickKeyModelProtocol{
    let needSuggestView: Bool = true
    
    static let shared = FlickKogakiKeyModel()

    let pressActions: [ActionType] = [.changeCharacterType]
    var longPressActions: [LongPressActionType] = []

    let labelType: KeyLabelType = .text("小ﾞﾟ")

    var flickKeys: [FlickDirection: FlickedKeyModel] {
        SettingData.shared.flickCustomKeySetting(for: .koganaKeyFlick).flick
    }
    
    var suggestModel: SuggestModel = SuggestModel(keyType: .custom(.koganaKeyFlick))

    
    private init(){}

    func label(width: CGFloat, states: VariableStates) -> KeyLabel {
        KeyLabel(self.labelType, width: width)
    }

    func flickSensitivity(to direction: FlickDirection) -> CGFloat {
        switch direction{
        case .left, .bottom:
            return 25
        case .top:
            return 50
        case .right:
            return 70
        }
    }

    func sound() {
        Sound.tabOrOtherKey()
    }
}
