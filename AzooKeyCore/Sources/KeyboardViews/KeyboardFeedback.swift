//
//  KeyboardFeedback.swift
//  Keyboard
//
//  Created by ensan on 2020/11/26.
//  Copyright © 2020 ensan. All rights reserved.
//

import func AudioToolbox.AudioServicesPlaySystemSound
import typealias AudioToolbox.SystemSoundID
import class UIKit.UIImpactFeedbackGenerator

/// フィードバックを返すためのツールセット
public enum KeyboardFeedback<Extension: ApplicationSpecificKeyboardViewExtension> {
    @MainActor
    private static var enableSound: Bool {
        Extension.SettingProvider.enableSound
    }
    @MainActor
    private static var requestedHaptics: Bool {
        Extension.SettingProvider.enableHaptics
    }
    @MainActor
    private static var enableHaptics: Bool {
        SemiStaticStates.shared.hapticsAvailable && SemiStaticStates.shared.hasFullAccess && requestedHaptics
    }
    // FIXME: possibly too heavy
    @MainActor
    private static var generator: UIImpactFeedbackGenerator { UIImpactFeedbackGenerator(style: .light) }

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
        playSystemSound(1104)
        impactOnMainActor(intensity: 0.7)
    }

    /// タブの移動、入力の確定、小仮名濁点化、カーソル移動などを伴う操作を行う際にフィードバックを返します。
    /// - Note: 押しはじめに鳴らす方が反応が良く感じます。
    public static func tabOrOtherKey() {
        playSystemSound(1156)
        impactOnMainActor(intensity: 0.75)
    }

    /// 文字の削除などを伴う操作を行う際に音を鳴らします。
    /// - Note: 押しはじめに鳴らす方が反応が良く感じます。
    public static func delete() {
        playSystemSound(1155)
        impactOnMainActor(intensity: 0.75)
    }

    /// 文字の一括削除の操作を行う際にフィードバックを返します。
    public static func smoothDelete() {
        playSystemSound(1105)
        impactOnMainActor(intensity: 0.8)
    }

    /// 操作のリセットを行うときにフィードバックを返します。
    public static func reset() {
        playSystemSound(1533)
        impactOnMainActor(intensity: 1)
    }

    /// systemSoundの再生のラッパー
    /// - Note: `generator.impactOccurred`はMainActor上でのみ動作する
    public static func impactOnMainActor(intensity: Double) {
        Task { @MainActor in
            if enableHaptics {
                generator.impactOccurred(intensity: intensity)
            }
        }
    }

    /// systemSoundの再生のラッパー
    /// - Note: `AudioServicesPlaySystemSound`は非同期で呼び出さないと爆音が鳴ることがある
    public static func playSystemSound(_ id: SystemSoundID) {
        Task {
            if await enableSound {
                // 再生自体は非同期で実行される
                AudioServicesPlaySystemSound(id)
            }
        }
    }
}
