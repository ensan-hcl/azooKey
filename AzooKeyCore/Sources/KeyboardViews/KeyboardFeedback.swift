//
//  KeyboardFeedback.swift
//  Keyboard
//
//  Created by ensan on 2020/11/26.
//  Copyright © 2020 ensan. All rights reserved.
//

import func AudioToolbox.AudioServicesPlaySystemSound
import Foundation
import class UIKit.UIImpactFeedbackGenerator

/// フィードバックを返すためのツールセット
@MainActor public enum KeyboardFeedback<Extension: ApplicationSpecificKeyboardViewExtension> {
    private static var enableSound: Bool {
        Extension.SettingProvider.enableSound
    }
    private static var requestedHaptics: Bool {
        Extension.SettingProvider.enableHaptics
    }
    private static var enableHaptics: Bool {
        SemiStaticStates.shared.hapticsAvailable && SemiStaticStates.shared.hasFullAccess && requestedHaptics
    }
    // FIXME: possibly too heavy
    private static var  generator: UIImpactFeedbackGenerator { UIImpactFeedbackGenerator(style: .light) }

    // 使えそうな音
    /* i
     1103: 高いクリック音
     1104: 純正クリック音
     1105: 木の音っぽいクリック音
     1130: 空洞のある木を叩いたような音
     1131: 電話のキーのような音
     1261: なんかいい感じ
     1306: 純正クリック音
     1396,7: 軽め
     1522: なんかいい感じ。
     1420,1429: なんかいい感じ。
     1318まで試した
     */

    /// 入力を伴う操作を行う際にフィードバックを返します。
    /// - Note: 押しはじめに鳴らす方が反応が良く感じます。
    public static func click() {
        if enableSound {
            AudioServicesPlaySystemSound(1104)
        }
        if enableHaptics {
            generator.impactOccurred(intensity: 0.7)
        }
    }

    /// タブの移動、入力の確定、小仮名濁点化、カーソル移動などを伴う操作を行う際にフィードバックを返します。
    /// - Note: 押しはじめに鳴らす方が反応が良く感じます。
    public static func tabOrOtherKey() {
        if enableSound {
            AudioServicesPlaySystemSound(1156)
        }
        if enableHaptics {
            generator.impactOccurred(intensity: 0.75)
        }
    }

    /// 文字の削除などを伴う操作を行う際に音を鳴らします。
    /// - Note: 押しはじめに鳴らす方が反応が良く感じます。
    public static func delete() {
        if enableSound {
            AudioServicesPlaySystemSound(1155)
        }
        if enableHaptics {
            generator.impactOccurred(intensity: 0.75)
        }
    }

    /// 文字の一括削除の操作を行う際にフィードバックを返します。
    public static func smoothDelete() {
        if enableSound {
            AudioServicesPlaySystemSound(1105)
        }
        if enableHaptics {
            generator.impactOccurred(intensity: 0.8)
        }
    }

    /// 操作のリセットを行うときにフィードバックを返します。
    public static func reset() {
        if enableSound {
            AudioServicesPlaySystemSound(1533)
        }
        if enableHaptics {
            generator.impactOccurred(intensity: 1)
        }
    }
}
