//
//  PasteButton.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/07.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct PasteButton: View {
    @Binding private var text: String

    init(_ text: Binding<String>) {
        self._text = text
    }

    var body: some View {
        Button {
            if let string = UIPasteboard.general.string {
                text = string
            }
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
    }
}

struct PasteLongPressButton: View {
    @Binding private var text: String

    init(_ text: Binding<String>) {
        self._text = text
    }

    var body: some View {
        Image(systemName: "doc.on.clipboard")
            .onLongPressGesture(minimumDuration: 0.5) {
                if let string = UIPasteboard.general.string {
                    Store.shared.feedbackGenerator.notificationOccurred(.success)
                    text = string
                }
            }
            .foregroundColor(.accentColor)
    }
}
