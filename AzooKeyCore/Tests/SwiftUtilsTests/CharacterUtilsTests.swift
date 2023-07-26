//
//  CharacterUtilsTests.swift
//  KanaKanjiConverterModuleTests
//
//  Created by ensan on 2022/12/18.
//  Copyright © 2022 ensan. All rights reserved.
//

@testable import SwiftUtils
import XCTest

final class CharacterUtilsTests: XCTestCase {

    func testIsKogana() throws {
        XCTAssertTrue(CharacterUtils.isKogana("ぁ"))
        XCTAssertTrue(CharacterUtils.isKogana("ヵ"))
        XCTAssertTrue(CharacterUtils.isKogana("ッ"))
        XCTAssertTrue(CharacterUtils.isKogana("ヮ"))
        XCTAssertTrue(CharacterUtils.isKogana("ゎ"))

        XCTAssertFalse(CharacterUtils.isKogana("あ"))
        XCTAssertFalse(CharacterUtils.isKogana("カ"))
        XCTAssertFalse(CharacterUtils.isKogana("a"))
        XCTAssertFalse(CharacterUtils.isKogana("!"))
    }

    func testIsRomanLetter() throws {
        XCTAssertTrue(CharacterUtils.isRomanLetter("a"))
        XCTAssertTrue(CharacterUtils.isRomanLetter("A"))
        XCTAssertTrue(CharacterUtils.isRomanLetter("b"))

        XCTAssertFalse(CharacterUtils.isRomanLetter("ぁ"))
        XCTAssertFalse(CharacterUtils.isRomanLetter("'"))
        XCTAssertFalse(CharacterUtils.isRomanLetter("あ"))
        XCTAssertFalse(CharacterUtils.isRomanLetter("カ"))
        XCTAssertFalse(CharacterUtils.isRomanLetter("!"))
    }

    func testIsDakuten() throws {
        XCTAssertTrue(CharacterUtils.isDakuten("が"))
        XCTAssertTrue(CharacterUtils.isDakuten("ば"))
        XCTAssertTrue(CharacterUtils.isDakuten("ダ"))
        XCTAssertTrue(CharacterUtils.isDakuten("ヴ"))
        XCTAssertTrue(CharacterUtils.isDakuten("ゔ"))

        XCTAssertFalse(CharacterUtils.isDakuten("ぱ"))
        XCTAssertFalse(CharacterUtils.isDakuten("あ"))
        XCTAssertFalse(CharacterUtils.isDakuten("a"))
        XCTAssertFalse(CharacterUtils.isDakuten("!"))
        XCTAssertFalse(CharacterUtils.isDakuten("ん"))
    }

    func testIsHandakuten() throws {
        XCTAssertTrue(CharacterUtils.isHandakuten("ぱ"))
        XCTAssertTrue(CharacterUtils.isHandakuten("パ"))
        XCTAssertTrue(CharacterUtils.isHandakuten("プ"))
        XCTAssertTrue(CharacterUtils.isHandakuten("ぽ"))
        XCTAssertTrue(CharacterUtils.isHandakuten("ペ"))

        XCTAssertFalse(CharacterUtils.isHandakuten("ば"))
        XCTAssertFalse(CharacterUtils.isHandakuten("が"))
        XCTAssertFalse(CharacterUtils.isHandakuten("a"))
        XCTAssertFalse(CharacterUtils.isHandakuten("!"))
        XCTAssertFalse(CharacterUtils.isHandakuten("ん"))
    }

    func testKogaki() throws {
        XCTAssertEqual(CharacterUtils.kogaki("あ"), "ぁ")
        XCTAssertEqual(CharacterUtils.kogaki("カ"), "ヵ")
        XCTAssertEqual(CharacterUtils.kogaki("ワ"), "ヮ")

        // そのままの場合もある
        XCTAssertEqual(CharacterUtils.kogaki("ん"), "ん")
        XCTAssertEqual(CharacterUtils.kogaki("漢"), "漢")
        XCTAssertEqual(CharacterUtils.kogaki("A"), "A")
    }

    func testOgaki() throws {
        XCTAssertEqual(CharacterUtils.ogaki("ぁ"), "あ")
        XCTAssertEqual(CharacterUtils.ogaki("ヵ"), "カ")
        XCTAssertEqual(CharacterUtils.ogaki("ヮ"), "ワ")

        // そのままの場合もある
        XCTAssertEqual(CharacterUtils.ogaki("ん"), "ん")
        XCTAssertEqual(CharacterUtils.ogaki("漢"), "漢")
        XCTAssertEqual(CharacterUtils.ogaki("A"), "A")
    }

