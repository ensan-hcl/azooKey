//
//  azooKeyKeyboardTests.swift
//  azooKeyKeyboardTests
//
//  Created by β α on 2020/10/08.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import XCTest
@testable import Keyboard

extension KanaComponent: Equatable {
    public static func ==(lhs: KanaComponent, rhs: KanaComponent) -> Bool {
        return lhs.internalText == rhs.internalText && lhs.displayedText == rhs.displayedText && lhs.isFreezed == rhs.isFreezed && lhs.escapeRomanKanaConverting == rhs.escapeRomanKanaConverting
    }
}

class azooKeyKeyboardTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        do {
            let holder = KanaRomanStateHolder()

            holder.insert("a", leftSideText: "")
            XCTAssert(holder.components == [KanaComponent(internalText: "a", kana: "あ")])
            holder.insert("k", leftSideText: "あ")
            XCTAssert(holder.components == [KanaComponent(internalText: "a", kana: "あ"), KanaComponent(internalText: "k", kana: "k", escapeRomanKanaConverting: false)])
            holder.insert("i", leftSideText: "あk")
            XCTAssert(holder.components == [KanaComponent(internalText: "a", kana: "あ"), KanaComponent(internalText: "ki", kana: "き")])
            holder.insert("n", leftSideText: "あき")
            XCTAssert(holder.components == [KanaComponent(internalText: "a", kana: "あ"), KanaComponent(internalText: "ki", kana: "き"), KanaComponent(internalText: "n", kana: "n", escapeRomanKanaConverting: false)])
            holder.insert("t", leftSideText: "あきn")
            XCTAssert(holder.components == [
                KanaComponent(internalText: "a", kana: "あ"),
                KanaComponent(internalText: "ki", kana: "き"),
                KanaComponent(internalText: "n", kana: "ん"),
                KanaComponent(internalText: "t", kana: "t", escapeRomanKanaConverting: false)
            ])
            holder.insert("e", leftSideText: "あきんt")
            XCTAssert(holder.components == [
                KanaComponent(internalText: "a", kana: "あ"),
                KanaComponent(internalText: "ki", kana: "き"),
                KanaComponent(internalText: "n", kana: "ん"),
                KanaComponent(internalText: "te", kana: "て")
            ])
            holder.insert("n", leftSideText: "あきん")
            print(holder.components)
            XCTAssert(holder.components == [
                KanaComponent(internalText: "a", kana: "あ"),
                KanaComponent(internalText: "ki", kana: "き"),
                KanaComponent(internalText: "n", kana: "ん", isFreezed: true),
                KanaComponent(internalText: "n", kana: "n", escapeRomanKanaConverting: false),
                KanaComponent(internalText: "te", kana: "て")
            ])
        }

        do {
            let holder = KanaRomanStateHolder()

            holder.insert("k", leftSideText: "")
            holder.insert("a", leftSideText: "k")
            holder.insert("n", leftSideText: "か")
            XCTAssert(
                holder.components == [
                    KanaComponent(internalText: "ka", kana: "か"),
                    KanaComponent(internalText: "n", kana: "n", escapeRomanKanaConverting: false)
                ]
            )
            holder.insert("y", leftSideText: "かn")
            XCTAssert(
                holder.components == [
                    KanaComponent(internalText: "ka", kana: "か"),
                    KanaComponent(internalText: "n", kana: "n", escapeRomanKanaConverting: false),
                    KanaComponent(internalText: "y", kana: "y", escapeRomanKanaConverting: false)
                ]
            )
            holder.insert("u", leftSideText: "かny")
            XCTAssert(
                holder.components == [
                    KanaComponent(internalText: "ka", kana: "か"),
                    KanaComponent(internalText: "nyu", kana: "にゅ")
                ]
            )

        }
    }

    func roman2kanaTest() throws {
        do {
            XCTAssert("ka".roman2katakana == "カ")
            XCTAssert("te".roman2katakana == "テ")
            XCTAssert("ai".roman2katakana == "アイ")
            XCTAssert("tt".roman2katakana == "ッt")
            XCTAssert("fa".roman2katakana == "ファ")
            XCTAssert("zl".roman2katakana == "→")
            XCTAssert("nn".roman2katakana == "ン")
            XCTAssert("an".roman2katakana == "アン")
            XCTAssert("ny".roman2katakana == "ny")
        }

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        // let store = DicDataStore()
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
