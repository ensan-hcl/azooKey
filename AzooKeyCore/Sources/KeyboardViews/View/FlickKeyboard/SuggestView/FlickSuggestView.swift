//
//  FlickSuggestView.swift
//  KeyboardViews
//
//  Created by ensan on 2020/04/10.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI


struct FlickSuggestView<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    @EnvironmentObject private var variableStates: VariableStates
    @Environment(Extension.Theme.self) private var theme
    private let model: any FlickKeyModelProtocol
    private let suggestType: FlickSuggestType
    private let tabDesign: TabDependentDesign
    private let size: CGSize

    init(model: any FlickKeyModelProtocol, tabDesign: TabDependentDesign, size: CGSize, suggestType: FlickSuggestType) {
        self.model = model
        self.tabDesign = tabDesign
        self.size = size
        self.suggestType = suggestType
    }
    
    private func getSuggestView(for model: FlickedKeyModel, isHidden: Bool, isPointed: Bool = false) -> some View {
        // 着せ替えが有効の場合、サジェストの背景色はwhiteにする。
        var pointedColor: Color {
            theme != Extension.ThemeExtension.default(layout: .flick) ? .white : .systemGray4
        }
        var unpointedColor: Color {
            theme != Extension.ThemeExtension.default(layout: .flick) ? .white : .systemGray5
        }

        let color = isPointed ? pointedColor : unpointedColor
        return RoundedRectangle(cornerRadius: 5.0)
            .strokeAndFill(fillContent: color, strokeContent: theme.borderColor.color, lineWidth: theme.borderWidth)
            .frame(width: size.width, height: size.height)
            .overlay {
                // ラベル
                KeyLabel<Extension>(model.labelType, width: size.width, textColor: theme.suggestLabelTextColor?.color)
            }
            .allowsHitTesting(false)
            .opacity(isHidden ? 0 : 1)
    }

    /// その方向にViewの表示が必要な場合はサジェストのViewを、不要な場合は透明なViewを返す。
    @ViewBuilder private func getSuggestViewIfNecessary(direction: FlickDirection) -> some View {
        switch self.suggestType {
        case .all:
            if let model = self.model.flickKeys(variableStates: variableStates)[direction] {
                getSuggestView(for: model, isHidden: false)
            } else {
                getSuggestView(for: .empty, isHidden: true)
            }
        case .flick(let targetDirection):
            if targetDirection == direction, let model = self.model.flickKeys(variableStates: variableStates)[direction] {
                getSuggestView(for: model, isHidden: false, isPointed: true)
            } else {
                getSuggestView(for: .empty, isHidden: true)
            }
        }
    }

    var body: some View {
        VStack(spacing: tabDesign.verticalSpacing) {
            self.getSuggestViewIfNecessary(direction: .top)
            HStack(spacing: tabDesign.horizontalSpacing) {
                self.getSuggestViewIfNecessary(direction: .left)
                RoundedRectangle(cornerRadius: 5.0)
                    .strokeAndFill(
                        fillContent: theme.specialKeyFillColor.color,
                        strokeContent: theme.borderColor.color,
                        lineWidth: theme.borderWidth
                    )
                    .frame(width: size.width, height: size.height)
                self.getSuggestViewIfNecessary(direction: .right)
            }
            self.getSuggestViewIfNecessary(direction: .bottom)
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}
