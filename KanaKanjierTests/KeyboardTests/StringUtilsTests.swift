//
//  StringUtilsTests.swift
//  KanaKanjierTests
//
//  Created by β α on 2022/12/18.
//  Copyright © 2022 DevEn3. All rights reserved.
//

@testable import Keyboard
import XCTest

final class StringTests: XCTestCase {

    func testIsKana() throws {
        XCTAssertTrue("あ".isKana)
        XCTAssertTrue("ぁ".isKana)
        XCTAssertTrue("ン".isKana)
        XCTAssertTrue("ァ".isKana)
        XCTAssertTrue("が".isKana)
        XCTAssertTrue("ゔ".isKana)

        XCTAssertFalse("k".isKana)
        XCTAssertFalse("@".isKana)
        XCTAssertFalse("ｶ".isKana)  // 半角カタカナはカナ扱いしない
    }

    func testOnlyRomanAlphabetOrNumber() throws {
        XCTAssertTrue("and13".onlyRomanAlphabetOrNumber)
        XCTAssertTrue("vmaoNFIU".onlyRomanAlphabetOrNumber)
        XCTAssertTrue("1332".onlyRomanAlphabetOrNumber)

        // 文字がない場合はfalse
        XCTAssertFalse("".onlyRomanAlphabetOrNumber)
        XCTAssertFalse("and 13".onlyRomanAlphabetOrNumber)
        XCTAssertFalse("can't".onlyRomanAlphabetOrNumber)
        XCTAssertFalse("Mt.".onlyRomanAlphabetOrNumber)
    }

    func testOnlyRomanAlphabet() throws {
        XCTAssertTrue("vmaoNFIU".onlyRomanAlphabet)
        XCTAssertTrue("NAO".onlyRomanAlphabet)

        // 文字がない場合はfalse
        XCTAssertFalse("".onlyRomanAlphabet)
        XCTAssertFalse("and 13".onlyRomanAlphabet)
        XCTAssertFalse("can't".onlyRomanAlphabet)
        XCTAssertFalse("Mt.".onlyRomanAlphabet)
        XCTAssertFalse("and13".onlyRomanAlphabet)
        XCTAssertFalse("vmaoNFIU83942".onlyRomanAlphabet)
    }

    func testContainsRomanAlphabet() throws {
        XCTAssertTrue("vmaoNFIU".containsRomanAlphabet)
        XCTAssertTrue("変数x".containsRomanAlphabet)
        XCTAssertTrue("and 13".containsRomanAlphabet)
        XCTAssertTrue("can't".containsRomanAlphabet)
        XCTAssertTrue("Mt.".containsRomanAlphabet)
        XCTAssertTrue("(^v^)".containsRomanAlphabet)

        // 文字がない場合はfalse
        XCTAssertFalse("".containsRomanAlphabet)
        XCTAssertFalse("!?!?".containsRomanAlphabet)
        XCTAssertFalse("(^_^)".containsRomanAlphabet)
        XCTAssertFalse("問題ア".containsRomanAlphabet)
    }

    func testIsEnglishSentence() throws {
        XCTAssertTrue("Is this an English sentence?".isEnglishSentence)
        XCTAssertTrue("English sentences can include symbols like '!?/\\=-+^`{}()[].".isEnglishSentence)

        // 文字がない場合はfalse
        XCTAssertFalse("".isEnglishSentence)
        XCTAssertFalse("The word '変数' is not an English word.".isEnglishSentence)
        XCTAssertFalse("これは完全に日本語の文章です".isEnglishSentence)
    }

    func testPerformanceExample() throws {
    }
}
