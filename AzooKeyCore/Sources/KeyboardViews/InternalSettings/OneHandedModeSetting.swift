//
//  OneHandedModeSetting.swift
//  azooKey
//
//  Created by ensan on 2021/03/12.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUIUtils

public struct OneHandedModeSetting: Sendable, Codable, StaticInitialValueAvailable {
    public static let initialValue = Self()

    // v3.1+: レイアウトに依存せず、向きごとに保持
    private(set) var vertical = OneHandedModeSettingItem()
    private(set) var horizontal = OneHandedModeSettingItem()
    private(set) var verticalHeight = OneHandedModeHeightSettingItem()
    private(set) var horizontalHeight = OneHandedModeHeightSettingItem()

    private func keyPath(orientation: KeyboardOrientation) -> WritableKeyPath<Self, OneHandedModeSettingItem> {
        switch orientation {
        case .vertical: return \.vertical
        case .horizontal: return \.horizontal
        }
    }

    public func item(orientation: KeyboardOrientation) -> OneHandedModeSettingItem {
        self[keyPath: keyPath(orientation: orientation)]
    }

    public func heightItem(orientation: KeyboardOrientation) -> OneHandedModeHeightSettingItem {
        switch orientation {
        case .vertical:
            self.verticalHeight
        case .horizontal:
            self.horizontalHeight
        }
    }

    public func bottomOffset(orientation: KeyboardOrientation) -> CGFloat {
        max(0, heightItem(orientation: orientation).bottomOffset ?? 0)
    }

    mutating func update(orientation: KeyboardOrientation, process: (inout OneHandedModeSettingItem) -> Void) {
        process(&self[keyPath: keyPath(orientation: orientation)])
    }

    mutating func set(orientation: KeyboardOrientation, size: CGSize, position: CGPoint, bottomOffset: CGFloat) {
        self[keyPath: keyPath(orientation: orientation)].hasUsed = true
        self[keyPath: keyPath(orientation: orientation)].width = size.width
        self[keyPath: keyPath(orientation: orientation)].position = CGPoint(x: position.x, y: 0)
        switch orientation {
        case .vertical:
            self.verticalHeight.height = size.height
            self.verticalHeight.bottomOffset = max(0, bottomOffset)
        case .horizontal:
            self.horizontalHeight.height = size.height
            self.horizontalHeight.bottomOffset = max(0, bottomOffset)
        }
    }

    mutating func setIfFirst(orientation: KeyboardOrientation, size: CGSize, position: CGPoint, forced: Bool = false) {
        if !self[keyPath: keyPath(orientation: orientation)].hasUsed || forced {
            self[keyPath: keyPath(orientation: orientation)].hasUsed = true
            self[keyPath: keyPath(orientation: orientation)].width = size.width
            self[keyPath: keyPath(orientation: orientation)].position = position
        }
        switch orientation {
        case .vertical:
            if self.verticalHeight.height == nil {
                self.verticalHeight.height = size.height
            }
            if self.verticalHeight.bottomOffset == nil {
                self.verticalHeight.bottomOffset = 0
            }
        case .horizontal:
            if self.horizontalHeight.height == nil {
                self.horizontalHeight.height = size.height
            }
            if self.horizontalHeight.bottomOffset == nil {
                self.horizontalHeight.bottomOffset = 0
            }
        }
    }

    mutating func reset(orientation: KeyboardOrientation) {
        // 対応する設定項目に、新しい空のインスタンスを代入して上書きする
        // これにより、hasUsedフラグもfalseに戻るため、setIfFirstが機能するようになる
        // userHasOverwrittenKeyboardHeightSettingについては、明示的なリセット操作が行われている以上、trueにしてしまってよい
        self[keyPath: keyPath(orientation: orientation)] = OneHandedModeSettingItem()
        switch orientation {
        case .vertical:
            self.verticalHeight = .init(height: nil, userHasOverwrittenKeyboardHeightSetting: true)
        case .horizontal:
            self.horizontalHeight = .init(height: nil, userHasOverwrittenKeyboardHeightSetting: true)
        }
    }

    mutating func setUserHasOverwrittenKeyboardHeightSetting(orientation: KeyboardOrientation) {
        switch orientation {
        case .vertical:
            self.verticalHeight.userHasOverwrittenKeyboardHeightSetting = true
        case .horizontal:
            self.horizontalHeight.userHasOverwrittenKeyboardHeightSetting = true
        }
    }

}

// MARK: - Backward compatible decoding (merge per-layout -> per-orientation)
extension OneHandedModeSetting {
    private enum CodingKeys: String, CodingKey {
        case vertical
        case horizontal
        case verticalHeight
        case horizontalHeight
        // legacy keys (<= v2.5)
        case flick_vertical
        case flick_horizontal
        case qwerty_vertical
        case qwerty_horizontal
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // New keys exist → decode straightforwardly
        if container.contains(.vertical) || container.contains(.horizontal) {
            self.vertical = try container.decodeIfPresent(OneHandedModeSettingItem.self, forKey: .vertical) ?? .init()
            self.horizontal = try container.decodeIfPresent(OneHandedModeSettingItem.self, forKey: .horizontal) ?? .init()
            self.verticalHeight = try container.decodeIfPresent(OneHandedModeHeightSettingItem.self, forKey: .verticalHeight) ?? .init()
            self.horizontalHeight = try container.decodeIfPresent(OneHandedModeHeightSettingItem.self, forKey: .horizontalHeight) ?? .init()
            return
        }

        // Legacy decoding: merge per-layout items into per-orientation
        let flickV = try container.decodeIfPresent(OneHandedModeSettingItem.self, forKey: .flick_vertical) ?? .init()
        let flickH = try container.decodeIfPresent(OneHandedModeSettingItem.self, forKey: .flick_horizontal) ?? .init()
        let qwertyV = try container.decodeIfPresent(OneHandedModeSettingItem.self, forKey: .qwerty_vertical) ?? .init()
        let qwertyH = try container.decodeIfPresent(OneHandedModeSettingItem.self, forKey: .qwerty_horizontal) ?? .init()

        // Prefer entries that were actually used; fall back to the other layout
        self.vertical = qwertyV.hasUsed ? qwertyV : flickV
        self.horizontal = qwertyH.hasUsed ? qwertyH : flickH

        self.verticalHeight = try container.decodeIfPresent(OneHandedModeHeightSettingItem.self, forKey: .verticalHeight) ?? .init()
        self.horizontalHeight = try container.decodeIfPresent(OneHandedModeHeightSettingItem.self, forKey: .horizontalHeight) ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.vertical, forKey: .vertical)
        try container.encode(self.horizontal, forKey: .horizontal)
        try container.encode(self.verticalHeight, forKey: .verticalHeight)
        try container.encode(self.horizontalHeight, forKey: .horizontalHeight)
    }
}

public struct OneHandedModeSettingItem: Sendable, Codable {
    // 最後の状態がOneHandedModeだったかどうか
    var isLastOnehandedMode: Bool = false
    // 使われたことがあるか
    var hasUsed: Bool = false
    // データ
    var width: CGFloat = .zero
    var position: CGPoint = .zero
}

/// v2.5で導入。
public struct OneHandedModeHeightSettingItem: Sendable, Codable {
    var height: CGFloat?
    /// キー領域とキーボード下端の間に確保する余白。nilは旧バージョンの保存値を表す。
    var bottomOffset: CGFloat?
    /// 片手モードの高さスケール設定（v2.4.2まで存在）に対して片手モード上の高さ設定を優先させるか判定するための値。
    public var userHasOverwrittenKeyboardHeightSetting: Bool = false
}
