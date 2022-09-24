//
//  azooKeyKeyboardTests.swift
//  azooKeyKeyboardTests
//
//  Created by β α on 2020/10/08.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import XCTest
@testable import Keyboard

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
