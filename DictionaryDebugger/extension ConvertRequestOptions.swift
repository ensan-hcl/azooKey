//
//  extension ConvertRequestOptions.swift
//  DictionaryDebugger
//
//  Created by β α on 2023/05/27.
//  Copyright © 2023 DevEn3. All rights reserved.
//

import Foundation
import KanaKanjiConverterModule

extension ConvertRequestOptions {
    static var appDefault: Self {
        .init(requireJapanesePrediction: false, requireEnglishPrediction: false, keyboardLanguage: .ja_JP, englishCandidateInRoman2KanaInput: false, halfWidthKanaCandidate: false, learningType: .nothing, dictionaryResourceURL: Bundle.main.bundleURL.appending(path: "Dictionary", directoryHint: .isDirectory), memoryDirectoryURL: Bundle.main.bundleURL, sharedContainerURL: Bundle.main.bundleURL, metadata: .init(appVersionString: "DictionaryDebugger"))
    }
}
