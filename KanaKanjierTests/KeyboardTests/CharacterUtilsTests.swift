//
//  CharacterUtilsTests.swift
//  KanaKanjierTests
//
//  Created by β α on 2022/12/18.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import XCTest
@testable import Keyboard

final class CharacterUtilsTests: XCTestCase {

    func testIsKogana() throws {
        XCTAssertTrue(("ぁ" as Character).isKogana)
        XCTAssertTrue(("ヵ" as Character).isKogana)
        XCTAssertTrue(("ッ" as Character).isKogana)
        XCTAssertTrue(("ヮ" as Character).isKogana)
        XCTAssertTrue(("ゎ" as Character).isKogana)

        XCTAssertFalse(("あ" as Character).isKogana)
        XCTAssertFalse(("カ" as Character).isKogana)
        XCTAssertFalse(("a" as Character).isKogana)
        XCTAssertFalse(("!" as Character).isKogana)
    }

    func testIsRomanLetter() throws {
        XCTAssertTrue(("a" as Character).isRomanLetter)
        XCTAssertTrue(("A" as Character).isRomanLetter)
        XCTAssertTrue(("b" as Character).isRomanLetter)

        XCTAssertFalse(("ぁ" as Character).isRomanLetter)
        XCTAssertFalse(("'" as Character).isRomanLetter)
        XCTAssertFalse(("あ" as Character).isRomanLetter)
        XCTAssertFalse(("カ" as Character).isRomanLetter)
        XCTAssertFalse(("!" as Character).isRomanLetter)
    }

    func testIsDakuten() throws {
        XCTAssertTrue(("が" as Character).isDakuten)
        XCTAssertTrue(("ば" as Character).isDakuten)
        XCTAssertTrue(("ダ" as Character).isDakuten)
        XCTAssertTrue(("ヴ" as Character).isDakuten)
        XCTAssertTrue(("ゔ" as Character).isDakuten)

        XCTAssertFalse(("ぱ" as Character).isDakuten)
        XCTAssertFalse(("あ" as Character).isDakuten)
        XCTAssertFalse(("a" as Character).isDakuten)
        XCTAssertFalse(("!" as Character).isDakuten)
        XCTAssertFalse(("ん" as Character).isDakuten)
    }

    func testIsHandakuten() throws {
        XCTAssertTrue(("ぱ" as Character).isHandakuten)
        XCTAssertTrue(("パ" as Character).isHandakuten)
        XCTAssertTrue(("プ" as Character).isHandakuten)
        XCTAssertTrue(("ぽ" as Character).isHandakuten)
        XCTAssertTrue(("ペ" as Character).isHandakuten)

        XCTAssertFalse(("ば" as Character).isHandakuten)
        XCTAssertFalse(("が" as Character).isHandakuten)
        XCTAssertFalse(("a" as Character).isHandakuten)
        XCTAssertFalse(("!" as Character).isHandakuten)
        XCTAssertFalse(("ん" as Character).isHandakuten)
    }

    func testKogaki() throws {
        XCTAssertEqual(("あ" as Character).kogaki, "ぁ")
        XCTAssertEqual(("カ" as Character).kogaki, "ヵ")
        XCTAssertEqual(("ワ" as Character).kogaki, "ヮ")

        // そのままの場合もある
        XCTAssertEqual(("ん" as Character).kogaki, "ん")
        XCTAssertEqual(("漢" as Character).kogaki, "漢")
        XCTAssertEqual(("A" as Character).kogaki, "A")
    }

    func testOgaki() throws {
        XCTAssertEqual(("ぁ" as Character).ogaki, "あ")
        XCTAssertEqual(("ヵ" as Character).ogaki, "カ")
        XCTAssertEqual(("ヮ" as Character).ogaki, "ワ")

        // そのままの場合もある
        XCTAssertEqual(("ん" as Character).ogaki, "ん")
        XCTAssertEqual(("漢" as Character).ogaki, "漢")
        XCTAssertEqual(("A" as Character).ogaki, "A")
    }

    func testDakuten() throws {
        XCTAssertEqual(("か" as Character).dakuten, "が")
        XCTAssertEqual(("う" as Character).dakuten, "ゔ")
        XCTAssertEqual(("ホ" as Character).dakuten, "ボ")
        // 「へ」はひらがな、カタカナの判別が難しいので、厳密にやる
        XCTAssertEqual(("へ" as Character).toHiragana().dakuten, ("べ" as Character).toHiragana())
        XCTAssertEqual(("へ" as Character).toKatakana().dakuten, ("べ" as Character).toKatakana())

        // そのままの場合もある
        XCTAssertEqual(("パ" as Character).dakuten, "パ")
        XCTAssertEqual(("漢" as Character).dakuten, "漢")
        XCTAssertEqual(("A" as Character).dakuten, "A")
    }