    func testDakuten() throws {
        XCTAssertEqual(CharacterUtils.dakuten("か"), "が")
        XCTAssertEqual(CharacterUtils.dakuten("う"), "ゔ")
        XCTAssertEqual(CharacterUtils.dakuten("ホ"), "ボ")
        // 「へ」はひらがな、カタカナの判別が難しいので、厳密にやる
        XCTAssertEqual(CharacterUtils.dakuten(("へ" as Character).toHiragana()), ("べ" as Character).toHiragana())
        XCTAssertEqual(CharacterUtils.dakuten(("へ" as Character).toKatakana()), ("べ" as Character).toKatakana())

        // そのままの場合もある
        XCTAssertEqual(CharacterUtils.dakuten("パ"), "パ")
        XCTAssertEqual(CharacterUtils.dakuten("漢"), "漢")
        XCTAssertEqual(CharacterUtils.dakuten("A"), "A")
    }

    func testMudakuten() throws {
        XCTAssertEqual(CharacterUtils.mudakuten("が"), "か")
        XCTAssertEqual(CharacterUtils.mudakuten("ゔ"), "う")
        XCTAssertEqual(CharacterUtils.mudakuten("ボ"), "ホ")
        // 「へ」はひらがな、カタカナの判別が難しいので、厳密にやる
        XCTAssertEqual(CharacterUtils.mudakuten(("べ" as Character).toHiragana()), ("へ" as Character).toHiragana())
        XCTAssertEqual(CharacterUtils.mudakuten(("べ" as Character).toKatakana()), ("へ" as Character).toKatakana())

        // そのままの場合もある
        XCTAssertEqual(CharacterUtils.mudakuten("パ"), "パ")
        XCTAssertEqual(CharacterUtils.mudakuten("漢"), "漢")
        XCTAssertEqual(CharacterUtils.mudakuten("A"), "A")
    }

    func testHandakuten() throws {
        XCTAssertEqual(CharacterUtils.handakuten("は"), "ぱ")
        XCTAssertEqual(CharacterUtils.handakuten("ホ"), "ポ")
        // 「へ」はひらがな、カタカナの判別が難しいので、厳密にやる
        XCTAssertEqual(CharacterUtils.handakuten(("へ" as Character).toHiragana()), ("ぺ" as Character).toHiragana())
        XCTAssertEqual(CharacterUtils.handakuten(("へ" as Character).toKatakana()), ("ぺ" as Character).toKatakana())

        // そのままの場合もある
        XCTAssertEqual(CharacterUtils.handakuten("バ"), "バ")
        XCTAssertEqual(CharacterUtils.handakuten("漢"), "漢")
        XCTAssertEqual(CharacterUtils.handakuten("A"), "A")
    }

    func testMuhandakuten() throws {
        XCTAssertEqual(CharacterUtils.muhandakuten("ぱ"), "は")
        XCTAssertEqual(CharacterUtils.muhandakuten("ポ"), "ホ")
        // 「へ」はひらがな、カタカナの判別が難しいので、厳密にやる
        XCTAssertEqual(CharacterUtils.muhandakuten(("ぺ" as Character).toHiragana()), ("へ" as Character).toHiragana())
        XCTAssertEqual(CharacterUtils.muhandakuten(("ぺ" as Character).toKatakana()), ("へ" as Character).toKatakana())

        // そのままの場合もある
        XCTAssertEqual(CharacterUtils.muhandakuten("バ"), "バ")
        XCTAssertEqual(CharacterUtils.muhandakuten("漢"), "漢")
        XCTAssertEqual(CharacterUtils.muhandakuten("A"), "A")
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
        XCTAssertEqual(("😇" as Character).toKatakana(), "😇")
    }

    func testRequestChange() throws {
        XCTAssertEqual(CharacterUtils.requestChange("あ"), "ぁ")
        XCTAssertEqual(CharacterUtils.requestChange("ぁ"), "あ")
        XCTAssertEqual(CharacterUtils.requestChange("か"), "が")
        XCTAssertEqual(CharacterUtils.requestChange("が"), "か")
        XCTAssertEqual(CharacterUtils.requestChange("つ"), "っ")
        XCTAssertEqual(CharacterUtils.requestChange("っ"), "づ")
        XCTAssertEqual(CharacterUtils.requestChange("づ"), "つ")
        XCTAssertEqual(CharacterUtils.requestChange("は"), "ば")
        XCTAssertEqual(CharacterUtils.requestChange("ば"), "ぱ")
        XCTAssertEqual(CharacterUtils.requestChange("ぱ"), "は")

        XCTAssertEqual(CharacterUtils.requestChange("a"), "A")
        XCTAssertEqual(CharacterUtils.requestChange("A"), "a")

        XCTAssertEqual(CharacterUtils.requestChange("Π"), "π")
        XCTAssertEqual(CharacterUtils.requestChange("π"), "Π")

        // そのままの場合もある
        XCTAssertEqual(CharacterUtils.requestChange("バ"), "バ")
        XCTAssertEqual(CharacterUtils.requestChange("漢"), "漢")
        XCTAssertEqual(CharacterUtils.requestChange("。"), "。")
    }

}
