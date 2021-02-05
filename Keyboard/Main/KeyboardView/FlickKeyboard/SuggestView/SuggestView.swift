//
//  SuggestView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
enum SuggestState{
    case oneDirection(FlickDirection)
    case all
    case nothing
    
    var isActive: Bool {
        if case .nothing = self{
            return false
        }
        return true
    }
}

//V：フリック・長押しされた時に表示されるビュー
struct SuggestView: View {
    private let model: SuggestModel
    @ObservedObject private var modelVariableSection: SuggestModelVariableSection
    
    init(model: SuggestModel){
        self.model = model
        self.modelVariableSection = model.variableSection
    }
     
    private func neededApeearView(direction: FlickDirection) -> some View {
        if case .oneDirection(direction) = self.modelVariableSection.suggestState{
            if let model = self.model.flickModels[direction]{
                return model.getSuggestView(size: self.model.keySize, isPointed: true)
            }else{
                return FlickedKeyModel.zero.getSuggestView(size: self.model.keySize, isHidden: true)
            }
        }
        if case .all = self.modelVariableSection.suggestState{
            if let model = self.model.flickModels[direction]{
                return model.getSuggestView(size: self.model.keySize)
            }else{
                return FlickedKeyModel.zero.getSuggestView(size: self.model.keySize, isHidden: true)
            }
        }
        return FlickedKeyModel.zero.getSuggestView(size: self.model.keySize, isHidden: true)
    }
    
    var body: some View {
        VStack(spacing: Design.shared.verticalSpacing){
            if self.modelVariableSection.suggestState.isActive{
                self.neededApeearView(direction: .top)
                
                HStack(spacing: Design.shared.horizontalSpacing){
                    self.neededApeearView(direction: .left)
                    RoundedRectangle(cornerRadius: 5.0)
                        .frame(width: self.model.keySize.width, height: self.model.keySize.height)
                        .foregroundColor(Design.shared.colors.highlightedKeyColor.opacity(Design.shared.themeManager.theme.keyBackgroundColorOpacity))
                    self.neededApeearView(direction: .right)
                }
                self.neededApeearView(direction: .bottom)
            }
 
        }
        .frame(width: model.keySize.width, height: model.keySize.height)
        .allowsHitTesting(false)
    }
}
