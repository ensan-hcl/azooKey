//
//  CenterAlignedView.swift
//  MainApp
//
//  Created by ensan on 2020/11/19.
//  Copyright © 2020 ensan. All rights reserved.
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
        HStack {
            Spacer(minLength: padding)
            self.content()
            Spacer(minLength: padding)
        }
    }
}
