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
    private let theme: ThemeData

    init(model: SuggestModel, theme: ThemeData){
        self.model = model
        self.modelVariableSection = model.variableSection
        self.theme = theme
    }
     
    private func neededApeearView(direction: FlickDirection) -> some View {
        if case .oneDirection(direction) = self.modelVariableSection.suggestState{
            if let model = self.model.flickModels[direction]{
                return model.getSuggestView(size: self.model.keySize, isPointed: true, theme: theme)
            }else{
                return FlickedKeyModel.zero.getSuggestView(size: self.model.keySize, isHidden: true, theme: theme)
            }
        }
        if case .all = self.modelVariableSection.suggestState{
            if let model = self.model.flickModels[direction]{
                return model.getSuggestView(size: self.model.keySize, theme: theme)
            }else{
                return FlickedKeyModel.zero.getSuggestView(size: self.model.keySize, isHidden: true, theme: theme)
            }
        }
        return FlickedKeyModel.zero.getSuggestView(size: self.model.keySize, isHidden: true, theme: theme)
    }

    private var centerFillColor: Color {
        theme.specialKeyFillColor.color
    }

    var body: some View {
        VStack(spacing: Design.shared.verticalSpacing){
            if self.modelVariableSection.suggestState.isActive{
                self.neededApeearView(direction: .top)
                
                HStack(spacing: Design.shared.horizontalSpacing){
                    self.neededApeearView(direction: .left)
                    RoundedRectangle(cornerRadius: 5.0)
                        .frame(width: self.model.keySize.width, height: self.model.keySize.height)
                        .foregroundColor(centerFillColor)
                    self.neededApeearView(direction: .right)
                }
                self.neededApeearView(direction: .bottom)
            }
 
        }
        .frame(width: model.keySize.width, height: model.keySize.height)
        .allowsHitTesting(false)
    }
}
