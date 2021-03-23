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
        case .tenkeyStyle:
            return .flick
        case .pcStyle:
            return .qwerty
        }
    }
}

fileprivate extension CustardInterface{
    var tabDesign: TabDependentDesign {
        switch self.keyLayout{
        case let .gridFit(value):
            return TabDependentDesign(width: value.rowCount, height: value.columnCount, layout: keyStyle.keyboardLayout, orientation: VariableStates.shared.keyboardOrientation)
        case let .gridScroll(value):
            switch value.direction{
            case .vertical:
                return TabDependentDesign(width: CGFloat(Int(value.rowCount)), height: CGFloat(value.columnCount), layout: .flick, orientation: VariableStates.shared.keyboardOrientation)
            case .horizontal:
                return TabDependentDesign(width: CGFloat(value.rowCount), height: CGFloat(Int(value.columnCount)), layout: .flick, orientation: VariableStates.shared.keyboardOrientation)
            }
        }
    }

    enum KeyPosition: Hashable {
        case gridFit(x: Int, y: Int)
        case gridScroll(index: Int)
    }

    var flickKeyModels: [KeyPosition: (model: FlickKeyModelProtocol, width: Int, height: Int)] {
        return self.keys.reduce(into: [:]){dictionary, value in
            switch value.key{
            case let .gridFit(data):
                dictionary[.gridFit(x: data.x, y: data.y)] = (value.value.flickKeyModel, data.width, data.height)
            case let .gridScroll(data):
                dictionary[.gridScroll(index: data.index)] = (value.value.flickKeyModel, 1, 1)
            }
        }
    }

    var qwertyKeyModels: [KeyPosition: (model: QwertyKeyModelProtocol, sizeType: QwertyKeySizeType)] {
        return self.keys.reduce(into: [:]){dictionary, value in
            switch value.key{
            case let .gridFit(data):
                dictionary[.gridFit(x: data.x, y: data.y)] = (value.value.qwertyKeyModel(layout: self.keyLayout), .unit(width: data.width, height: data.height))
            case let .gridScroll(data):
                dictionary[.gridScroll(index: data.index)] = (value.value.qwertyKeyModel(layout: self.keyLayout), .unit(width: 1, height: 1))
            }
        }
    }
}

