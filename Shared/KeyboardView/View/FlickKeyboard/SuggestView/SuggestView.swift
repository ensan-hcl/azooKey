//
//  SuggestView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum SuggestState {
    case oneDirection(FlickDirection)
    case all
    case nothing

    var isActive: Bool {
        if case .nothing = self {
            return false
        }
        return true
    }
}

// V：フリック・長押しされた時に表示されるビュー
struct SuggestView: View {
    private let model: SuggestModel
    @ObservedObject private var modelVariableSection: SuggestModelVariableSection
    @Environment(\.themeEnvironment) private var theme
    private let tabDesign: TabDependentDesign
    private let size: CGSize

    init(model: SuggestModel, tabDesign: TabDependentDesign, size: CGSize) {
        self.model = model
        self.modelVariableSection = model.variableSection
        self.tabDesign = tabDesign
        self.size = size
    }

    private func neededApeearView(direction: FlickDirection) -> some View {
        if case .oneDirection(direction) = self.modelVariableSection.suggestState {
            if let model = self.model.flickModels[direction] {
                return model.getSuggestView(size: size, isHidden: false, isPointed: true, theme: theme)
            } else {
                return FlickedKeyModel.zero.getSuggestView(size: size, isHidden: true, theme: theme)
            }
        }
        if case .all = self.modelVariableSection.suggestState {
            if let model = self.model.flickModels[direction] {
                return model.getSuggestView(size: size, isHidden: false, theme: theme)
            } else {
                return FlickedKeyModel.zero.getSuggestView(size: size, isHidden: true, theme: theme)
            }
        }
        return FlickedKeyModel.zero.getSuggestView(size: size, isHidden: true, theme: theme)
    }

    var body: some View {
        VStack(spacing: tabDesign.verticalSpacing) {
            if self.modelVariableSection.suggestState.isActive {
                self.neededApeearView(direction: .top)
                HStack(spacing: tabDesign.horizontalSpacing) {
                    self.neededApeearView(direction: .left)
                    RoundedRectangle(cornerRadius: 5.0)
                        .strokeAndFill(
                            fillContent: theme.specialKeyFillColor.color,
                            strokeContent: theme.borderColor.color,
                            lineWidth: CGFloat(theme.borderWidth)
                        )
                        .frame(width: size.width, height: size.height)
                    self.neededApeearView(direction: .right)
                }
                self.neededApeearView(direction: .bottom)
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}
