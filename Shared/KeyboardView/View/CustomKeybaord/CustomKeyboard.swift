//
//  VerticalCustomKeyboard.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/18.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate extension CustardKeyLabelStyle {
    var keyLabelType: KeyLabelType {
        switch self {
        case let .text(value):
            return .text(value)
        case let .systemImage(value):
            return .image(value)
        }
    }
}

fileprivate extension CustardInterfaceLayoutScrollValue {
    var scrollDirection: Axis.Set {
        switch self.direction {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
}

fileprivate extension CustardInterfaceStyle {
    var keyboardLayout: KeyboardLayout {
        switch self {
        case .tenkeyStyle:
            return .flick
        case .pcStyle:
            return .qwerty
        }
    }
}

fileprivate extension CustardInterface {
    func tabDesign(keyboardOrientation: KeyboardOrientation) -> TabDependentDesign {
        switch self.keyLayout {
        case let .gridFit(value):
            return TabDependentDesign(width: value.rowCount, height: value.columnCount, layout: keyStyle.keyboardLayout, orientation: keyboardOrientation)
        case let .gridScroll(value):
            switch value.direction {
            case .vertical:
                return TabDependentDesign(width: CGFloat(Int(value.rowCount)), height: CGFloat(value.columnCount), layout: .flick, orientation: keyboardOrientation)
            case .horizontal:
                return TabDependentDesign(width: CGFloat(value.rowCount), height: CGFloat(Int(value.columnCount)), layout: .flick, orientation: keyboardOrientation)
            }
        }
    }

    var flickKeyModels: [KeyPosition: (model: FlickKeyModelProtocol, width: Int, height: Int)] {
        return self.keys.reduce(into: [:]) {dictionary, value in
            switch value.key {
            case let .gridFit(data):
                dictionary[.gridFit(x: data.x, y: data.y)] = (value.value.flickKeyModel, data.width, data.height)
            case let .gridScroll(data):
                dictionary[.gridScroll(index: data.index)] = (value.value.flickKeyModel, 1, 1)
            }
        }
    }

    var qwertyKeyModels: [KeyPosition: (model: QwertyKeyModelProtocol, sizeType: QwertyKeySizeType)] {
        return self.keys.reduce(into: [:]) {dictionary, value in
            switch value.key {
            case let .gridFit(data):
                dictionary[.gridFit(x: data.x, y: data.y)] = (value.value.qwertyKeyModel(layout: self.keyLayout), .unit(width: data.width, height: data.height))
            case let .gridScroll(data):
                dictionary[.gridScroll(index: data.index)] = (value.value.qwertyKeyModel(layout: self.keyLayout), .unit(width: 1, height: 1))
            }
        }
    }
}

fileprivate extension CustardKeyDesign.ColorType {
    var flickKeyColorType: FlickKeyColorType {
        switch self {
        case .normal:
            return .normal
        case .special:
            return .tabkey
        case .selected:
            return .selected
        }
    }

    var qwertyKeyColorType: QwertyUnpressedKeyColorType {
        switch self {
        case .normal:
            return .normal
        case .special:
            return .special
        case .selected:
            return .selected
        }
    }

    var simpleKeyColorType: SimpleUnpressedKeyColorType {
        switch self {
        case .normal:
            return .normal
        case .special:
            return .special
        case .selected:
            return .selected
        }
    }

}

extension CustardInterfaceKey {
    var flickKeyModel: FlickKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value {
            case .changeKeyboard:
                return FlickChangeKeyboardModel.shared
            case .enter:
                return FlickEnterKeyModel()
            case .flickKogaki:
                return FlickKogakiKeyModel.shared
            case .flickKutoten:
                return FlickKanaSymbolsKeyModel.shared
            case .flickHiraTab:
                return FlickTabKeyModel.hiraTabKeyModel
            case .flickAbcTab:
                return FlickTabKeyModel.abcTabKeyModel
            case .flickStar123Tab:
                return FlickTabKeyModel.numberTabKeyModel
            }
        case let .custom(value):
            let flickKeyModels: [FlickDirection: FlickedKeyModel] = value.variations.reduce(into: [:]) {dictionary, variation in
                switch variation.type {
                case let .flickVariation(direction):
                    dictionary[direction] = FlickedKeyModel(
                        labelType: variation.key.design.label.keyLabelType,
                        pressActions: variation.key.press_actions.map {$0.actionType},
                        longPressActions: variation.key.longpress_actions.longpressActionType
                    )
                case .longpressVariation:
                    break
                }
            }
            let model = FlickKeyModel(
                labelType: value.design.label.keyLabelType,
                pressActions: value.press_actions.map {$0.actionType},
                longPressActions: value.longpress_actions.longpressActionType,
                flickKeys: flickKeyModels,
                needSuggestView: value.longpress_actions == .none && !value.variations.isEmpty,
                keycolorType: value.design.color.flickKeyColorType
            )
            return model
        }
    }

    private func convertToQwertyKeyModel(model: FlickKeyModelProtocol) -> QwertyKeyModelProtocol {
        let variations = VariationsModel([model.flickKeys[.left], model.flickKeys[.top], model.flickKeys[.right], model.flickKeys[.bottom]].compactMap {$0}.map {(label: $0.labelType, actions: $0.pressActions)})
        return QwertyKeyModel(labelType: .text("小ﾞﾟ"), pressActions: [.changeCharacterType], longPressActions: .none, variationsModel: variations, keyColorType: .normal, needSuggestView: false, for: (1, 1))
    }

    func qwertyKeyModel(layout: CustardInterfaceLayout) -> QwertyKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value {
            case .changeKeyboard:
                @KeyboardSetting(.preferredLanguage) var preferredLanguage
                let changeKeyboardKey: QwertyChangeKeyboardKeyModel
                if let second = preferredLanguage.second {
                    changeKeyboardKey = .init(keySizeType: .normal(of: 1, for: 1), fallBackType: .secondTab(secondLanguage: second))
                } else {
                    changeKeyboardKey = .init(keySizeType: .normal(of: 1, for: 1), fallBackType: .tabBar)
                }
                return changeKeyboardKey
            case .enter:
                return QwertyEnterKeyModel(keySizeType: .enter)
            case .flickKogaki:
                return  convertToQwertyKeyModel(model: FlickKogakiKeyModel.shared)
            case .flickKutoten:
                return convertToQwertyKeyModel(model: FlickKanaSymbolsKeyModel.shared)
            case .flickHiraTab:
                return convertToQwertyKeyModel(model: FlickTabKeyModel.hiraTabKeyModel)
            case .flickAbcTab:
                return convertToQwertyKeyModel(model: FlickTabKeyModel.abcTabKeyModel)
            case .flickStar123Tab:
                return convertToQwertyKeyModel(model: FlickTabKeyModel.numberTabKeyModel)
            }
        case let .custom(value):
            let variations: [(label: KeyLabelType, actions: [ActionType])] = value.variations.reduce(into: []) {array, variation in
                switch variation.type {
                case .flickVariation:
                    break
                case .longpressVariation:
                    array.append((variation.key.design.label.keyLabelType, variation.key.press_actions.map {$0.actionType}))
                }
            }

            let model = QwertyKeyModel(
                labelType: value.design.label.keyLabelType,
                pressActions: value.press_actions.map {$0.actionType},
                longPressActions: value.longpress_actions.longpressActionType,
                variationsModel: VariationsModel(variations),
                keyColorType: value.design.color.qwertyKeyColorType,
                needSuggestView: value.longpress_actions == .none,
                for: (1, 1)
            )
            return model
        }
    }

    var simpleKeyModel: SimpleKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value {
            case .changeKeyboard:
                return SimpleChangeKeyboardKeyModel()
            case .enter:
                return SimpleEnterKeyModel()
            case .flickKogaki:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("小ﾞﾟ"), unpressedKeyColorType: .special, pressActions: [.changeCharacterType])
            case .flickKutoten:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("、"), unpressedKeyColorType: .normal, pressActions: [.input("、")])
            case .flickHiraTab:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("あいう"), unpressedKeyColorType: .special, pressActions: [.moveTab(.user_dependent(.japanese))])
            case .flickAbcTab:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("abc"), unpressedKeyColorType: .special, pressActions: [.moveTab(.user_dependent(.english))])
            case .flickStar123Tab:
                return SimpleKeyModel(keyType: .functional, keyLabelType: .text("☆123"), unpressedKeyColorType: .special, pressActions: [.moveTab(.existential(.flick_numbersymbols))])
            }
        case let .custom(value):
            return SimpleKeyModel(
                keyType: .normal,
                keyLabelType: value.design.label.keyLabelType,
                unpressedKeyColorType: value.design.color.simpleKeyColorType,
                pressActions: value.press_actions.map {$0.actionType},
                longPressActions: value.longpress_actions.longpressActionType
            )
        }
    }
}