fileprivate extension CustardKeyDesign.ColorType{
    var flickKeyColorType: FlickKeyColorType {
        switch self{
        case .normal:
            return .normal
        case .special:
            return .tabkey
        case .selected:
            return .selected
        }
    }

    var qwertyKeyColorType: QwertyUnpressedKeyColorType {
        switch self{
        case .normal:
            return .normal
        case .special:
            return .special
        case .selected:
            return .selected
        }
    }

    var simpleKeyColorType: SimpleUnpressedKeyColorType {
        switch self{
        case .normal:
            return .normal
        case .special:
            return .special
        case .selected:
            return .selected
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
                return FlickEnterKeyModel()
            case .flick_kogaki:
                return FlickKogakiKeyModel.shared
            case .flick_kutoten:
                return FlickKanaSymbolsKeyModel.shared
            case .flick_hira_tab:
                return FlickTabKeyModel.hiraTabKeyModel
            case .flick_abc_tab:
                return FlickTabKeyModel.abcTabKeyModel
            case .flick_star123_tab:
                return FlickTabKeyModel.numberTabKeyModel
            }
        case let .custom(value):
            let flickKeyModels: [FlickDirection: FlickedKeyModel] = value.variations.reduce(into: [:]){dictionary, variation in
                switch variation.type{
                case let .flickVariation(direction):
                    dictionary[direction] = FlickedKeyModel(
                        labelType: variation.key.design.label.keyLabelType,
                        pressActions: variation.key.press_actions.map{$0.actionType},
                        longPressActions: variation.key.longpress_actions.longpressActionType
                    )
                case .longpressVariation:
                    break
                }
            }
            let model = FlickKeyModel(
                labelType: value.design.label.keyLabelType,
                pressActions: value.press_actions.map{$0.actionType},
                longPressActions: value.longpress_actions.longpressActionType,
                flickKeys: flickKeyModels,
                needSuggestView: value.longpress_actions == .none && !value.variations.isEmpty,
                keycolorType: value.design.color.flickKeyColorType
            )
            return model
        }
    }

    private func convertToQwertyKeyModel(model: FlickKeyModelProtocol) -> QwertyKeyModelProtocol {
        let variations = VariationsModel([model.flickKeys[.left], model.flickKeys[.top], model.flickKeys[.right], model.flickKeys[.bottom]].compactMap{$0}.map{(label: $0.labelType, actions: $0.pressActions)})
        return QwertyKeyModel(labelType: .text("小ﾞﾟ"), pressActions: [.changeCharacterType], longPressActions: .none, variationsModel: variations, keyColorType: .normal, needSuggestView: false, for: (1, 1))
    }

    func qwertyKeyModel(layout: CustardInterfaceLayout) -> QwertyKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value {
            case .change_keyboard:
                let changeKeyboardKey: QwertyChangeKeyboardKeyModel
                if let second = SettingData.shared.preferredLanguageSetting.second{
                    changeKeyboardKey = .init(keySizeType: .normal(of: 1, for: 1), fallBackType: .secondTab(secondLanguage: second))
                }else{
                    changeKeyboardKey = .init(keySizeType: .normal(of: 1, for: 1), fallBackType: .tabBar)
                }
                return changeKeyboardKey
            case .enter:
                return QwertyEnterKeyModel(keySizeType: .enter)
            case .flick_kogaki:
                return  convertToQwertyKeyModel(model: FlickKogakiKeyModel.shared)
            case .flick_kutoten:
                return convertToQwertyKeyModel(model: FlickKanaSymbolsKeyModel.shared)
            case .flick_hira_tab:
                return convertToQwertyKeyModel(model: FlickTabKeyModel.hiraTabKeyModel)
            case .flick_abc_tab:
                return convertToQwertyKeyModel(model: FlickTabKeyModel.abcTabKeyModel)
            case .flick_star123_tab:
                return convertToQwertyKeyModel(model: FlickTabKeyModel.numberTabKeyModel)
            }
        case let .custom(value):
            let variations: [(label: KeyLabelType, actions: [ActionType])] = value.variations.reduce(into: []){array, variation in
                switch variation.type{
                case .flickVariation:
                    break
                case .longpressVariation:
                    array.append((variation.key.design.label.keyLabelType, variation.key.press_actions.map{$0.actionType}))
                }
            }

            let model = QwertyKeyModel(
                labelType: value.design.label.keyLabelType,
                pressActions: value.press_actions.map{$0.actionType},
                longPressActions: value.longpress_actions.longpressActionType,
                variationsModel: VariationsModel(variations),
                keyColorType: value.design.color.qwertyKeyColorType,
                needSuggestView: value.longpress_actions == .none,
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
            case .flick_kogaki:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("小ﾞﾟ"), unpressedKeyColorType: .special, pressActions: [.changeCharacterType])
            case .flick_kutoten:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("、"), unpressedKeyColorType: .normal, pressActions: [.input("、")])
            case .flick_hira_tab:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("あいう"), unpressedKeyColorType: .special, pressActions: [.moveTab(.user_dependent(.japanese))])
            case .flick_abc_tab:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("abc"), unpressedKeyColorType: .special, pressActions: [.moveTab(.user_dependent(.english))])
            case .flick_star123_tab:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("☆123"), unpressedKeyColorType: .special, pressActions: [.moveTab(.existential(.flick_numbersymbols))])
            }
        case let .custom(value):
            return SimpleKeyModel(
                keyType: .normal,
                keyLabelType: value.design.label.keyLabelType,
                unpressedKeyColorType: value.design.color.simpleKeyColorType,
                pressActions: value.press_actions.map{$0.actionType},
                longPressActions: value.longpress_actions.longpressActionType
            )
        }
    }
}

struct CustomKeyboardView: View {
    @ObservedObject private var variableStates = VariableStates.shared
    @Environment(\.themeEnvironment) private var theme
    @State private var allowHitTesting = true
    private let custard: Custard
    private let tabDesign: TabDependentDesign

    init(custard: Custard){
        self.custard = custard
        self.tabDesign = custard.interface.tabDesign
    }

    private func flickKeyData(x: Int, y: Int, width: Int, height: Int) -> (position: CGPoint, size: CGSize) {
        let width = tabDesign.keyViewWidth(widthCount: width)
        let height = tabDesign.keyViewHeight(heightCount: height)
        let dx = width * 0.5 + tabDesign.keyViewWidth * CGFloat(x) + tabDesign.horizontalSpacing * CGFloat(x)
        let dy = height * 0.5 + tabDesign.keyViewHeight * CGFloat(y) + tabDesign.verticalSpacing * CGFloat(y)
        return (CGPoint(x: dx, y: dy), CGSize(width: width, height: height))
    }

