//
//  IntegerTextField.swift
//  azooKey
//
//  Created by ensan on 2023/03/24.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

public struct IntegerTextField: View {
    public init(_ title: LocalizedStringKey, text: Binding<String>, range: ClosedRange<Int> = .min ... .max) {
        self.title = title
        self._text = text
        self.range = range
    }

    private let title: LocalizedStringKey
    private let range: ClosedRange<Int>
    @Binding private var text: String

    public var body: some View {
        HStack {
            TextField(title, text: $text)
                .onChange(of: text) { newValue in
                    if let value = Int(newValue) {
                        if range.upperBound < value {
                            text = "\(range.upperBound)"
                        } else if value < range.lowerBound {
                            text = "\(range.lowerBound)"
                        }
                    }
                }
            HStack(spacing: 0) {
                Button {
                    if let value = Int(text) {
                        if value == range.upperBound {
                            return
                        }
                        text = "\(value + 1)"
                    }
                } label: {
                    Label("1増やす", systemImage: "plus")
                        .padding(7)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                Button {
                    if let value = Int(text) {
                        if value == range.lowerBound {
                            return
                        }
                        text = "\(value - 1)"
                    }
                } label: {
                    Label("1減らす", systemImage: "minus")
                        .padding(7)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
            }
            .labelStyle(.iconOnly)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.systemGray5)
            }
        }
    }
}
