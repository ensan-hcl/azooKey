//
//  WarekiConversionTests.swift
//  azooKeyTests
//
//  Created by ensan on 2022/12/22.
//  Copyright © 2022 ensan. All rights reserved.
//

import XCTest

final class WarekiConversionTests: XCTestCase {
    func makeDirectInput(direct input: String) -> ComposingText {
        ComposingText(
            convertTargetCursorPosition: input.count,
            input: input.map {.init(character: $0, inputStyle: .direct)},
            convertTarget: input
        )
    }

    func testSeireki2Wareki() throws {
        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "2019ねん")
            let result = converter.toWarekiCandidates(input)
            XCTAssertEqual(result.count, 2)
            if result.count == 2 {
                XCTAssertEqual(result[0].text, "令和元年")
                XCTAssertEqual(result[1].text, "平成31年")
            }
        }

        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "2020ねん")
            let result = converter.toWarekiCandidates(input)
            XCTAssertEqual(result.count, 1)
            if result.count == 1 {
                XCTAssertEqual(result[0].text, "令和2年")
            }
        }

        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "2001ねん")
            let result = converter.toWarekiCandidates(input)
            XCTAssertEqual(result.count, 1)
            if result.count == 1 {
                XCTAssertEqual(result[0].text, "平成13年")
            }
        }

        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "1945ねん")
            let result = converter.toWarekiCandidates(input)
            XCTAssertEqual(result.count, 1)
            if result.count == 1 {
                XCTAssertEqual(result[0].text, "昭和20年")
            }
        }

        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "9999ねん")
            let result = converter.toWarekiCandidates(input)
            XCTAssertEqual(result.count, 1)
            if result.count == 1 {
                XCTAssertEqual(result[0].text, "令和7981年")
            }
        }

        // invalid cases
        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "せいれき2001ねん")
            let result = converter.toWarekiCandidates(input)
            XCTAssertTrue(result.isEmpty)
        }
        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "1582ねん")
            let result = converter.toWarekiCandidates(input)
            XCTAssertTrue(result.isEmpty)
        }
        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "10000ねん")
            let result = converter.toWarekiCandidates(input)
            XCTAssertTrue(result.isEmpty)
        }

    }

    func testWareki2Seireki() throws {
        do {
            let converter = KanaKanjiConverter()
            let input = ComposingText(
                convertTargetCursorPosition: 8,
                input: "れいわがんねん".map {.init(character: $0, inputStyle: .direct)},
                convertTarget: "れいわがんねん"
            )
            let result = converter.toSeirekiCandidates(input)
            XCTAssertEqual(result.count, 1)
            if result.count == 1 {
                XCTAssertEqual(result[0].text, "2019年")
            }
        }

        do {
            let converter = KanaKanjiConverter()
            let input = ComposingText(
                convertTargetCursorPosition: 8,
                input: "れいわ1ねん".map {.init(character: $0, inputStyle: .direct)},
                convertTarget: "れいわ1ねん"
            )
            let result = converter.toSeirekiCandidates(input)
            XCTAssertEqual(result.count, 1)
            if result.count == 1 {
                XCTAssertEqual(result[0].text, "2019年")
            }
        }

        do {
            let converter = KanaKanjiConverter()
            let input = ComposingText(
                convertTargetCursorPosition: 8,
                input: "しょうわ25ねん".map {.init(character: $0, inputStyle: .direct)},
                convertTarget: "しょうわ25ねん"
            )
            let result = converter.toSeirekiCandidates(input)
            XCTAssertEqual(result.count, 1)
            if result.count == 1 {
                XCTAssertEqual(result[0].text, "1950年")
            }
        }

        do {
            let converter = KanaKanjiConverter()
            let input = ComposingText(
                convertTargetCursorPosition: 8,
                input: "めいじ9ねん".map {.init(character: $0, inputStyle: .direct)},
                convertTarget: "めいじ9ねん"
            )
            let result = converter.toSeirekiCandidates(input)
            XCTAssertEqual(result.count, 1)
            if result.count == 1 {
                XCTAssertEqual(result[0].text, "1876年")
            }
        }

        // invalid cases
        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "れいわ100ねん")
            let result = converter.toSeirekiCandidates(input)
            XCTAssertTrue(result.isEmpty)
        }

        do {
            let converter = KanaKanjiConverter()
            let input = makeDirectInput(direct: "けいおう5ねん")
            let result = converter.toSeirekiCandidates(input)
            XCTAssertTrue(result.isEmpty)
        }
    }
}