struct CustomKeyboardView: View {
    private let custard: Custard
    private var tabDesign: TabDependentDesign {
        custard.interface.tabDesign(keyboardOrientation: variableStates.keyboardOrientation)
    }
    @ObservedObject private var variableStates = VariableStates.shared

    init(custard: Custard) {
        self.custard = custard
    }

    private func qwertyKeyData(x: Int, y: Int, size: QwertyKeySizeType) -> (position: CGPoint, size: CGSize) {
        let width = size.width(design: tabDesign)
        let height = size.height(design: tabDesign)
        let dx = width * 0.5 + tabDesign.keyViewWidth * CGFloat(x) + tabDesign.horizontalSpacing * CGFloat(x)
        let dy = height * 0.5 + tabDesign.keyViewHeight * CGFloat(y) + tabDesign.verticalSpacing * CGFloat(y)
        return (CGPoint(x: dx, y: dy), CGSize(width: width, height: height))
    }

    var body: some View {
        switch custard.interface.keyLayout {
        case let .gridFit(value):
            switch custard.interface.keyStyle {
            case .tenkeyStyle:
                CustardFlickKeysView(models: custard.interface.flickKeyModels, tabDesign: tabDesign, layout: value) {view, _, _ in
                    view
                }
            case .pcStyle:
                let models = custard.interface.qwertyKeyModels
                ZStack {
                    ForEach(0..<value.columnCount, id: \.self) {y in
                        ForEach(0..<value.rowCount, id: \.self) {x in
                            if let data = models[.gridFit(x: x, y: y)] {
                                let info = qwertyKeyData(x: x, y: y, size: data.sizeType)
                                QwertyKeyView(model: data.model, tabDesign: tabDesign, size: info.size)
                                    .position(x: info.position.x, y: info.position.y)
                            }
                        }
                    }.frame(width: tabDesign.keysWidth, height: tabDesign.keysHeight)
                }
            }
        case let .gridScroll(value):
            let height = tabDesign.keysHeight
            let models = (0..<custard.interface.keys.count).compactMap {custard.interface.keys[.gridScroll(GridScrollPositionSpecifier($0))]}
            switch value.direction {
            case .vertical:
                let gridItem = GridItem(.fixed(tabDesign.keyViewWidth), spacing: tabDesign.horizontalSpacing / 2)
                ScrollView(.vertical) {
                    LazyVGrid(columns: Array(repeating: gridItem, count: Int(value.rowCount)), spacing: tabDesign.verticalSpacing / 2) {
                        ForEach(0..<models.count, id: \.self) {i in
                            SimpleKeyView(model: models[i].simpleKeyModel, tabDesign: tabDesign)
                        }
                    }
                }.frame(height: height)
            case .horizontal:
                let gridItem = GridItem(.fixed(tabDesign.keyViewHeight), spacing: tabDesign.verticalSpacing / 2)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: Array(repeating: gridItem, count: Int(value.columnCount)), spacing: tabDesign.horizontalSpacing / 2) {
                        ForEach(0..<models.count, id: \.self) {i in
                            SimpleKeyView(model: models[i].simpleKeyModel, tabDesign: tabDesign)
                        }
                    }
                }.frame(height: height)
            }
        }
    }
}

