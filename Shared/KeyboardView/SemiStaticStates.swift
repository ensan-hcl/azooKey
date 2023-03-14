//
//  SemiStaticStates.swift
//  azooKey
//
//  Created by ensan on 2022/12/18.
//  Copyright © 2022 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import class CoreHaptics.CHHapticEngine

/// 実行しないと値が確定しないが、実行されれば全く変更されない値。収容アプリでも共有できる形にすること。
final class SemiStaticStates {
    static let shared = SemiStaticStates()
    private init() {}

    // MARK: 端末依存の値
    private(set) var needsInputModeSwitchKey = true
    private(set) var hapticsAvailable = false

    func setNeedsInputModeSwitchKey(_ bool: Bool? = nil) {
        if let bool {
            self.hasFullAccess = bool
        } else {
            self.hasFullAccess = UIInputViewController().needsInputModeSwitchKey
        }
    }

    func setHapticsAvailable() {
        self.hapticsAvailable = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    // MARK: 「キーボードを開く」—「キーボードを閉じる」の動作の間に変更しない値
    private(set) var hasFullAccess = false
    func setHasFullAccess(_ bool: Bool? = nil) {
        if let bool {
            self.hasFullAccess = bool
        } else {
            self.hasFullAccess = UIInputViewController().hasFullAccess
        }
    }

    /// - do not  consider using screenHeight
    /// - スクリーンそのもののサイズ。キーボードビューの幅は片手モードなどによって変更が生じうるため、`screenWidth`は限定的な場面でのみ使うことが望まし。
    private(set) var screenWidth: CGFloat = .zero
    private(set) var keyboardHeightScale: CGFloat = 1

    /// - note: キーボードが開かれたタイミングで一度呼ぶのが望ましい。
    func setKeyboardHeightScale(_ scale: CGFloat) {
        self.keyboardHeightScale = scale
    }

    /// Function to set the width of area of keyboard
    /// - Parameter width: 使用可能な領域の幅.
    /// - 副作用として、この関数はデバイスの向きを決定し、UIのサイズを調整する。
    func setScreenWidth(_ width: CGFloat, orientation: KeyboardOrientation? = nil) {
        if self.screenWidth == width && orientation == VariableStates.shared.keyboardOrientation {
            return
        }
        if let orientation {
            VariableStates.shared.setOrientation(orientation)
        } else {
            VariableStates.shared.setOrientation(UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height ? .vertical : .horizontal)
        }
        self.screenWidth = width
        // screenWidthを更新してからDesign.keyboardHeightを呼ぶ必要がある。
        // あまりいいデザインではない・・・。
        let height = Design.keyboardHeight(screenWidth: width)
        debug("SemiStaticStates setScreenWidth", width, height)
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