    func testMudakuten() throws {
        XCTAssertEqual(("が" as Character).mudakuten, "か")
        XCTAssertEqual(("ゔ" as Character).mudakuten, "う")
        XCTAssertEqual(("ボ" as Character).mudakuten, "ホ")
        // 「へ」はひらがな、カタカナの判別が難しいので、厳密にやる
        XCTAssertEqual(("べ" as Character).toHiragana().mudakuten, ("へ" as Character).toHiragana())
        XCTAssertEqual(("べ" as Character).toKatakana().mudakuten, ("へ" as Character).toKatakana())

        // そのままの場合もある
        XCTAssertEqual(("パ" as Character).mudakuten, "パ")
        XCTAssertEqual(("漢" as Character).mudakuten, "漢")
        XCTAssertEqual(("A" as Character).mudakuten, "A")
    }

    func testHandakuten() throws {
        XCTAssertEqual(("は" as Character).handakuten, "ぱ")
        XCTAssertEqual(("ホ" as Character).handakuten, "ポ")
        // 「へ」はひらがな、カタカナの判別が難しいので、厳密にやる
        XCTAssertEqual(("へ" as Character).toHiragana().handakuten, ("ぺ" as Character).toHiragana())
        XCTAssertEqual(("へ" as Character).toKatakana().handakuten, ("ぺ" as Character).toKatakana())

        // そのままの場合もある
        XCTAssertEqual(("バ" as Character).handakuten, "バ")
        XCTAssertEqual(("漢" as Character).handakuten, "漢")
        XCTAssertEqual(("A" as Character).handakuten, "A")
    }

    func testMuhandakuten() throws {
        XCTAssertEqual(("ぱ" as Character).muhandakuten, "は")
        XCTAssertEqual(("ポ" as Character).muhandakuten, "ホ")
        // 「へ」はひらがな、カタカナの判別が難しいので、厳密にやる
        XCTAssertEqual(("ぺ" as Character).toHiragana().muhandakuten, ("へ" as Character).toHiragana())
        XCTAssertEqual(("ぺ" as Character).toKatakana().muhandakuten, ("へ" as Character).toKatakana())

        // そのままの場合もある
        XCTAssertEqual(("バ" as Character).muhandakuten, "バ")
        XCTAssertEqual(("漢" as Character).muhandakuten, "漢")
        XCTAssertEqual(("A" as Character).muhandakuten, "A")
    }

    func testToHiragana() throws {
        XCTAssertEqual(("ハ" as Character).toHiragana(), "は")
        XCTAssertEqual(("ヴ" as Character).toHiragana(), "ゔ")
        XCTAssertEqual(("ン" as Character).toHiragana(), "ん")
        XCTAssertEqual(("ァ" as Character).toHiragana(), "ぁ")

        // そのままの場合もある
        XCTAssertEqual(("漢" as Character).toHiragana(), "漢")
        XCTAssertEqual(("あ" as Character).toHiragana(), "あ")
        XCTAssertEqual(("A" as Character).toHiragana(), "A")
    }

    func testToKatakana() throws {
        XCTAssertEqual(("は" as Character).toKatakana(), "ハ")
        XCTAssertEqual(("ゔ" as Character).toKatakana(), "ヴ")
        XCTAssertEqual(("ん" as Character).toKatakana(), "ン")
        XCTAssertEqual(("ぁ" as Character).toKatakana(), "ァ")

        // そのままの場合もある
        XCTAssertEqual(("漢" as Character).toKatakana(), "漢")
        XCTAssertEqual(("ア" as Character).toKatakana(), "ア")
        XCTAssertEqual(("A" as Character).toKatakana(), "A")
    }

    func testRequestChange() throws {
        XCTAssertEqual(("あ" as Character).requestChange(), "ぁ")
        XCTAssertEqual(("ぁ" as Character).requestChange(), "あ")
        XCTAssertEqual(("か" as Character).requestChange(), "が")
        XCTAssertEqual(("が" as Character).requestChange(), "か")
        XCTAssertEqual(("つ" as Character).requestChange(), "っ")
        XCTAssertEqual(("っ" as Character).requestChange(), "づ")
        XCTAssertEqual(("づ" as Character).requestChange(), "つ")
        XCTAssertEqual(("は" as Character).requestChange(), "ば")
        XCTAssertEqual(("ば" as Character).requestChange(), "ぱ")
        XCTAssertEqual(("ぱ" as Character).requestChange(), "は")

        XCTAssertEqual(("a" as Character).requestChange(), "A")
        XCTAssertEqual(("A" as Character).requestChange(), "a")

        XCTAssertEqual(("Π" as Character).requestChange(), "π")
        XCTAssertEqual(("π" as Character).requestChange(), "Π")

        // そのままの場合もある
        XCTAssertEqual(("バ" as Character).requestChange(), "バ")
        XCTAssertEqual(("漢" as Character).requestChange(), "漢")
        XCTAssertEqual(("。" as Character).requestChange(), "。")
    }

}
