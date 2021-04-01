//
//  GenericColorPicker.swift
//  KanaKanjier
//
//  Created by β α on 2021/03/01.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct GenericColorPicker<T>: View {
    private let titleKey: LocalizedStringKey
    private let supportsOpacity: Bool
    @Binding private var selection: T
    @State private var color: Color = Color.init(white: 1)

    private let process: (Color) -> T

    init(_ titleKey: LocalizedStringKey, selection: Binding<T>, supportsOpacity: Bool = true, initialValue: Color? = nil, convert process: @escaping (Color) -> T) {
        self.titleKey = titleKey
        self._selection = selection
        self.supportsOpacity = supportsOpacity
        self.process = process
        if let initialValue = initialValue {
            self._color = State(initialValue: initialValue)
        }
    }

    var body: some View {
        ColorPicker(titleKey, selection: $color, supportsOpacity: supportsOpacity)
            .onChange(of: color) {value in
                if value == color {
                    self.selection = process(value)
                }
            }
    }

}
