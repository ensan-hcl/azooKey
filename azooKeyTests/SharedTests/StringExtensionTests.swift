//
//  StringExtensionTests.swift
//  KanaKanjierTests
//
//  Created by β α on 2022/12/23.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import XCTest

final class StringExtensionTests: XCTestCase {

    func testToKatakana() throws {
        XCTAssertEqual("かゔぁあーんじょ123+++リスク".toKatakana(), "カヴァアーンジョ123+++リスク")
        XCTAssertEqual("".toKatakana(), "")
        XCTAssertEqual("コレハロン".toKatakana(), "コレハロン")
    }

    func testToHiragana() throws {
        XCTAssertEqual("カヴァアーンじょ123+++リスク".toHiragana(), "かゔぁあーんじょ123+++りすく")
        XCTAssertEqual("".toHiragana(), "")
        XCTAssertEqual("これはろん".toHiragana(), "これはろん")
    }

    func testIndexFromStart() throws {
        do {
            let string = "ア❤️‍🔥ウ😇オ"
            XCTAssertEqual(string[string.indexFromStart(3)], "😇")
            XCTAssertEqual(string[string.indexFromStart(4)], "オ")
        }
    }

}
