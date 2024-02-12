//
//  QwertyVariationsView.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyVariationsView<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    private let model: VariationsModel
    private let selection: Int?
    @Environment(Extension.Theme.self) private var theme
    @Namespace private var namespace
    private let tabDesign: TabDependentDesign
    @EnvironmentObject private var variableStates: VariableStates

    init(model: VariationsModel, selection: Int?, tabDesign: TabDependentDesign) {
        self.tabDesign = tabDesign
        self.model = model
        self.selection = selection
    }

    private var suggestColor: Color {
        theme != Extension.ThemeExtension.default(layout: .qwerty) ? .white : Design.colors.suggestKeyColor(layout: .qwerty)
    }

    var body: some View {
        HStack(spacing: tabDesign.horizontalSpacing) {
            ForEach(model.variations.indices, id: \.self) {(index: Int) in
                ZStack {
                    if index == selection {
                        Rectangle()
                            .foregroundStyle(.blue)
                            .cornerRadius(10.0)
                            .matchedGeometryEffect(id: "focus", in: namespace)
                    }
                    getLabel(model.variations[index].label, textColor: index == selection ? .white : theme.suggestLabelTextColor?.color ?? .black)
                }
                .frame(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight(screenWidth: variableStates.screenWidth) * 0.9, alignment: .center)
            }
        }
        .animation(.easeOut(duration: 0.075), value: selection)
    }

    @MainActor private func getLabel(_ labelType: KeyLabelType, textColor: Color) -> KeyLabel<Extension> {
        KeyLabel(labelType, width: tabDesign.keyViewWidth, textColor: textColor)
    }
}
