//
//  FlickKeyboardView.swift
//  Keyboard
//
//  Created by ensan on 2020/04/16.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

struct FlickKeyboardView: View {
    @State private var suggestState = FlickSuggestState()

    private let tabDesign: TabDependentDesign
    private let keyModels: [[any FlickKeyModelProtocol]]
    init(keyModels: [[any FlickKeyModelProtocol]], interfaceSize: CGSize, keyboardOrientation: KeyboardOrientation) {
        self.keyModels = keyModels
        self.tabDesign = TabDependentDesign(width: 5, height: 4, interfaceSize: interfaceSize, layout: .flick, orientation: keyboardOrientation)
    }

    private var horizontalIndices: Range<Int> {
        keyModels.indices
    }

    private func verticalIndices(h: Int) -> Range<Int> {
        keyModels[h].indices
    }

    @MainActor private func keyView(h: Int, v: Int) -> FlickKeyView {
        let model = self.keyModels[h][v]
        let size: CGSize
        if model is FlickEnterKeyModel {
            size = CGSize(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight(heightCount: 2))
        } else {
            size = tabDesign.keyViewSize
        }
        return FlickKeyView(model: model, size: size, position: (x: h, y: v), suggestState: $suggestState)
    }

    @MainActor
    private func suggestView(h: Int, v: Int, suggestType: FlickSuggestState.SuggestType) -> FlickSuggestView {
        let model = self.keyModels[h][v]
        let size: CGSize
        if model is FlickEnterKeyModel {
            size = CGSize(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight(heightCount: 2))
        } else {
            size = tabDesign.keyViewSize
        }
        return FlickSuggestView(model: model, tabDesign: tabDesign, size: size, suggestType: suggestType)
    }

    var body: some View {
        ZStack {
            HStack(spacing: tabDesign.horizontalSpacing) {
                ForEach(self.horizontalIndices, id: \.self) {h in
                    let columnSuggestStates = self.suggestState.items[h, default: [:]]
                    VStack(spacing: tabDesign.verticalSpacing) {
                        ForEach(self.verticalIndices(h: h), id: \.self) {v in
                            self.keyView(h: h, v: v)
                                .zIndex(columnSuggestStates[v] != nil ? 1 : 0)
                                .overlay(alignment: .center) {
                                    if let suggestType = columnSuggestStates[v] {
                                        suggestView(h: h, v: v, suggestType: suggestType)
                                            .zIndex(2)
                                    }
                                }
                        }
                    }
                    .zIndex(columnSuggestStates.isEmpty ? 0 : 1)
                }
            }
        }
    }
}
