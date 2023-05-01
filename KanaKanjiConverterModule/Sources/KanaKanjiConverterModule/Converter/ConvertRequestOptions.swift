//
//  ConvertRequestOptions.swift
//  Keyboard
//
//  Created by ensan on 2022/12/20.
//  Copyright © 2022 ensan. All rights reserved.
//

import Foundation

public struct ConvertRequestOptions {
    public init(N_best: Int, requireJapanesePrediction: Bool, requireEnglishPrediction: Bool, keyboardLanguage: KeyboardLanguage, typographyLetterCandidate: Bool, unicodeCandidate: Bool, englishCandidateInRoman2KanaInput: Bool, fullWidthRomanCandidate: Bool, halfWidthKanaCandidate: Bool, learningType: LearningType, maxMemoryCount: Int, shouldResetMemory: Bool, memoryDirectoryURL: URL, sharedContainerURL: URL, metadata: ConvertRequestOptions.Metadata) {
        self.N_best = N_best
        self.requireJapanesePrediction = requireJapanesePrediction
        self.requireEnglishPrediction = requireEnglishPrediction
        self.keyboardLanguage = keyboardLanguage
        self.typographyLetterCandidate = typographyLetterCandidate
        self.unicodeCandidate = unicodeCandidate
        self.englishCandidateInRoman2KanaInput = englishCandidateInRoman2KanaInput
        self.fullWidthRomanCandidate = fullWidthRomanCandidate
        self.halfWidthKanaCandidate = halfWidthKanaCandidate
        self.learningType = learningType
        self.maxMemoryCount = maxMemoryCount
        self.shouldResetMemory = shouldResetMemory
        self.memoryDirectoryURL = memoryDirectoryURL
        self.sharedContainerURL = sharedContainerURL
        self.metadata = metadata
        // fixed
        self.bundleURL = Bundle.module.bundleURL
    }

    public var N_best: Int
    public var requireJapanesePrediction: Bool
    public var requireEnglishPrediction: Bool
    public var keyboardLanguage: KeyboardLanguage
    // KeyboardSettingのinjection用途
    public var typographyLetterCandidate: Bool
    public var unicodeCandidate: Bool
    public var englishCandidateInRoman2KanaInput: Bool
    public var fullWidthRomanCandidate: Bool
    public var halfWidthKanaCandidate: Bool
    public var learningType: LearningType
    public var maxMemoryCount: Int
    public var shouldResetMemory: Bool
    // ディレクトリなど
    public var memoryDirectoryURL: URL
    public var sharedContainerURL: URL
    public var bundleURL: URL
    // メタデータ
    public var metadata: Metadata

    static var `default`: Self {
        Self(
            N_best: 10,
            requireJapanesePrediction: true,
            requireEnglishPrediction: true,
            keyboardLanguage: .ja_JP,
            typographyLetterCandidate: false,
            unicodeCandidate: true,
            englishCandidateInRoman2KanaInput: true,
            fullWidthRomanCandidate: true,
            halfWidthKanaCandidate: false,
            learningType: .inputAndOutput,
            maxMemoryCount: 65536,
            shouldResetMemory: false,
            memoryDirectoryURL: (try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)) ?? Bundle.module.bundleURL,
            sharedContainerURL: Bundle.module.bundleURL,
            metadata: Metadata(appVersionString: "Unknown")
        )
    }

    public struct Metadata {
        public init(appVersionString: String) {
            self.appVersionString = appVersionString
        }
        var appVersionString: String
    }
}
