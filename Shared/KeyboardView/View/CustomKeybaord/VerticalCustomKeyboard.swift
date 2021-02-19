//
//  VerticalCustomKeyboard.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/18.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate extension CustardKeyLabelStyle{
    var keyLabelType: KeyLabelType {
        switch self{
        case let .text(value):
            return .text(value)
        case let .systemImage(value):
            return .image(value)
        }
    }
}

fileprivate extension CustardKeyAction{
    var actionType: ActionType {
        switch self{
        case let .input(value):
            return .input(value)
        case .exchangeCharacter:
            return .changeCharacterType
        case let .delete(value):
            return .delete(value)
        case .smoothDelete:
            return .smoothDelete
        case .enter:
            return .enter
        case let .moveCursor(value):
            return .moveCursor(value)
        case let .moveTab(value):
            return .moveTab(.abc) //FIXME: 誤り
        case .toggleCursorMovingView:
            return .toggleShowMoveCursorView
        case .toggleCapsLockState:
            return .changeCapsLockState(state: .capslock) //FIXME: 誤り
        }
    }

    var longpressActionType: KeyLongPressActionType {
        switch self{
        case let .input(value):
            return .input(value)
        case .delete:
            return .delete
        case let .moveCursor(value):
            return .moveCursor(value < 0 ? .left : .right)
        default:
            return .doOnce(self.actionType)
        }
    }
}

fileprivate extension CustardInterfaceStyle{
    var keyboardLayout: KeyboardLayout {
        switch self{
        case .flick:
            return .flick
        case .qwerty:
            return .qwerty
        }
    }
}

fileprivate extension CustardInterface{
    var tabDesign: TabDependentDesign {
        switch self.key_layout{
        case let .gridFit(value):
            return TabDependentDesign(width: value.width, height: value.height, layout: key_style.keyboardLayout, orientation: VariableStates.shared.keyboardOrientation)
        case let .scrollFit(value):
            //FIXME: 未実装
            return TabDependentDesign(width: 5, height: 5, layout: key_style.keyboardLayout, orientation: VariableStates.shared.keyboardOrientation)
        }
    }

    var flickKeyModels: [CustardKeyCoordinator: FlickKeyModelProtocol] {
        self.keys.mapValues{
            $0.flickKeyModel
        }
    }

    var qwertyKeyModels: [CustardKeyCoordinator: QwertyKeyModelProtocol] {
        self.keys.mapValues{
            $0.qwertyKeyModel
        }
    }
}

fileprivate extension CustardInterfaceKey {
    var flickKeyModel: FlickKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value {
            case .change_keyboard:
                return FlickChangeKeyboardModel.shared
            }
        case let .custom(value):
            let flickKeyModels: [FlickDirection: FlickedKeyModel] = value.variation.reduce(into: [:]){dictionary, variation in
                switch variation.type{
                case let .flick(direction):
                    dictionary[direction] = FlickedKeyModel(
                        labelType: variation.key.label.keyLabelType,
                        pressActions: variation.key.press_action.map{$0.actionType},
                        longPressActions: variation.key.longpress_action.map{$0.longpressActionType}
                    )
                case .variations:
                    break
                }
            }
            let model = FlickKeyModel(
                labelType: value.label.keyLabelType,
                pressActions: value.press_action.map{$0.actionType},
                longPressActions: value.longpress_action.map{$0.longpressActionType},
                flickKeys: flickKeyModels
            )
            return model
        }
    }

    var qwertyKeyModel: QwertyKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value {
            case .change_keyboard:
                return QwertyChangeKeyboardKeyModel(rowInfo: (10,0,0,0))
            }
        case let .custom(value):
            let variations: [(label: KeyLabelType, actions: [ActionType])] = value.variation.reduce(into: []){array, variation in
                switch variation.type{
                case .flick:
                    break
                case .variations:
                    array.append((variation.key.label.keyLabelType, variation.key.press_action.map{$0.actionType}))
                }
            }

            let model = QwertyKeyModel(
                labelType: value.label.keyLabelType,
                pressActions: value.press_action.map{$0.actionType},
                longPressActions: value.longpress_action.map{$0.longpressActionType},
                variationsModel: VariationsModel(variations),
                needSuggestView: true,
                for: (1,1)
            )
            return model
        }
    }

}

struct VerticalCustomKeyboardView: View {
    @ObservedObject private var variableStates = VariableStates.shared
    private let theme: ThemeData
    private let custard: Custard
    private let tabDesign: TabDependentDesign

    init(theme: ThemeData, custard: Custard = .mock){
        self.theme = theme
        self.custard = custard
        self.tabDesign = custard.interface.tabDesign
    }

    var body: some View {
        switch custard.interface.key_layout{
        case let .gridFit(value):
            switch custard.interface.key_style{
            case .flick:
                let models = custard.interface.flickKeyModels
                ZStack{
                    ForEach(0..<value.width, id: \.self){x in
                        ForEach(0..<value.height, id: \.self){y in
                            if let model = models[.grid(GridCoordinator(x: x, y: y))]{
                                FlickKeyView(model: model, theme: theme, tabDesign: tabDesign)
                            }
                        }
                    }
                    ForEach(0..<value.width, id: \.self){x in
                        ForEach(0..<value.height, id: \.self){y in
                            if let model = models[.grid(GridCoordinator(x: x, y: y))]{
                                SuggestView(model: model.suggestModel, theme: theme, tabDesign: tabDesign)
                            }
                        }
                    }
                }
            case .qwerty:
                let models = custard.interface.qwertyKeyModels
                ForEach(0..<value.width, id: \.self){x in
                    ForEach(0..<value.height, id: \.self){y in
                        if let model = models[.grid(GridCoordinator(x: x, y: y))]{
                            QwertyKeyView(model: model, theme: theme, tabDesign: tabDesign)
                        }
                    }
                }
            }
        case let .scrollFit(value):
            //FIXME: 未実装
            ScrollView{
                Text("not implemented")
            }
        }
    }
}
