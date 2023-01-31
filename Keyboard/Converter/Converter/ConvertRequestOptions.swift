//
//  ConvertRequestOptions.swift
//  Keyboard
//
//  Created by ensan on 2022/12/20.
//  Copyright © 2022 ensan. All rights reserved.
//

import Foundation

struct ConvertRequestOptions {
    var N_best: Int = 10
    var requireJapanesePrediction: Bool = true
    var requireEnglishPrediction: Bool = true
    var keyboardLanguage: KeyboardLanguage = .ja_JP
    var mainInputStyle: InputStyle = .direct
    // KeyboardSettingのinjection用途
    var typographyLetterCandidate: Bool = TypographyLetter.defaultValue
    var unicodeCandidate: Bool = UnicodeCandidate.defaultValue
    var englishCandidateInRoman2KanaInput: Bool = EnglishCandidate.defaultValue
    var fullWidthRomanCandidate: Bool = FullRomanCandidate.defaultValue
    var halfWidthKanaCandidate: Bool = HalfKanaCandidate.defaultValue
    var learningType: LearningType = LearningTypeSetting.defaultValue
    var maxMemoryCount: Int = 8192
}
