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
    private let selection: Int?
    @Environment(\.themeEnvironment) private var theme
    private let tabDesign: TabDependentDesign
    init(model: VariationsModel, selection: Int?, tabDesign: TabDependentDesign) {
        self.tabDesign = tabDesign
        self.model = model
        self.selection = selection
    }

    private var suggestColor: Color {
        theme != .default ? .white : Design.colors.suggestKeyColor
    }

    var body: some View {
        HStack(spacing: tabDesign.horizontalSpacing) {
            ForEach(model.variations.indices, id: \.self) {(index: Int) in
                ZStack {
                    Rectangle()
                        .foregroundColor(index == selection ? Color.blue : suggestColor)
                        .frame(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight * 0.9, alignment: .center)
                        .cornerRadius(10.0)
                    getLabel(model.variations[index].label)
                }
            }
        }
    }

    private func getLabel(_ labelType: KeyLabelType) -> KeyLabel {
        let width = tabDesign.keyViewWidth
        if theme != .default {
            return KeyLabel(labelType, width: width, textColor: .black)
        }
        return KeyLabel(labelType, width: width)
    }

}
