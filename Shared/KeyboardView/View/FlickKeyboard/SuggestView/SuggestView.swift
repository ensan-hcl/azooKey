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
    private let tabDesign: TabDependentDesign

    init(model: SuggestModel, theme: ThemeData, tabDesign: TabDependentDesign){
        self.model = model
        self.modelVariableSection = model.variableSection
        self.theme = theme
        self.tabDesign = tabDesign
    }
     
    private func neededApeearView(direction: FlickDirection) -> some View {
        let keySize = CGSize(width: model.keySizeType.width(design: tabDesign), height:model.keySizeType.height(design: tabDesign))
        if case .oneDirection(direction) = self.modelVariableSection.suggestState{
            if let model = self.model.flickModels[direction]{
                return model.getSuggestView(size: keySize, isPointed: true, theme: theme)
            }else{
                return FlickedKeyModel.zero.getSuggestView(size: keySize, isHidden: true, theme: theme)
            }
        }
        if case .all = self.modelVariableSection.suggestState{
            if let model = self.model.flickModels[direction]{
                return model.getSuggestView(size: keySize, theme: theme)
            }else{
                return FlickedKeyModel.zero.getSuggestView(size: keySize, isHidden: true, theme: theme)
            }
        }
        return FlickedKeyModel.zero.getSuggestView(size: keySize, isHidden: true, theme: theme)
    }

    private var centerFillColor: Color {
        theme.specialKeyFillColor.color
    }

    var body: some View {
        let keySize = CGSize(width: model.keySizeType.width(design: tabDesign), height:model.keySizeType.height(design: tabDesign))
        VStack(spacing: tabDesign.verticalSpacing){
            if self.modelVariableSection.suggestState.isActive{
                self.neededApeearView(direction: .top)
                
                HStack(spacing: tabDesign.horizontalSpacing){
                    self.neededApeearView(direction: .left)
                    RoundedRectangle(cornerRadius: 5.0)
                        .frame(width: keySize.width, height: keySize.height)
                        .foregroundColor(centerFillColor)
                    self.neededApeearView(direction: .right)
                }
                self.neededApeearView(direction: .bottom)
            }
 
        }
        .frame(width: keySize.width, height: keySize.height)
        .allowsHitTesting(false)
    }
}
