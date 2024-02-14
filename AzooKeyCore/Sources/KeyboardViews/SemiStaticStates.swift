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
    public static let shared = SemiStaticStates()
    private init() {}

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

    private(set) public var keyboardHeightScale: CGFloat = 1

    /// - note: キーボードが開かれたタイミングで一度呼ぶのが望ましい。
    public func setKeyboardHeightScale(_ scale: CGFloat) {
        self.keyboardHeightScale = scale
    }
}
