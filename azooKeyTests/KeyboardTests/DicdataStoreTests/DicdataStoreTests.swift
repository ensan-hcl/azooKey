//
//  DicdataStoreTests.swift
//  azooKeyTests
//
//  Created by ensan on 2023/02/09.
//  Copyright © 2023 ensan. All rights reserved.
//

import XCTest

final class DicdataStoreTests: XCTestCase {

    func sequentialInput(_ composingText: inout ComposingText, sequence: String, inputStyle: InputStyle) {
        for char in sequence {
            _ = composingText.insertAtCursorPosition(String(char), inputStyle: inputStyle)
        }
    }

    /// 絶対に変換できるべき候補をここに記述する
    ///  - 主に「変換できない」と報告のあった候補を追加する
    func testMustWords() throws {
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        let dicdataStore = DicdataStore()
        let mustWords = [
            ("アサッテ", "明後日"),
            ("ダイヒョウ", "代表"),
            ("テキナ", "的な"),
            ("ヤマダ", "山田"),
        ]
        for (key, word) in mustWords {
            var c = ComposingText()
            _ = c.insertAtCursorPosition(key, inputStyle: .direct)
            let result = dicdataStore.getLOUDSData(inputData: c, from: 0, to: c.input.endIndex-1)
            // 冗長な書き方だが、こうすることで「どの項目でエラーが発生したのか」がはっきりするため、こう書いている。
            XCTAssertEqual(result.first(where: {$0.data.word == word})?.data.word, word)
        }
    }

    func testGetLOUDSDataInRange() throws {
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        let dicdataStore = DicdataStore()
        do {
            var c = ComposingText()
            _ = c.insertAtCursorPosition("ヘンカン", inputStyle: .roman2kana)
            let result = dicdataStore.getLOUDSDataInRange(inputData: c, from: 0, toIndexRange: 2..<4)
            XCTAssertFalse(result.contains(where: {$0.data.word == "変"}))
            XCTAssertTrue(result.contains(where: {$0.data.word == "変化"}))
            XCTAssertTrue(result.contains(where: {$0.data.word == "変換"}))
        }
        do {
            var c = ComposingText()
            _ = c.insertAtCursorPosition("ヘンカン", inputStyle: .roman2kana)
            let result = dicdataStore.getLOUDSDataInRange(inputData: c, from: 0, toIndexRange: 0..<4)
            XCTAssertTrue(result.contains(where: {$0.data.word == "変"}))
            XCTAssertTrue(result.contains(where: {$0.data.word == "変化"}))
            XCTAssertTrue(result.contains(where: {$0.data.word == "変換"}))
        }
        do {
            var c = ComposingText()
            _ = c.insertAtCursorPosition("ツカッ", inputStyle: .roman2kana)
            let result = dicdataStore.getLOUDSDataInRange(inputData: c, from: 0, toIndexRange: 2..<3)
            XCTAssertTrue(result.contains(where: {$0.data.word == "使っ"}))
        }
        do {
            var c = ComposingText()
            _ = c.insertAtCursorPosition("ツカッt", inputStyle: .roman2kana)
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
