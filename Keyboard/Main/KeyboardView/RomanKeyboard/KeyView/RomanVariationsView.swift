//
//  RomanVariationsView.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI



struct RomanVariationsView: View {
    private let model: VariationsModel
    @ObservedObject private var modelVariableSection: VariationsModelVariableSection
    init(model: VariationsModel){
        self.model = model
        self.modelVariableSection = model.variableSection
    }
    
    var body: some View {
        HStack(spacing: Store.shared.design.keyViewHorizontalSpacing){
            ForEach(model.variations.indices){(index: Int) in
                ZStack{
                    Rectangle()
                        .foregroundColor(index == self.modelVariableSection.selection ? Color.blue:Store.shared.design.colors.highlightedKeyColor)
                        .frame(width: Store.shared.design.keyViewSize.width, height: Store.shared.design.keyViewSize.height*0.9, alignment: .center)
                        .cornerRadius(10.0)
                    getLabel(model.variations[index].label)
                }
            }

        }
    }
    
    func getLabel(_ labelType: KeyLabelType) -> KeyLabel {
        let width = Store.shared.design.keyViewSize.width
        return KeyLabel(labelType, width: width)
    }

}
