//
//  ComposingTextTests.swift
//  azooKeyTests
//
//  Created by ensan on 2022/12/18.
//  Copyright © 2022 ensan. All rights reserved.
//

import XCTest

final class ComposingTextTests: XCTestCase {

    func sequentialInput(_ composingText: inout ComposingText, sequence: String, inputStyle: InputStyle) {
        for char in sequence {
            composingText.insertAtCursorPosition(String(char), inputStyle: inputStyle)
        }
    }

    func testIsEmpty() throws {
        var c = ComposingText()
        XCTAssertTrue(c.isEmpty)
        c.insertAtCursorPosition("あ", inputStyle: .direct)
        XCTAssertFalse(c.isEmpty)
        c.stopComposition()
        XCTAssertTrue(c.isEmpty)
    }

    func testInsertAtCursorPosition() throws {
        // ダイレクト
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("あ", inputStyle: .direct)
            XCTAssertEqual(c.input, [ComposingText.InputElement(character: "あ", inputStyle: .direct)])
            XCTAssertEqual(c.convertTarget, "あ")
            XCTAssertEqual(c.convertTargetCursorPosition, 1)

            c.insertAtCursorPosition("ん", inputStyle: .direct)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "あ", inputStyle: .direct), .init(character: "ん", inputStyle: .direct)], convertTarget: "あん"))
        }
        // ローマ字
        do {
            let inputStyle = InputStyle.roman2kana
            var c = ComposingText()
            c.insertAtCursorPosition("a", inputStyle: inputStyle)
            XCTAssertEqual(c.input, [ComposingText.InputElement(character: "a", inputStyle: inputStyle)])
            XCTAssertEqual(c.convertTarget, "あ")
            XCTAssertEqual(c.convertTargetCursorPosition, 1)

            c.insertAtCursorPosition("k", inputStyle: inputStyle)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "a", inputStyle: inputStyle), .init(character: "k", inputStyle: inputStyle)], convertTarget: "あk"))

            c.insertAtCursorPosition("i", inputStyle: inputStyle)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "a", inputStyle: inputStyle), .init(character: "k", inputStyle: inputStyle), .init(character: "i", inputStyle: inputStyle)], convertTarget: "あき"))
        }
        // ローマ字で一気に入力
        do {
            let inputStyle = InputStyle.roman2kana
            var c = ComposingText()
            c.insertAtCursorPosition("akafa", inputStyle: inputStyle)
            XCTAssertEqual(c.input, [
                ComposingText.InputElement(character: "a", inputStyle: inputStyle),
                ComposingText.InputElement(character: "k", inputStyle: inputStyle),
                ComposingText.InputElement(character: "a", inputStyle: inputStyle),
                ComposingText.InputElement(character: "f", inputStyle: inputStyle),
                ComposingText.InputElement(character: "a", inputStyle: inputStyle),
            ])
            XCTAssertEqual(c.convertTarget, "あかふぁ")
            XCTAssertEqual(c.convertTargetCursorPosition, 4)

        }
        // ローマ字の特殊ケース(促音)
        do {
            let inputStyle = InputStyle.roman2kana
            var c = ComposingText()
            sequentialInput(&c, sequence: "itte", inputStyle: .roman2kana)
            XCTAssertEqual(c.input, [
                ComposingText.InputElement(character: "i", inputStyle: .roman2kana),
                ComposingText.InputElement(character: "っ", inputStyle: .direct),
                ComposingText.InputElement(character: "t", inputStyle: .roman2kana),
                ComposingText.InputElement(character: "e", inputStyle: .roman2kana),
            ])
            XCTAssertEqual(c.convertTarget, "いって")
            XCTAssertEqual(c.convertTargetCursorPosition, 3)
        }
        // ローマ字の特殊ケース(撥音)
        do {
            let inputStyle = InputStyle.roman2kana
            var c = ComposingText()
            sequentialInput(&c, sequence: "anta", inputStyle: .roman2kana)
            XCTAssertEqual(c.input, [
                ComposingText.InputElement(character: "a", inputStyle: .roman2kana),
                ComposingText.InputElement(character: "ん", inputStyle: .direct),
                ComposingText.InputElement(character: "t", inputStyle: .roman2kana),
                ComposingText.InputElement(character: "a", inputStyle: .roman2kana),
            ])
            XCTAssertEqual(c.convertTarget, "あんた")
            XCTAssertEqual(c.convertTargetCursorPosition, 3)
        }
        // ミックス
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("a", inputStyle: .direct)
            XCTAssertEqual(c.input, [ComposingText.InputElement(character: "a", inputStyle: .direct)])
            XCTAssertEqual(c.convertTarget, "a")
            XCTAssertEqual(c.convertTargetCursorPosition, 1)

            c.insertAtCursorPosition("k", inputStyle: .roman2kana)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "a", inputStyle: .direct), .init(character: "k", inputStyle: .roman2kana)], convertTarget: "ak"))

            c.insertAtCursorPosition("i", inputStyle: .roman2kana)
            XCTAssertEqual(c, ComposingText(convertTargetCursorPosition: 2, input: [.init(character: "a", inputStyle: .direct), .init(character: "k", inputStyle: .roman2kana), .init(character: "i", inputStyle: .roman2kana)], convertTarget: "aき"))
        }
    }

    func testDeleteForward() throws {
        // ダイレクト
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("あいうえお", inputStyle: .direct) // あいうえお|
            _ = c.moveCursorFromCursorPosition(count: -3)  // あい|うえお
            // 「う」を消す
            c.deleteForwardFromCursorPosition(count: 1)   // あい|えお
            XCTAssertEqual(c.input, [
                ComposingText.InputElement(character: "あ", inputStyle: .direct),
                ComposingText.InputElement(character: "い", inputStyle: .direct),
                ComposingText.InputElement(character: "え", inputStyle: .direct),
                ComposingText.InputElement(character: "お", inputStyle: .direct),
            ])
            XCTAssertEqual(c.convertTarget, "あいえお")
            XCTAssertEqual(c.convertTargetCursorPosition, 2)
        }

        // ローマ字（危険なケース）
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("akafa", inputStyle: .roman2kana) // あかふぁ|
            _ = c.moveCursorFromCursorPosition(count: -1)  // あかふ|ぁ
            // 「ぁ」を消す
            c.deleteForwardFromCursorPosition(count: 1)   // あかふ
            XCTAssertEqual(c.input, [
                ComposingText.InputElement(character: "a", inputStyle: .roman2kana),
                ComposingText.InputElement(character: "k", inputStyle: .roman2kana),
                ComposingText.InputElement(character: "a", inputStyle: .roman2kana),
                ComposingText.InputElement(character: "ふ", inputStyle: .direct),
            ])
            XCTAssertEqual(c.convertTarget, "あかふ")
            XCTAssertEqual(c.convertTargetCursorPosition, 3)
        }

    }

    func testIsRightSideValid() throws {
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("akafatta", inputStyle: .roman2kana) // あかふぁった|
            XCTAssertTrue(ComposingText.isRightSideValid(lastElement: ComposingText.InputElement(character: "a", inputStyle: .roman2kana), convertTargetElements: [ComposingText.ConvertTargetElement(string: "あ", inputStyle: .roman2kana)], of: c.input, to: 1))
            XCTAssertFalse(ComposingText.isRightSideValid(lastElement: ComposingText.InputElement(character: "k", inputStyle: .roman2kana), convertTargetElements: [ComposingText.ConvertTargetElement(string: "あk", inputStyle: .roman2kana)], of: c.input, to: 2))
            XCTAssertTrue(ComposingText.isRightSideValid(lastElement: ComposingText.InputElement(character: "a", inputStyle: .roman2kana), convertTargetElements: [ComposingText.ConvertTargetElement(string: "あか", inputStyle: .roman2kana)], of: c.input, to: 3))
            XCTAssertFalse(ComposingText.isRightSideValid(lastElement: ComposingText.InputElement(character: "f", inputStyle: .roman2kana), convertTargetElements: [ComposingText.ConvertTargetElement(string: "あかf", inputStyle: .roman2kana)], of: c.input, to: 4))
            XCTAssertTrue(ComposingText.isRightSideValid(lastElement: ComposingText.InputElement(character: "a", inputStyle: .roman2kana), convertTargetElements: [ComposingText.ConvertTargetElement(string: "あかふぁ", inputStyle: .roman2kana)], of: c.input, to: 5))
            // これはtrueにしている
            XCTAssertTrue(ComposingText.isRightSideValid(lastElement: ComposingText.InputElement(character: "t", inputStyle: .roman2kana), convertTargetElements: [ComposingText.ConvertTargetElement(string: "あかふぁt", inputStyle: .roman2kana)], of: c.input, to: 6))
            // これはfalse
            XCTAssertFalse(ComposingText.isRightSideValid(lastElement: ComposingText.InputElement(character: "t", inputStyle: .roman2kana), convertTargetElements: [ComposingText.ConvertTargetElement(string: "あかふぁtt", inputStyle: .roman2kana)], of: c.input, to: 7))
            XCTAssertTrue(ComposingText.isRightSideValid(lastElement: ComposingText.InputElement(character: "a", inputStyle: .roman2kana), convertTargetElements: [ComposingText.ConvertTargetElement(string: "あかふぁった", inputStyle: .roman2kana)], of: c.input, to: 8))
        }
    }

    func testGetConvertTargetIfRightSideIsValid() throws {
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("akafatta", inputStyle: .roman2kana) // あかふぁった|
            XCTAssertEqual(
                ComposingText.getConvertTargetIfRightSideIsValid(
                    lastElement: ComposingText.InputElement(character: "t", inputStyle: .roman2kana),
                    of: c.input,
                    to: 6,
                    convertTargetElements: [ComposingText.ConvertTargetElement(string: "あかふぁt", inputStyle: .roman2kana)]
                ),
                "あかふぁっ"
            )
        }
        do {
            var c = ComposingText()
            c.insertAtCursorPosition("kintarou", inputStyle: .roman2kana) // きんたろう|
            XCTAssertEqual(
                ComposingText.getConvertTargetIfRightSideIsValid(
                    lastElement: ComposingText.InputElement(character: "n", inputStyle: .roman2kana),
                    of: c.input,
                    to: 3,
                    convertTargetElements: [ComposingText.ConvertTargetElement(string: "きn", inputStyle: .roman2kana)]
                ),
                "きん"
            )
        }
    }

    func testDifferenceSuffix() throws {
        do {
            var c1 = ComposingText()
            c1.insertAtCursorPosition("hasir", inputStyle: .roman2kana)

            var c2 = ComposingText()
            c2.insertAtCursorPosition("hasiru", inputStyle: .roman2kana)

            XCTAssertEqual(c2.differenceSuffix(to: c1).deleted, 0)
            XCTAssertEqual(c2.differenceSuffix(to: c1).addedCount, 1)
        }
        do {
            var c1 = ComposingText()
            c1.insertAtCursorPosition("tukatt", inputStyle: .roman2kana)

            var c2 = ComposingText()
            c2.insertAtCursorPosition("tukatte", inputStyle: .roman2kana)

            XCTAssertEqual(c2.differenceSuffix(to: c1).deleted, 0)
            XCTAssertEqual(c2.differenceSuffix(to: c1).addedCount, 1)
        }
    }
}
