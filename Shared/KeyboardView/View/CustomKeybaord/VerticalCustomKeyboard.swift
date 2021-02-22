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

fileprivate extension CustardInterfaceLayoutScrollValue{
    var scrollDirection: Axis.Set {
        switch self.direction {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
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
        case let .gridScroll(value):
            switch value.direction{
            case .vertical:
                return TabDependentDesign(width: CGFloat(value.columnKeyCount), height: CGFloat(value.screenRowKeyCount), layout: key_style.keyboardLayout, orientation: VariableStates.shared.keyboardOrientation)
            case .horizontal:
                return TabDependentDesign(width: CGFloat(value.screenRowKeyCount), height: CGFloat(value.columnKeyCount), layout: key_style.keyboardLayout, orientation: VariableStates.shared.keyboardOrientation)
            }
        }
    }

    var flickKeyModels: [CustardKeyCoordinator: FlickKeyModelProtocol] {
        self.keys.mapValues{
            $0.flickKeyModel
        }
    }

    var qwertyKeyModels: [CustardKeyCoordinator: QwertyKeyModelProtocol] {
        self.keys.mapValues{
            $0.qwertyKeyModel(layout: self.key_layout)
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
            case .enter:
                return FlickEnterKeyModel(keySizeType: .normal)
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

    func qwertyKeyModel(layout: CustardInterfaceLayout) -> QwertyKeyModelProtocol {
        let horizontalKeyCount: Int
        switch layout{
        case let .gridFit(value):
            horizontalKeyCount = value.width
        case let .gridScroll(value):
            horizontalKeyCount = value.columnKeyCount
        }

        switch self {
        case let .system(value):
            switch value {
            case .change_keyboard:
                return QwertyChangeKeyboardKeyModel(keySizeType: .normal(of: 1, for: 1))
            case .enter:
                return QwertyEnterKeyModel(keySizeType: .normal(of: 1, for: 1))
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

    var simpleKeyModel: SimpleKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value{
            case .change_keyboard:
                return SimpleChangeKeyboardKeyModel()
            case .enter:
                return SimpleEnterKeyModel()
            }
        case let .custom(value):
            return SimpleKeyModel(
                keyType: .normal,
                keyLabelType: value.label.keyLabelType,
                pressActions: value.press_action.map{$0.actionType},
                longPressActions: value.longpress_action.map{$0.longpressActionType}
            )
        }
    }
}

struct CustomKeyboardView: View {
    @ObservedObject private var variableStates = VariableStates.shared
    @State private var allowHitTesting = true
    private let theme: ThemeData
    private let custard: Custard
    private let tabDesign: TabDependentDesign

    init(theme: ThemeData, custard: Custard){
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
                    HStack(spacing: tabDesign.horizontalSpacing){
                        ForEach(0..<value.width, id: \.self){x in
                            VStack(spacing: tabDesign.verticalSpacing){
                                ForEach(0..<value.height, id: \.self){y in
                                    if let model = models[.grid(GridFitCoordinator(x: x, y: y))]{
                                        FlickKeyView(model: model, theme: theme, tabDesign: tabDesign)
                                    }
                                }
                            }
                        }
                    }
                    HStack(spacing: tabDesign.horizontalSpacing){
                        ForEach(0..<value.width, id: \.self){x in
                            VStack(spacing: tabDesign.verticalSpacing){
                                ForEach(0..<value.height, id: \.self){y in
                                    if let model = models[.grid(GridFitCoordinator(x: x, y: y))]{
                                        SuggestView(model: model.suggestModel, theme: theme, tabDesign: tabDesign)
                                    }
                                }
                            }
                        }
                    }
                }
            case .qwerty:
                let models = custard.interface.qwertyKeyModels
                VStack(spacing: tabDesign.verticalSpacing){
                    ForEach(0..<value.height, id: \.self){y in
                        HStack(spacing: tabDesign.horizontalSpacing){
                            ForEach(0..<value.width, id: \.self){x in
                                if let model = models[.grid(GridFitCoordinator(x: x, y: y))]{
                                    QwertyKeyView(model: model, theme: theme, tabDesign: tabDesign)
                                }
                            }
                        }
                    }
                }
            }
        case let .gridScroll(value):
            //FIXME: 未実装
            let height = Design.shared.keyboardHeight - (Design.shared.resultViewHeight + 12)
            let models = (0..<custard.interface.keys.count).compactMap{custard.interface.keys[.scroll(GridScrollCoordinator($0))]}
            switch value.direction{
            case .vertical:
                let gridItem = GridItem(.fixed(tabDesign.keyViewWidth))
                ScrollView(.vertical){
                    LazyVGrid(columns: Array(repeating: gridItem, count: value.columnKeyCount), spacing: tabDesign.verticalSpacing){
                        ForEach(0..<models.count){i in
                            SimpleKeyView(model: models[i].simpleKeyModel, theme: theme, tabDesign: tabDesign)
                        }
                    }
                }.frame(height: height)
            case .horizontal:
                let gridItem = GridItem(.fixed(tabDesign.keyViewHeight))
                ScrollView(.horizontal){
                    LazyHGrid(rows: Array(repeating: gridItem, count: value.columnKeyCount), spacing: tabDesign.horizontalSpacing){
                        ForEach(0..<models.count){i in
                            SimpleKeyView(model: models[i].simpleKeyModel, theme: theme, tabDesign: tabDesign)
                        }
                    }
                }.frame(height: height)
            }
        }
    }
}
