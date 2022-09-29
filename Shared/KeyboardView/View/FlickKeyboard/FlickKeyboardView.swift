//
//  File.swift
//  Keyboard
//
//  Created by β α on 2020/04/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct FlickKeyboardView: View {
    private let tabDesign: TabDependentDesign
    private let keyModels: [[any FlickKeyModelProtocol]]
    init(keyModels: [[any FlickKeyModelProtocol]]) {
        self.keyModels = keyModels
        self.tabDesign = TabDependentDesign(width: 5, height: 4, layout: .flick, orientation: VariableStates.shared.keyboardOrientation)
    }

    private var horizontalIndices: Range<Int> {
        keyModels.indices
    }

    private func verticalIndices(h: Int) -> Range<Int> {
        keyModels[h].indices
    }

    private func keyView(h: Int, v: Int) -> FlickKeyView {
        let model = self.keyModels[h][v]
        let size: CGSize
        if model is FlickEnterKeyModel {
            size = CGSize(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight(heightCount: 2))
        } else {
            size = tabDesign.keyViewSize
        }
        return FlickKeyView(model: model, size: size)
    }

    private func suggestView(h: Int, v: Int) -> SuggestView {
        let model = self.keyModels[h][v]
        let size: CGSize
        if model is FlickEnterKeyModel {
            size = CGSize(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight(heightCount: 2))
        } else {
            size = tabDesign.keyViewSize
        }
        return SuggestView(model: model.suggestModel, tabDesign: tabDesign, size: size)
    }

    var body: some View {
        ZStack {
            HStack(spacing: tabDesign.horizontalSpacing) {
                ForEach(self.horizontalIndices, id: \.self) {h in
                    VStack(spacing: tabDesign.verticalSpacing) {
                        ForEach(self.verticalIndices(h: h), id: \.self) {(v: Int) -> FlickKeyView in
                            self.keyView(h: h, v: v)
                        }
                    }
                }
            }
            HStack(spacing: tabDesign.horizontalSpacing) {
                ForEach(self.horizontalIndices, id: \.self) {h in
                    VStack(spacing: tabDesign.verticalSpacing) {
                        ForEach(self.verticalIndices(h: h), id: \.self) {(v: Int) -> SuggestView in
                            self.suggestView(h: h, v: v)
                        }
                    }
                }
            }
        }
    }
}
