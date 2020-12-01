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
    
    func getSuggestView(size: CGSize, isHidden: Bool = false, isPointed: Bool = false) -> some View {
        let color = Color(isPointed ? UIColor.systemGray4:UIColor.systemGray5)
        return Rectangle()
            .frame(width: size.width, height: size.height)
            .foregroundColor(color)
            .cornerRadius(5.0)
            .overlay(self.label(width: size.width))
            .allowsHitTesting(false)
            .opacity(isHidden ? 0:1)
    }
    
    func label(width: CGFloat) -> some View {
        return KeyLabel(self.labelType, width: width)
    }
    
    func flick(){
        self.pressActions.forEach{Store.shared.action.registerPressAction($0)}
    }
    
    func longFlickReserve(){
        self.longPressActions.forEach{Store.shared.action.reserveLongPressAction($0)}
    }
    
    func longFlickEnd(){
        self.longPressActions.forEach{Store.shared.action.registerLongPressActionEnd($0)}
    }
    
}