    private func qwertyKeyData(x: Int, y: Int, size: QwertyKeySizeType) -> (position: CGPoint, size: CGSize) {
        let width = size.width(design: tabDesign)
        let height = size.height(design: tabDesign)
        let dx = width * 0.5 + tabDesign.keyViewWidth * CGFloat(x) + tabDesign.horizontalSpacing * CGFloat(x)
        let dy = height * 0.5 + tabDesign.keyViewHeight * CGFloat(y) + tabDesign.verticalSpacing * CGFloat(y)
        return (CGPoint(x: dx, y: dy), CGSize(width: width, height: height))
    }

    var body: some View {
        switch custard.interface.keyLayout{
        case let .gridFit(value):
            switch custard.interface.keyStyle{
            case .tenkeyStyle:
                let models = custard.interface.flickKeyModels
                ZStack{
                    ForEach(0..<value.rowCount, id: \.self){x in
                        ForEach(0..<value.columnCount, id: \.self){y in
                            if let data = models[.gridFit(x: x, y: y)]{
                                let info = flickKeyData(x: x, y: y, width: data.width, height: data.height)
                                FlickKeyView(model: data.model, size: info.size)
                                    .position(x: info.position.x, y: info.position.y)
                            }
                        }
                    }.frame(width: tabDesign.keysWidth, height: tabDesign.keysHeight)
                    ForEach(0..<value.rowCount, id: \.self){x in
                        ForEach(0..<value.columnCount, id: \.self){y in
                            if let data = models[.gridFit(x: x, y: y)]{
                                let info = flickKeyData(x: x, y: y, width: data.width, height: data.height)
                                SuggestView(model: data.model.suggestModel, tabDesign: tabDesign, size: info.size)
                                    .position(x: info.position.x, y: info.position.y)
                            }
                        }
                    }.frame(width: tabDesign.keysWidth, height: tabDesign.keysHeight)
                }
            case .pcStyle:
                let models = custard.interface.qwertyKeyModels
                ZStack{
                    ForEach(0..<value.columnCount, id: \.self){y in
                        ForEach(0..<value.rowCount, id: \.self){x in
                            if let data = models[.gridFit(x: x, y: y)]{
                                let info = qwertyKeyData(x: x, y: y, size: data.sizeType)
                                QwertyKeyView(model: data.model, tabDesign: tabDesign, size: info.size)
                                    .position(x: info.position.x, y: info.position.y)
                            }
                        }
                    }.frame(width: tabDesign.keysWidth, height: tabDesign.keysHeight)
                }
            /*
             VStack(spacing: tabDesign.verticalSpacing){
             ForEach(0..<value.columnCount, id: \.self){y in
             HStack(spacing: tabDesign.horizontalSpacing){
             ForEach(0..<value.rowCount, id: \.self){x in
             if let model = models[.gridFit(GridFitPositionSpecifier(x: x, y: y))]{
             QwertyKeyView(model: model, tabDesign: tabDesign)
             }
             }
             }
             }
             }
             */
            }
        case let .gridScroll(value):
            let height = tabDesign.keysHeight
            let models = (0..<custard.interface.keys.count).compactMap{custard.interface.keys[.gridScroll(GridScrollPositionSpecifier($0))]}
            switch value.direction{
            case .vertical:
                let gridItem = GridItem(.fixed(tabDesign.keyViewWidth), spacing: tabDesign.horizontalSpacing/2)
                ScrollView(.vertical){
                    LazyVGrid(columns: Array(repeating: gridItem, count: Int(value.rowCount)), spacing: tabDesign.verticalSpacing/2){
                        ForEach(0..<models.count, id: \.self){i in
                            SimpleKeyView(model: models[i].simpleKeyModel, tabDesign: tabDesign)
                        }
                    }
                }.frame(height: height)
            case .horizontal:
                let gridItem = GridItem(.fixed(tabDesign.keyViewHeight), spacing: tabDesign.verticalSpacing/2)
                ScrollView(.horizontal){
                    LazyHGrid(rows: Array(repeating: gridItem, count: Int(value.columnCount)), spacing: tabDesign.horizontalSpacing/2){
                        ForEach(0..<models.count, id: \.self){i in
                            SimpleKeyView(model: models[i].simpleKeyModel, tabDesign: tabDesign)
                        }
                    }
                }.frame(height: height)
            }
        }
    }
}
