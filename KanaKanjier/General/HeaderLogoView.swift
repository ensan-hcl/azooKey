//
//  HeaderIconView.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct HeaderLogoView: View {
    @Environment(\.colorScheme) private var colorScheme

    enum Size {
        case normal
        case large
    }

    private let size: Size

    init(size: Size = .normal) {
        self.size = size
    }

    private var iconColor: Color {
        return Color("IconColor")
    }

    private var iconSize: CGFloat {
        switch self.size {
        case .normal:
            return 40
        case .large:
            return 60
        }
    }

    var body: some View {
        Group {
            if let font30 = Design.fonts.azooKeyIconFont(iconSize * 0.75) {
                switch colorScheme {
                case .light:
                    Text("A")
                        .font(font30)
                case .dark:
                    Text("B")
                        .font(font30)
                @unknown default:
                    Text("azooKey")
                        .font(Font(UIFont.systemFont(ofSize: 30)))
                }
            } else {
                Text("azooKey")
                    .font(Font(UIFont.systemFont(ofSize: 30)))
            }
        }
        .foregroundColor(iconColor)
        .padding(.top, 10)
        .padding(.bottom, -5)
    }
}
