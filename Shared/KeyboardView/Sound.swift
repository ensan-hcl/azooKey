//
//  Sound.swift
//  Keyboard
//
//  Created by β α on 2020/11/26.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import AudioToolbox

/// 音を鳴らすためのツールセット
enum Sound {
    @KeyboardSetting(.enableKeySound) private static var enableSound
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

    /// 入力を伴う操作を行う際に音を鳴らします。
    /// - Note: 押しはじめに鳴らす方が反応が良く感じます。
    static func click() {
        if enableSound {
            AudioServicesPlaySystemSound(1104)
        }
    }

    /// タブの移動、入力の確定、小仮名濁点化、カーソル移動などを伴う操作を行う際に音を鳴らします。
    /// - Note: 押しはじめに鳴らす方が反応が良く感じます。
    static func tabOrOtherKey() {
        if enableSound {
            AudioServicesPlaySystemSound(1156)
        }
    }

    /// 文字の削除などを伴う操作を行う際に音を鳴らします。
    /// - Note: 押しはじめに鳴らす方が反応が良く感じます。
    static func delete() {
        if enableSound {
            AudioServicesPlaySystemSound(1155)
        }
    }

    /// 文字の一括削除の操作を行う際に音を鳴らします。
    static func smoothDelete() {
        if enableSound {
            AudioServicesPlaySystemSound(1105)
        }
    }

    /// 操作のリセットを行うときに音を鳴らします。
    static func reset() {
        if enableSound {
            AudioServicesPlaySystemSound(1533)
        }
    }
}
