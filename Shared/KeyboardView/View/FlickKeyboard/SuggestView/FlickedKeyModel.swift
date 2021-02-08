//
//  FlickedView.swift
//  Keyboard
//
//  Created by β α on 2020/04/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum FlickDirection: CustomStringConvertible {
    case left
    case top
    case right
    case bottom
    
    var description: String {
        switch self{
        case .left:
            return "左"
        case .top:
            return "上"
        case .right:
            return "右"
        case .bottom:
            return "下"
        }
    }
}

struct FlickedKeyModel{
    static let zero: FlickedKeyModel = FlickedKeyModel(labelType: .text(""), pressActions: [])
    let labelType: KeyLabelType
    let pressActions: [ActionType]
    let longPressActions: [KeyLongPressActionType]
    
    init(labelType: KeyLabelType, pressActions: [ActionType], longPressActions: [KeyLongPressActionType] = []) {
        self.labelType = labelType
        self.pressActions = pressActions
        self.longPressActions = longPressActions
    }

    private var pointedColor: Color {
        VariableStates.shared.themeManager.theme != .default ? .white : Color(UIColor.systemGray4)
    }

    private var unpointedColor: Color {
        VariableStates.shared.themeManager.theme != .default ? .white : Color(UIColor.systemGray5)
    }

    func getSuggestView(size: CGSize, isHidden: Bool = false, isPointed: Bool = false) -> some View {
        let color = isPointed ? pointedColor : unpointedColor
        return RoundedRectangle(cornerRadius: 5.0)
            .frame(width: size.width, height: size.height)
            .foregroundColor(color)
            .overlay(self.label(width: size.width))
            .allowsHitTesting(false)
            .opacity(isHidden ? 0:1)
    }
    
    func label(width: CGFloat) -> some View {
        if VariableStates.shared.themeManager.theme != .default{
            return KeyLabel(self.labelType, width: width, textColor: .black)
        }
        return KeyLabel(self.labelType, width: width)
    }
    
    func flick(){
        self.pressActions.forEach{VariableStates.shared.action.registerAction($0)}
    }
    
    func longFlickReserve(){
        self.longPressActions.forEach{VariableStates.shared.action.reserveLongPressAction($0)}
    }
    
    func longFlickEnd(){
        self.longPressActions.forEach{VariableStates.shared.action.registerLongPressActionEnd($0)}
    }
    
}
