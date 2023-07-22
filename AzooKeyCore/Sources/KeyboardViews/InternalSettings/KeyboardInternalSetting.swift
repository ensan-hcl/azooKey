//
//  KeyboardInternalSetting.swift
//
//
//  Created by ensan on 2023/07/21.
//

import Foundation
import SwiftUtils

public struct KeyboardInternalSetting: UserDefaultsManager {
    public static var shared = Self()

    public enum Keys: String, UserDefaultsKeys {
        public typealias Manager = KeyboardInternalSetting
        case one_handed_mode_setting
        case tab_character_preference
        case emoji_tab_expand_mode_preference

        public init(keyPath: PartialKeyPath<Manager>) {
            switch keyPath {
            case \Manager.oneHandedModeSetting:
                self = .one_handed_mode_setting
            case \Manager.tabCharacterPreference:
                self = .tab_character_preference
            case \Manager.emojiTabExpandModePreference:
                self = .emoji_tab_expand_mode_preference
            default:
                fatalError("Unknown Key Path: \(keyPath)")
            }
        }
    }

    private(set) public var oneHandedModeSetting: OneHandedModeSetting = Self.load(key: .one_handed_mode_setting)
    private(set) public var tabCharacterPreference: TabCharacterPreference = Self.load(key: .tab_character_preference)
    private(set) public var emojiTabExpandModePreference: EmojiTabExpandModePreference = Self.load(key: .emoji_tab_expand_mode_preference)
}
