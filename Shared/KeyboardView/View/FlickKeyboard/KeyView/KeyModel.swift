//
//  KeyModel.swift
//  Keyboard
//
//  Created by β α on 2020/04/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

// M：基本は変わらない
struct FlickKeyModel: FlickKeyModelProtocol {
    var variableSection = KeyModelVariableSection()

    var suggestModel: SuggestModelProtocol
    let needSuggestView: Bool
    let flickKeys: [FlickDirection: FlickedKeyModel]

    // これら3つの値は内部からしか参照していない
    let labelType: KeyLabelType
    let pressActions: [KeyPressActionType]
    let longPressActions: [KeyLongPressActionType]

    init(labelType: KeyLabelType, pressActions: [KeyPressActionType], longPressActions: [KeyLongPressActionType], flickKeys: [FlickDirection: FlickedKeyModel], needSuggestView: Bool = true) {
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
        self.flickKeys = flickKeys
        self.needSuggestView = needSuggestView

        self.suggestModel = SuggestModel(flickModels: flickKeys)
    }

    func getLabel() -> AnyView {
        switch self.labelType {
        case let .text(string):
            return AnyView(Text(string).font(Store.shared.designDepartment.keyLabelFont))
        case let .image(fileName):
            return AnyView(Image(systemName: fileName).font(Store.shared.designDepartment.iconImageFont))
        case let .customImage(fileName):
            return AnyView(Image(fileName).resizable().frame(width: 30, height: 30, alignment: .leading))
        }
    }

}
