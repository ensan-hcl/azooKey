//
//  ChangeKeyboardButtonView.swift
//  Keyboard
//
//  Created by ensan on 2021/02/06.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

public struct ChangeKeyboardButtonView<Extension: ApplicationSpecificKeyboardViewExtension>: UIViewRepresentable {
    private let selector: Selector?
    private let size: CGFloat
    @Environment(Extension.Theme.self) private var theme

    public init(selector: Selector? = nil, size: CGFloat) {
        self.selector = selector
        self.size = size
    }

    private var weight: UIImage.SymbolWeight {
        switch theme.textFont {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case  .light, .regular:
            return .light
        case .medium:
            return .medium
        case .semibold, .bold:
            return .semibold
        case .heavy:
            return .heavy
        case .black:
            return .black
        }
    }

    public func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .custom)
        if let selector {
            button.addTarget(nil, action: selector, for: .allTouchEvents)
        }
        let largeConfig = UIImage.SymbolConfiguration(pointSize: size, weight: weight, scale: .default)
        let largeBoldDoc = UIImage(systemName: "globe", withConfiguration: largeConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.setTitleColor(UIColor(theme.textColor.color), for: [.normal, .highlighted])
        button.tintColor = UIColor(theme.textColor.color)
        return button
    }

    public func updateUIView(_ uiView: UIButton, context: Context) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: size, weight: weight, scale: .default)
        let largeBoldDoc = UIImage(systemName: "globe", withConfiguration: largeConfig)
        uiView.setImage(largeBoldDoc, for: .normal)
        uiView.setTitleColor(UIColor(theme.textColor.color), for: [.normal, .highlighted])
        uiView.tintColor = UIColor(theme.textColor.color)
    }
}
