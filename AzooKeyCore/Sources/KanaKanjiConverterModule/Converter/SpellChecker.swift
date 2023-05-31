//
//  SpellChecker.swift
//
//
//  Created by ensan on 2023/05/20.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

final class SpellChecker {
    #if os(iOS) || os(tvOS)
    private let checker = UITextChecker()
    #elseif os(macOS)
    private let checker = NSSpellChecker.shared
    #endif

    func completions(forPartialWordRange range: NSRange, in string: String, language: String) -> [String]? {
        #if os(iOS) || os(tvOS)
        return checker.completions(forPartialWordRange: range, in: string, language: language)
        #elseif os(macOS)
        return checker.completions(forPartialWordRange: range, in: string, language: language, inSpellDocumentWithTag: 0)
        #endif
    }
}
