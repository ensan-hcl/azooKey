//
//  LargeTextView.swift
//  Keyboard
//
//  Created by ensan on 2020/09/21.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct LargeTextView: View {
    private let text: String
    @Binding private var isViewOpen: Bool

    init(text: String, isViewOpen: Binding<Bool>) {
        self.text = text
        self._isViewOpen = isViewOpen
    }

    private var font: Font {
        Font.system(size: Design.largeTextViewFontSize(text), weight: .regular, design: .serif)
    }
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: true, content: {
                Text(text)
                    .font(font)
            })
            Button(action: {
                isViewOpen = false
            }) {
                Image(systemName: "xmark")
                Text("閉じる")
                    .font(.body)
            }.frame(width: nil, height: Design.keyboardScreenHeight * 0.15)
        }
        .background(Color.background)
        .frame(height: Design.keyboardScreenHeight, alignment: .bottom)
    }
}
