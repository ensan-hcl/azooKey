//
//  SuggestView.swift
//  azooKey
//
//  Created by ensan on 2020/04/10.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

struct FlickSuggestState {
    enum SuggestType {
        case all
        case flick(FlickDirection)
    }
    var items: [Int: [Int: SuggestType]] = [:]
}

struct FlickSuggestView: View {
    @Environment(\.themeEnvironment) private var theme
    private let model: SuggestModel
    private let suggestType: FlickSuggestState.SuggestType
    private let tabDesign: TabDependentDesign
    private let size: CGSize

    init(model: SuggestModel, tabDesign: TabDependentDesign, size: CGSize, suggestType: FlickSuggestState.SuggestType) {
        self.model = model
        self.tabDesign = tabDesign
        self.size = size
        self.suggestType = suggestType
    }

    private func neededAppearView(direction: FlickDirection) -> some View {
        if case .flick(direction) = self.suggestType {
            if let model = self.model.flickModels[direction] {
                return model.getSuggestView(size: size, isHidden: false, isPointed: true, theme: theme)
            } else {
                return FlickedKeyModel.zero.getSuggestView(size: size, isHidden: true, theme: theme)
            }
        }
        if case .all = self.suggestType {
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
            self.neededAppearView(direction: .top)
            HStack(spacing: tabDesign.horizontalSpacing) {
                self.neededAppearView(direction: .left)
                RoundedRectangle(cornerRadius: 5.0)
                    .strokeAndFill(
                        fillContent: theme.specialKeyFillColor.color,
                        strokeContent: theme.borderColor.color,
                        lineWidth: theme.borderWidth
                    )
                    .frame(width: size.width, height: size.height)
                self.neededAppearView(direction: .right)
            }
            self.neededAppearView(direction: .bottom)
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }
}
