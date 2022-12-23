//
//  ComposingTextTests.swift
//  KanaKanjierTests
//
//  Created by β α on 2022/12/18.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import XCTest

final class ComposingTextTests: XCTestCase {

    func testIsEmpty() throws {
        var c = ComposingText()
        XCTAssertTrue(c.isEmpty)
        _ = c.insertAtCursorPosition("あ", inputStyle: .direct)
        XCTAssertFalse(c.isEmpty)
        c.clear()
        XCTAssertTrue(c.isEmpty)
    }

    func testInsertAtCursorPosition() throws {
        // ダイレクト
        do {
            var c = ComposingText()
            var v = c.insertAtCursorPosition("あ", inputStyle: .direct)
            XCTAssertEqual(c.input, [ComposingText.InputElement(character: "あ", inputStyle: .direct)])
            XCTAssertEqual(c.convertTarget, "あ")
            XCTAssertEqual(c.convertTargetCursorPosition, 1)
            XCTAssertEqual(v, ComposingText.ViewOperation(delete: 0, input: "あ"))

            v = c.insertAtCursorPosition("ん", inputStyle: .direct)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "あ", inputStyle: .direct), .init(character: "ん", inputStyle: .direct)], convertTarget: "あん"))
            XCTAssertEqual(v, ComposingText.ViewOperation(delete: 0, input: "ん"))
        }
        // ローマ字
        do {
            let inputStyle = InputStyle.roman2kana
            var c = ComposingText()
            var v = c.insertAtCursorPosition("a", inputStyle: inputStyle)
            XCTAssertEqual(c.input, [ComposingText.InputElement(character: "a", inputStyle: inputStyle)])
            XCTAssertEqual(c.convertTarget, "あ")
            XCTAssertEqual(c.convertTargetCursorPosition, 1)
            XCTAssertEqual(v, ComposingText.ViewOperation(delete: 0, input: "あ"))

            v = c.insertAtCursorPosition("k", inputStyle: inputStyle)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "a", inputStyle: inputStyle), .init(character: "k", inputStyle: inputStyle)], convertTarget: "あk"))
            XCTAssertEqual(v, ComposingText.ViewOperation(delete: 0, input: "k"))

            v = c.insertAtCursorPosition("i", inputStyle: inputStyle)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "a", inputStyle: inputStyle), .init(character: "k", inputStyle: inputStyle), .init(character: "i", inputStyle: inputStyle)], convertTarget: "あき"))
            XCTAssertEqual(v, ComposingText.ViewOperation(delete: 1, input: "き"))
        }
        // ミックス
        do {
            var c = ComposingText()
            var v = c.insertAtCursorPosition("a", inputStyle: .direct)
            XCTAssertEqual(c.input, [ComposingText.InputElement(character: "a", inputStyle: .direct)])
            XCTAssertEqual(c.convertTarget, "a")
            XCTAssertEqual(c.convertTargetCursorPosition, 1)
            XCTAssertEqual(v, ComposingText.ViewOperation(delete: 0, input: "a"))

            v = c.insertAtCursorPosition("k", inputStyle: .roman2kana)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "a", inputStyle: .direct), .init(character: "k", inputStyle: .roman2kana)], convertTarget: "ak"))
            XCTAssertEqual(v, ComposingText.ViewOperation(delete: 0, input: "k"))

            v = c.insertAtCursorPosition("i", inputStyle: .roman2kana)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "a", inputStyle: .direct), .init(character: "k", inputStyle: .roman2kana), .init(character: "i", inputStyle: .roman2kana)], convertTarget: "aき"))
            XCTAssertEqual(v, ComposingText.ViewOperation(delete: 1, input: "き"))
        }
    }
}
