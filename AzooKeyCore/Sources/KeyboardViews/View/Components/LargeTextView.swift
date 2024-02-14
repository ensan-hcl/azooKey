//
//  LargeTextView.swift
//  Keyboard
//
//  Created by ensan on 2020/09/21.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUIUtils

@MainActor
struct LargeTextView: View {
    private let text: String
    @Binding private var isViewOpen: Bool
    @EnvironmentObject private var variableStates: VariableStates

    init(text: String, isViewOpen: Binding<Bool>) {
        self.text = text
        self._isViewOpen = isViewOpen
    }

    private var font: Font {
        Font.system(
            size: Design.largeTextViewFontSize(
                text,
                upsideComponent: variableStates.upsideComponent,
                orientation: variableStates.keyboardOrientation,
                screenWidth: variableStates.screenWidth
            ),
            weight: .regular,
            design: .serif
        )
    }
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: true, content: {
                Text(text)
                    .font(font)
            })
            Button {
                isViewOpen = false
            } label: {
                Label("閉じる", systemImage: "xmark")
            }.frame(
                width: nil,
                height: Design.keyboardScreenHeight(
                    upsideComponent: variableStates.upsideComponent,
                    orientation: variableStates.keyboardOrientation,
                    screenWidth: variableStates.screenWidth
                ) * 0.15
            )
        }
        .background(Color.background)
        .frame(
            height: Design.keyboardScreenHeight(
                upsideComponent: variableStates.upsideComponent,
                orientation: variableStates.keyboardOrientation,
                screenWidth: variableStates.screenWidth
            ),
            alignment: .bottom
        )
    }
}
