//
//  VerticalCustomKeyboard.swift
//  azooKey
//
//  Created by ensan on 2021/02/18.
//  Copyright © 2021 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

fileprivate extension CustardKeyLabelStyle {
    var keyLabelType: KeyLabelType {
        switch self {
        case let .text(value):
            return .text(value)
        case let .systemImage(value):
            return .image(value)
        case let .mainAndSub(main, sub):
            return .symbols([main, sub])
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
    func tabDesign(interfaceSize: CGSize, keyboardOrientation: KeyboardOrientation) -> TabDependentDesign {
        switch self.keyLayout {
        case let .gridFit(value):
            return TabDependentDesign(width: value.rowCount, height: value.columnCount, interfaceSize: interfaceSize, layout: keyStyle.keyboardLayout, orientation: keyboardOrientation)
        case let .gridScroll(value):
            switch value.direction {
            case .vertical:
                return TabDependentDesign(width: CGFloat(Int(value.rowCount)), height: CGFloat(value.columnCount), interfaceSize: interfaceSize, layout: .flick, orientation: keyboardOrientation)
            case .horizontal:
                return TabDependentDesign(width: CGFloat(value.rowCount), height: CGFloat(Int(value.columnCount)), interfaceSize: interfaceSize, layout: .flick, orientation: keyboardOrientation)
            }
        }
    }

    @MainActor func flickKeyModels<Extension: ApplicationSpecificKeyboardViewExtension>(extension _: Extension.Type) -> [KeyPosition: (model: any FlickKeyModelProtocol, width: Int, height: Int)] {
        self.keys.reduce(into: [:]) {dictionary, value in
            switch value.key {
            case let .gridFit(data):
                dictionary[.gridFit(x: data.x, y: data.y)] = (value.value.flickKeyModel(extension: Extension.self), data.width, data.height)
            case let .gridScroll(data):
                dictionary[.gridScroll(index: data.index)] = (value.value.flickKeyModel(extension: Extension.self), 1, 1)
            }
        }
    }

    @MainActor func qwertyKeyModels<Extension: ApplicationSpecificKeyboardViewExtension>(extension _: Extension.Type) -> [KeyPosition: (model: any QwertyKeyModelProtocol, sizeType: QwertyKeySizeType)] {
        self.keys.reduce(into: [:]) {dictionary, value in
            switch value.key {
            case let .gridFit(data):
                dictionary[.gridFit(x: data.x, y: data.y)] = (value.value.qwertyKeyModel(layout: self.keyLayout, extension: Extension.self), .unit(width: data.width, height: data.height))
            case let .gridScroll(data):
                dictionary[.gridScroll(index: data.index)] = (value.value.qwertyKeyModel(layout: self.keyLayout, extension: Extension.self), .unit(width: 1, height: 1))
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
        case .unimportant:
            return .unimportant
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
        case .unimportant:
            return .unimportant
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
        case .unimportant:
            return .unimportant
        }
    }

}

extension CustardInterfaceKey {
    @MainActor public func flickKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>(extension _: Extension.Type) -> any FlickKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value {
            case .changeKeyboard:
                return FlickChangeKeyboardModel<Extension>.shared
            case .enter:
                return FlickEnterKeyModel<Extension>()
            case .flickKogaki:
                return FlickKogakiKeyModel<Extension>.shared
            case .flickKutoten:
                return FlickKanaSymbolsKeyModel<Extension>.shared
            case .flickHiraTab:
                return FlickTabKeyModel<Extension>.hiraTabKeyModel()
            case .flickAbcTab:
                return FlickTabKeyModel<Extension>.abcTabKeyModel()
            case .flickStar123Tab:
                return FlickTabKeyModel<Extension>.numberTabKeyModel()
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
            let model = FlickKeyModel<Extension>(
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

    private func convertToQwertyKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>(customKey: KeyFlickSetting.SettingData, extension _: Extension.Type) -> any QwertyKeyModelProtocol {
        let variations = VariationsModel([customKey.flick[.left], customKey.flick[.top], customKey.flick[.right], customKey.flick[.bottom]].compactMap {$0}.map {(label: $0.labelType, actions: $0.pressActions)})
        return QwertyKeyModel<Extension>(labelType: customKey.labelType, pressActions: customKey.actions, longPressActions: customKey.longpressActions, variationsModel: variations, keyColorType: .normal, needSuggestView: false, for: (1, 1))
    }

    @MainActor func qwertyKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>(layout: CustardInterfaceLayout, extension: Extension.Type) -> any QwertyKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value {
            case .changeKeyboard:
                let changeKeyboardKey: QwertyChangeKeyboardKeyModel<Extension>
                if let second = Extension.SettingProvider.preferredLanguage.second {
                    changeKeyboardKey = .init(keySizeType: .normal(of: 1, for: 1), fallBackType: .secondTab(secondLanguage: second))
                } else {
                    changeKeyboardKey = .init(keySizeType: .normal(of: 1, for: 1), fallBackType: .tabBar)
                }
                return changeKeyboardKey
            case .enter:
                return QwertyEnterKeyModel<Extension>(keySizeType: .enter)
            case .flickKogaki:
                return convertToQwertyKeyModel(customKey: Extension.SettingProvider.koganaFlickCustomKey.compiled(), extension: Extension.self)
            case .flickKutoten:
                return convertToQwertyKeyModel(customKey: Extension.SettingProvider.kanaSymbolsFlickCustomKey.compiled(), extension: Extension.self)
            case .flickHiraTab:
                return convertToQwertyKeyModel(customKey: Extension.SettingProvider.hiraTabFlickCustomKey.compiled(), extension: Extension.self)
            case .flickAbcTab:
                return convertToQwertyKeyModel(customKey: Extension.SettingProvider.abcTabFlickCustomKey.compiled(), extension: Extension.self)
            case .flickStar123Tab:
                return convertToQwertyKeyModel(customKey: Extension.SettingProvider.symbolsTabFlickCustomKey.compiled(), extension: Extension.self)
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

            let model = QwertyKeyModel<Extension>(
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

    func simpleKeyModel<Extension: ApplicationSpecificKeyboardViewExtension>(extension _: Extension.Type) -> any SimpleKeyModelProtocol {
        switch self {
        case let .system(value):
            switch value {
            case .changeKeyboard:
                return SimpleChangeKeyboardKeyModel<Extension>()
            case .enter:
                return SimpleEnterKeyModel<Extension>()
            case .flickKogaki:
                return SimpleKeyModel<Extension>(keyLabelType: .text("小ﾞﾟ"), unpressedKeyColorType: .special, pressActions: [.changeCharacterType])
            case .flickKutoten:
                return SimpleKeyModel<Extension>(keyLabelType: .text("、"), unpressedKeyColorType: .normal, pressActions: [.input("、")])
            case .flickHiraTab:
                return SimpleKeyModel<Extension>(keyLabelType: .text("あいう"), unpressedKeyColorType: .special, pressActions: [.moveTab(.system(.user_japanese))])
            case .flickAbcTab:
                return SimpleKeyModel<Extension>(keyLabelType: .text("abc"), unpressedKeyColorType: .special, pressActions: [.moveTab(.system(.user_english))])
            case .flickStar123Tab:
                return SimpleKeyModel<Extension>(keyLabelType: .text("☆123"), unpressedKeyColorType: .special, pressActions: [.moveTab(.system(.flick_numbersymbols))])
            }
        case let .custom(value):
            return SimpleKeyModel<Extension>(
                keyLabelType: value.design.label.keyLabelType,
                unpressedKeyColorType: value.design.color.simpleKeyColorType,
                pressActions: value.press_actions.map {$0.actionType},
                longPressActions: value.longpress_actions.longpressActionType
            )
        }
    }
}

@available(iOS 15, *)
struct CustomKeyboardView<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    private let custard: Custard
    private var tabDesign: TabDependentDesign {
        custard.interface.tabDesign(interfaceSize: variableStates.interfaceSize, keyboardOrientation: variableStates.keyboardOrientation)
    }
    @EnvironmentObject private var variableStates: VariableStates

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
                CustardFlickKeysView(models: custard.interface.flickKeyModels(extension: Extension.self), tabDesign: tabDesign, layout: value) {(view: FlickKeyView<Extension>, _, _) in
                    view
                }
            case .pcStyle:
                let models = custard.interface.qwertyKeyModels(extension: Extension.self)
                ZStack {
                    ForEach(0..<value.columnCount, id: \.self) {y in
                        ForEach(0..<value.rowCount, id: \.self) {x in
                            if let data = models[.gridFit(x: x, y: y)] {
                                let info = qwertyKeyData(x: x, y: y, size: data.sizeType)
                                QwertyKeyView<Extension>(model: data.model, tabDesign: tabDesign, size: info.size)
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
                            SimpleKeyView<Extension>(model: models[i].simpleKeyModel(extension: Extension.self), tabDesign: tabDesign)
                        }
                    }
                }.frame(height: height)
            case .horizontal:
                let gridItem = GridItem(.fixed(tabDesign.keyViewHeight), spacing: tabDesign.verticalSpacing / 2)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: Array(repeating: gridItem, count: Int(value.columnCount)), spacing: tabDesign.horizontalSpacing / 2) {
                        ForEach(0..<models.count, id: \.self) {i in
                            SimpleKeyView<Extension>(model: models[i].simpleKeyModel(extension: Extension.self), tabDesign: tabDesign)
                        }
                    }
                }.frame(height: height)
            }
        }
    }
}

@available(iOS 15, *)
public struct CustardFlickKeysView<Extension: ApplicationSpecificKeyboardViewExtension, Content: View>: View {
    @State private var suggestState = FlickSuggestState()

    public init(models: [KeyPosition: (model: any FlickKeyModelProtocol, width: Int, height: Int)], tabDesign: TabDependentDesign, layout: CustardInterfaceLayoutGridValue, @ViewBuilder generator: @escaping (FlickKeyView<Extension>, Int, Int) -> (Content)) {
        self.models = models
        self.tabDesign = tabDesign
        self.layout = layout
        self.contentGenerator = generator
    }

    private let contentGenerator: (FlickKeyView<Extension>, Int, Int) -> (Content)
    private let models: [KeyPosition: (model: any FlickKeyModelProtocol, width: Int, height: Int)]
    private let tabDesign: TabDependentDesign
    private let layout: CustardInterfaceLayoutGridValue

    @MainActor private func flickKeyData(x: Int, y: Int, width: Int, height: Int) -> (position: CGPoint, size: CGSize) {
        let width = tabDesign.keyViewWidth(widthCount: width)
        let height = tabDesign.keyViewHeight(heightCount: height)
        let dx = width * 0.5 + tabDesign.keyViewWidth * CGFloat(x) + tabDesign.horizontalSpacing * CGFloat(x)
        let dy = height * 0.5 + tabDesign.keyViewHeight * CGFloat(y) + tabDesign.verticalSpacing * CGFloat(y)
        return (CGPoint(x: dx, y: dy), CGSize(width: width, height: height))
    }

    public var body: some View {
        ZStack {
            ForEach(0..<layout.rowCount, id: \.self) {x in
                let columnSuggestStates = self.suggestState.items[x, default: [:]]
                ForEach(0..<layout.columnCount, id: \.self) {y in
                    if let data = models[.gridFit(x: x, y: y)] {
                        let info = flickKeyData(x: x, y: y, width: data.width, height: data.height)
                        contentGenerator(FlickKeyView(model: data.model, size: info.size, position: (x, y), suggestState: $suggestState), x, y)                            .zIndex(columnSuggestStates[y] != nil ? 1 : 0)
                            .overlay(alignment: .center) {
                                if let suggestType = columnSuggestStates[y] {
                                    FlickSuggestView<Extension>(model: data.model, tabDesign: tabDesign, size: info.size, suggestType: suggestType)
                                        .zIndex(2)
                                }
                            }
                            .position(x: info.position.x, y: info.position.y)
                    }
                }
                .zIndex(columnSuggestStates.isEmpty ? 0 : 1)
            }
            .frame(width: tabDesign.keysWidth, height: tabDesign.keysHeight)
        }
    }
}
