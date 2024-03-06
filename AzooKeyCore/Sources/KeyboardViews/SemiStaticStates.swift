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
public final class SemiStaticStates {
    @MainActor public static let shared = SemiStaticStates()
    @MainActor private init() {}

    // MARK: 端末依存の値
    @MainActor private(set) public lazy var needsInputModeSwitchKey = {
        UIInputViewController().needsInputModeSwitchKey
    }()
    private(set) public lazy var hapticsAvailable = false

    @MainActor public func setNeedsInputModeSwitchKey(_ bool: Bool) {
        self.needsInputModeSwitchKey = bool
    }

    public func setHapticsAvailable() {
        self.hapticsAvailable = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    // MARK: 「キーボードを開く」—「キーボードを閉じる」の動作の間に変更しない値
    @MainActor private(set) public var hasFullAccess = {
        UIInputViewController().hasFullAccess
    }()

    @MainActor public func setHasFullAccess(_ bool: Bool) {
        self.hasFullAccess = bool
    }

    /// - do not  consider using screenHeight
    /// - スクリーンそのもののサイズ。キーボードビューの幅は片手モードなどによって変更が生じうるため、`screenWidth`は限定的な場面でのみ使うことが望まし。
    private(set) public var screenWidth: CGFloat = 0
    private(set) public var keyboardHeightScale: CGFloat = 1

    /// - note: キーボードが開かれたタイミングで一度呼ぶのが望ましい。
    public func setKeyboardHeightScale(_ scale: CGFloat) {
        self.keyboardHeightScale = scale
    }

    /// Function to set the width of area of keyboard
    /// - Parameter width: 使用可能な領域の幅.
    public func setScreenWidth(_ width: CGFloat) {
        self.screenWidth = width
    }
}
