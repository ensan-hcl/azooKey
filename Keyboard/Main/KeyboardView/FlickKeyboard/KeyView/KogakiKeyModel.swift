//
//  KogakiKeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/10/04.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
struct KogakiKeyModel: FlickKeyModelProtocol{
    let needSuggestView: Bool = true
    
    static let shared = KogakiKeyModel(labelType:.text("小ﾞﾟ"))

    var pressActions: [ActionType]{ [.changeCharacterType] }
    var longPressActions: [KeyLongPressActionType] = []
    var variableSection: KeyModelVariableSection = KeyModelVariableSection()

    var labelType: KeyLabelType
    var flickKeys: [FlickDirection: FlickedKeyModel] {
        return Store.shared.userSetting.kogakiFlickSetting
    }
    
    var suggestModel: SuggestModel = SuggestModel(keyType: .kogaki)

    
    init(labelType: KeyLabelType){
        self.labelType = labelType
    }

    var label: KeyLabel {
        return KeyLabel(self.labelType, width: keySize.width)
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
        SoundTools.tabOrOtherKey()
    }
}
