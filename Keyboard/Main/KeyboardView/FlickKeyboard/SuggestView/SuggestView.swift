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
struct SuggestView: View{
    private let model: SuggestModel
    @ObservedObject private var modelVariableSection: SuggestModelVariableSection
    
    init(model: SuggestModel){
        self.model = model
        self.modelVariableSection = model.variableSection
    }
     
    func neededApeearView(direction: FlickDirection) -> some View {
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
        VStack(spacing: Store.shared.design.keyViewVerticalSpacing){
            if self.modelVariableSection.suggestState.isActive{
                self.neededApeearView(direction: .top)
                
                HStack(spacing: Store.shared.design.keyViewHorizontalSpacing){
                    self.neededApeearView(direction: .left)
                    Rectangle()
                        .frame(width: self.model.keySize.width, height: self.model.keySize.height)
                        .foregroundColor(Store.shared.design.colors.highlightedKeyColor)
                        .cornerRadius(5.0)
                    self.neededApeearView(direction: .right)
                }
 
                self.neededApeearView(direction: .bottom)
            }
 
        }
        .frame(width: model.keySize.width, height: model.keySize.height)
        .allowsHitTesting(false)
    }
}
