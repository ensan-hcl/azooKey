//
//  CenterAlignedView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct CenterAlignedView<Content: View>: View {
    private let content: () -> Content
    private let padding: CGFloat?

    init(padding: CGFloat? = nil, @ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
        self.padding = padding
    }

    var body: some View {
        if let padding = padding {
            HStack {
                Spacer(minLength: padding)
                self.content()
                Spacer(minLength: padding)
            }
        } else {
            HStack {
                Spacer()
                self.content()
                Spacer()
            }
        }
    }
}
