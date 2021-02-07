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
    private var selector: Selector?
    private var size: CGFloat

    init(selector: Selector? = nil, size: CGFloat){
        self.selector = selector
        self.size = size
    }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .custom)
        var weight: UIImage.SymbolWeight {
            switch VariableStates.shared.themeManager.theme.textFont{
            case .normal:
                return .light
            case .bold:
                return .semibold
            }
        }
        if let selector = selector{
            button.addTarget(nil, action: selector, for: .allTouchEvents)
        }
        let largeConfig = UIImage.SymbolConfiguration(pointSize: size, weight: weight, scale: .default)
        let largeBoldDoc = UIImage(systemName: "globe", withConfiguration: largeConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.setTitleColor(UIColor(VariableStates.shared.themeManager.theme.textColor), for: [.normal, .highlighted])
        button.tintColor = UIColor(VariableStates.shared.themeManager.theme.textColor)
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        return
    }
}
