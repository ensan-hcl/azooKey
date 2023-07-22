//
//  EmojiTabExpandModePreference.swift
//  azooKey
//
//  Created by ensan on 2023/03/19.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation
import SwiftUtils

/// 絵文字等のタブで、表示する文字に関する設定を記述する
public struct EmojiTabExpandModePreference: Codable, StaticInitialValueAvailable {
    public static let initialValue = Self()
    var level: Level = .medium
    enum Level: String, Codable {
        case small
        case medium
        case large
    }
}
