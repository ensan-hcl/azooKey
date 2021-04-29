//
//  ColorTools.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/08.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum ColorTools {
    static func rgba(_ color: Color, process: (Double, Double, Double, Double) -> Color = {Color(hue: $0, saturation: $1, brightness: $2, opacity: $3)}) -> Color? {
        guard let rgba = color.cgColor?.components else {
            return nil
        }
        // R、GおよびBが0.0を最小量、1.0を最大値とする0.0から1.0の範囲にある
        let r = rgba[0]
        let g = rgba[1]
        let b = rgba[2]
        let a = rgba[3]
        return process(Double(r), Double(g), Double(b), Double(a))
    }

    static func hsv(_ color: Color, process: (Double, Double, Double, Double) -> Color = {Color(hue: $0, saturation: $1, brightness: $2, opacity: $3)}) -> Color? {
        guard let rgba = color.cgColor?.components else {
            return nil
        }
        // R、GおよびBが0.0を最小量、1.0を最大値とする0.0から1.0の範囲にある
        let r = rgba[0]
        let g = rgba[1]
        let b = rgba[2]
        let a = rgba[3]

        let maxValue = max(max(r, g), b)
        let minValue = min(min(r, g), b)
        let sub = maxValue - minValue

        var h: CGFloat = 0
        var s: CGFloat = 0
        var v: CGFloat = 0

        // Calculate Hue
        if sub == 0 {
            // MAX = MIN(例・S = 0)のとき、 Hは定義されない。
            h = 0
        } else {
            if maxValue == r {
                h = (60 * (g - b) / sub) + 0
            } else if maxValue == g {
                h = (60 * (b - r) / sub) + 120
            } else if maxValue == b {
                h = (60 * (r - g) / sub) + 240
            }
            // さらに H += 360 if H < 0
            if h < 0 {
                h += 360
            }
        }

        // Calculate Saturation
        if maxValue > 0 {
            s = sub / maxValue
        }

        // Calculate Value
        v = maxValue

        return process(Double(h / 360), Double(s), Double(v), Double(a))
    }

}
