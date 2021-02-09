//
//  ChangeKeyboardButtonView.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct ChangeKeyboardButtonView: UIViewRepresentable {
    private let selector: Selector?
    private let size: CGFloat
    private let theme: ThemeData

    init(selector: Selector? = nil, size: CGFloat, theme: ThemeData){
        self.selector = selector
        self.size = size
        self.theme = theme
    }

    private var weight: UIImage.SymbolWeight {
        switch theme.textFont{
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

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .custom)
        if let selector = selector{
            button.addTarget(nil, action: selector, for: .allTouchEvents)
        }
        let largeConfig = UIImage.SymbolConfiguration(pointSize: size, weight: weight, scale: .default)
        let largeBoldDoc = UIImage(systemName: "globe", withConfiguration: largeConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.setTitleColor(UIColor(theme.textColor), for: [.normal, .highlighted])
        button.tintColor = UIColor(theme.textColor)
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: size, weight: weight, scale: .default)
        let largeBoldDoc = UIImage(systemName: "globe", withConfiguration: largeConfig)
        uiView.setImage(largeBoldDoc, for: .normal)
        uiView.setTitleColor(UIColor(theme.textColor), for: [.normal, .highlighted])
        uiView.tintColor = UIColor(theme.textColor)
    }
}
