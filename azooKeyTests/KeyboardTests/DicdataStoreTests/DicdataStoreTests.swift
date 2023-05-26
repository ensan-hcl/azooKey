//
//  DicdataStoreTests.swift
//  azooKeyTests
//
//  Created by ensan on 2023/02/09.
//  Copyright © 2023 ensan. All rights reserved.
//

import XCTest
import KanaKanjiConverterModule
import KanaKanjiConverterResource

final class DicdataStoreTests: XCTestCase {
    func sequentialInput(_ composingText: inout ComposingText, sequence: String, inputStyle: KanaKanjiConverterModule.InputStyle) {
        for char in sequence {
            composingText.insertAtCursorPosition(String(char), inputStyle: inputStyle)
        }
    }

    func requestOptions() -> ConvertRequestOptions {
        ConvertRequestOptions(
            N_best: 5,
            requireJapanesePrediction: true,
            requireEnglishPrediction: false,
            keyboardLanguage: .ja_JP,
            typographyLetterCandidate: false,
            unicodeCandidate: true,
            englishCandidateInRoman2KanaInput: true,
            fullWidthRomanCandidate: false,
            halfWidthKanaCandidate: false,
            learningType: .nothing,
            maxMemoryCount: 0,
            shouldResetMemory: false,
            dictionaryResourceURL: KanaKanjiConverterResourceURL.url.appendingPathComponent("Dictionary", isDirectory: true),
            memoryDirectoryURL: URL(fileURLWithPath: ""),
            sharedContainerURL: URL(fileURLWithPath: ""),
            metadata: .init(appVersionString: "Tests")
        )
    }

    /// 絶対に変換できるべき候補をここに記述する
    ///  - 主に「変換できない」と報告のあった候補を追加する
    func testMustWords() throws {
        let dicdataStore = DicdataStore(convertRequestOptions: requestOptions())
        let mustWords = [
            ("アサッテ", "明後日"),
            ("ダイヒョウ", "代表"),
            ("テキナ", "的な"),
            ("ヤマダ", "山田"),
            ("アイロ", "隘路"),
            ("ナンタイ", "軟体"),
            ("ナンジ", "何時"),
            ("ナド", "等"),
        ]
        for (key, word) in mustWords {
            var c = ComposingText()
            c.insertAtCursorPosition(key, inputStyle: .direct)
            let result = dicdataStore.getLOUDSData(inputData: c, from: 0, to: c.input.endIndex-1)
            // 冗長な書き方だが、こうすることで「どの項目でエラーが発生したのか」がはっきりするため、こう書いている。
            XCTAssertEqual(result.first(where: {$0.data.word == word})?.data.word, word)
        }
    }

    /// 入っていてはおかしい候補をここに記述する
    ///  - 主に以前混入していたが取り除いた語を記述する
    func testMustNotWords() throws {
        let dicdataStore = DicdataStore(convertRequestOptions: requestOptions())
        let mustWords = [
            ("タイ", "体."),
            ("アサッテ", "明日"),
            ("チョ", "ちょwww"),
            ("a", "あ"),   // direct入力の場合「a」で「あ」をサジェストしてはいけない
        ]
        for (key, word) in mustWords {
            var c = ComposingText()
            c.insertAtCursorPosition(key, inputStyle: .direct)
            let result = dicdataStore.getLOUDSData(inputData: c, from: 0, to: c.input.endIndex-1)
            XCTAssertNil(result.first(where: {$0.data.word == word && $0.data.ruby == key}))
        }
    }

    func testGetLOUDSDataInRange() throws {
        let dicdataStore = DicdataStore(convertRequestOptions: requestOptions())
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("ヘンカン", inputStyle: .roman2kana)
            let result = dicdataStore.getLOUDSDataInRange(inputData: c, from: 0, toIndexRange: 2..<4)
            XCTAssertFalse(result.contains(where: {$0.data.word == "変"}))
            XCTAssertTrue(result.contains(where: {$0.data.word == "変化"}))
            XCTAssertTrue(result.contains(where: {$0.data.word == "変換"}))
        }
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("ヘンカン", inputStyle: .roman2kana)
            let result = dicdataStore.getLOUDSDataInRange(inputData: c, from: 0, toIndexRange: 0..<4)
            XCTAssertTrue(result.contains(where: {$0.data.word == "変"}))
            XCTAssertTrue(result.contains(where: {$0.data.word == "変化"}))
            XCTAssertTrue(result.contains(where: {$0.data.word == "変換"}))
        }
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("ツカッ", inputStyle: .roman2kana)
            let result = dicdataStore.getLOUDSDataInRange(inputData: c, from: 0, toIndexRange: 2..<3)
            XCTAssertTrue(result.contains(where: {$0.data.word == "使っ"}))
        }
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("ツカッt", inputStyle: .roman2kana)
            let result = dicdataStore.getLOUDSDataInRange(inputData: c, from: 0, toIndexRange: 2..<4)
            XCTAssertTrue(result.contains(where: {$0.data.word == "使っ"}))
        }
        do {
            var c = ComposingText()
            sequentialInput(&c, sequence: "tukatt", inputStyle: .roman2kana)
            let result = dicdataStore.getLOUDSDataInRange(inputData: c, from: 0, toIndexRange: 4..<6)
            XCTAssertTrue(result.contains(where: {$0.data.word == "使っ"}))
        }
    }
}
