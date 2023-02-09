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