struct CustardFlickKeysView<Content: View>: View {
    init(models: [KeyPosition : (model: FlickKeyModelProtocol, width: Int, height: Int)], tabDesign: TabDependentDesign, layout: CustardInterfaceLayoutGridValue, needSuggest: Bool = true, @ViewBuilder generator: @escaping (FlickKeyView, Int, Int) -> (Content)) {
        self.models = models
        self.tabDesign = tabDesign
        self.layout = layout
        self.needSuggest = needSuggest
        self.contentGenerator = generator
    }

    private let contentGenerator: (FlickKeyView, Int, Int) -> (Content)
    private let models: [KeyPosition: (model: FlickKeyModelProtocol, width: Int, height: Int)]
    private let tabDesign: TabDependentDesign
    private let layout: CustardInterfaceLayoutGridValue
    private let needSuggest: Bool

    private func flickKeyData(x: Int, y: Int, width: Int, height: Int) -> (position: CGPoint, size: CGSize) {
        let width = tabDesign.keyViewWidth(widthCount: width)
        let height = tabDesign.keyViewHeight(heightCount: height)
        let dx = width * 0.5 + tabDesign.keyViewWidth * CGFloat(x) + tabDesign.horizontalSpacing * CGFloat(x)
        let dy = height * 0.5 + tabDesign.keyViewHeight * CGFloat(y) + tabDesign.verticalSpacing * CGFloat(y)
        return (CGPoint(x: dx, y: dy), CGSize(width: width, height: height))
    }

    var body: some View {
        ZStack {
            ForEach(0..<layout.rowCount, id: \.self) {x in
                ForEach(0..<layout.columnCount, id: \.self) {y in
                    if let data = models[.gridFit(x: x, y: y)] {
                        let info = flickKeyData(x: x, y: y, width: data.width, height: data.height)
                        contentGenerator(FlickKeyView(model: data.model, size: info.size), x, y)
                            .position(x: info.position.x, y: info.position.y)
                    }
                }
            }.frame(width: tabDesign.keysWidth, height: tabDesign.keysHeight)
            if needSuggest {
                ForEach(0..<layout.rowCount, id: \.self) {x in
                    ForEach(0..<layout.columnCount, id: \.self) {y in
                        if let data = models[.gridFit(x: x, y: y)] {
                            let info = flickKeyData(x: x, y: y, width: data.width, height: data.height)
                            SuggestView(model: data.model.suggestModel, tabDesign: tabDesign, size: info.size)
                                .position(x: info.position.x, y: info.position.y)
                        }
                    }
                }.frame(width: tabDesign.keysWidth, height: tabDesign.keysHeight)
            }
            /*
             let suggests = models.filter{key, value in
             return value.model.suggestModel.variableSection.suggestState.isActive
             }.map{(key: $0.key, value: $0.value)}
             ForEach(suggests.indices, id: \.self){ i in
             if case let .gridFit(x: x, y: y) = suggests[i].key{
             let info = flickKeyData(x: x, y: y, width: suggests[i].value.width, height: suggests[i].value.height)
             SuggestView(model: suggests[i].value.model.suggestModel, tabDesign: tabDesign, size: info.size)
             .position(x: info.position.x, y: info.position.y)
             }
             }
             */
        }
    }
}
