//
//  SemiStaticStates.swift
//  azooKey
//
//  Created by ensan on 2022/12/18.
//  Copyright © 2022 ensan. All rights reserved.
//

import Foundation
import SwiftUI

/// 実行しないと値が確定しないが、実行されれば全く変更されない値。収容アプリでも共有できる形にすること。
final class SemiStaticStates {
    static let shared = SemiStaticStates()
    private init() {}

    private(set) var needsInputModeSwitchKey = true // 端末が変化しない限り変更が必要ない
    func setNeedsInputModeSwitchKeyMode(_ bool: Bool) {
        self.needsInputModeSwitchKey = bool
    }

    /// - do not  consider using screenHeight
    /// - スクリーンそのもののサイズ。キーボードビューの幅は片手モードなどによって変更が生じうるため、`screenWidth`は限定的な場面でのみ使うことが望まし。
    private(set) var screenWidth: CGFloat = .zero
    private(set) var screenHeight: CGFloat = .zero

    /// Function to set the size of keyboard
    /// - Parameter size: only `size.width` used, and `size.height` has almost no needs, but using a bit.
    /// - 副作用として、この関数はデバイスの向きを決定し、UIのサイズを調整する。
    func setScreenSize(size: CGSize, orientation: KeyboardOrientation? = nil) {
        if self.screenWidth == size.width && orientation == VariableStates.shared.keyboardOrientation {
            return
        }
        if let orientation {
            VariableStates.shared.setOrientation(orientation)
        } else {
            VariableStates.shared.setOrientation(UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height ? .vertical : .horizontal)
        }
        let width = size.width
        self.screenWidth = width
        // screenWidthを更新してからDesign.keyboardHeightを呼ぶ必要がある。
        // あまりいいデザインではない・・・。
        let height = Design.keyboardHeight(screenWidth: width)
        self.screenHeight = height
        debug("SemiStaticStates setScreenSize", width, height)
        let (layout, orientation) = (layout: VariableStates.shared.keyboardLayout, orientation: VariableStates.shared.keyboardOrientation)

        // 片手モードの処理
        KeyboardInternalSetting.shared.update(\.oneHandedModeSetting) {value in
            value.setIfFirst(layout: layout, orientation: orientation, size: .init(width: width, height: height), position: .zero)
        }
        switch VariableStates.shared.resizingState {
        case .fullwidth:
            VariableStates.shared.interfaceSize = CGSize(width: width, height: height)
        case .onehanded, .resizing:
            let item = KeyboardInternalSetting.shared.oneHandedModeSetting.item(layout: layout, orientation: orientation)
            // 安全のため、指示されたwidth, heightを超える値を許可しない。
            VariableStates.shared.interfaceSize = CGSize(width: min(width, item.size.width), height: min(height, item.size.height))
            VariableStates.shared.interfacePosition = item.position
        }
    }
}
