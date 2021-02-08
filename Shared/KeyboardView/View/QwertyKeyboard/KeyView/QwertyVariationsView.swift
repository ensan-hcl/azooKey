//
//  QwertyVariationsView.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyVariationsView: View {
    private let model: VariationsModel
    @ObservedObject private var modelVariableSection: VariationsModelVariableSection
    init(model: VariationsModel){
        self.model = model
        self.modelVariableSection = model.variableSection
    }

    private var suggestColor: Color {
        VariableStates.shared.themeManager.theme != .default ? .white : Design.colors.suggestKeyColor
    }

    var body: some View {
        HStack(spacing: Design.shared.horizontalSpacing){
            ForEach(model.variations.indices, id: \.self){(index: Int) in
                ZStack{
                    Rectangle()
                        .foregroundColor(index == self.modelVariableSection.selection ? Color.blue:suggestColor)
                        .frame(width: Design.shared.keyViewSize.width, height: Design.shared.keyViewSize.height*0.9, alignment: .center)
                        .cornerRadius(10.0)
                    getLabel(model.variations[index].label)
                }
            }

        }
    }
    
    func getLabel(_ labelType: KeyLabelType) -> KeyLabel {
        let width = Design.shared.keyViewSize.width
        if VariableStates.shared.themeManager.theme != .default{
            return KeyLabel(labelType, width: width, textColor: .black)
        }
        return KeyLabel(labelType, width: width)
    }

}
