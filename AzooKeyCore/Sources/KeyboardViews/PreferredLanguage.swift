//
//  PreferredLanguage.swift
//
//
//  Created by ensan on 2023/07/23.
//

import Foundation
import enum KanaKanjiConverterModule.KeyboardLanguage

public struct PreferredLanguage: Codable, Hashable, Sendable {
    public init(first: KeyboardLanguage, second: KeyboardLanguage?) {
        self.first = first
        self.second = second
    }

    public var first: KeyboardLanguage
    public var second: KeyboardLanguage?
}
