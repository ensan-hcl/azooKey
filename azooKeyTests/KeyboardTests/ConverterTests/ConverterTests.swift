//
//  ConverterTests.swift
//  azooKeyTests
//
//  Created by ensan on 2023/01/30.
//  Copyright © 2023 ensan. All rights reserved.
//

import XCTest

final class ConverterTests: XCTestCase {
    func testFullConversion() throws {
        // データリソースの場所を指定する
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        do {
            let converter = KanaKanjiConverter()
            var c = ComposingText()
            _ = c.insertAtCursorPosition("あずーきーはしんじだいのきーぼーどあぷりです", inputStyle: .direct)
            let results = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))
            XCTAssertEqual(results.mainResults.first?.text, "azooKeyは新時代のキーボードアプリです")
        }
        do {
            let converter = KanaKanjiConverter()
            var c = ComposingText()
            _ = c.insertAtCursorPosition("ようしょうきからてにすすいえいやきゅうしょうりんじけんぽうなどさまざまなすぽーつをけいけんしながらそだちしょうがっこうじだいはろさんぜるすきんこうにたいざいしておりごるふやてにすをならっていた", inputStyle: .direct)
            let results = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))
            XCTAssertEqual(results.mainResults.first?.text, "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた")

        }
    }

    // 1文字ずつ変換する
    // memo: 内部実装としては別のモジュールが呼ばれるのだが、それをテストする方法があまりないかもしれない
    func testGradualConversion() throws {
        // データリソースの場所を指定する
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        let text = "ようしょうきからてにすすいえいやきゅうしょうりんじけんぽうなどさまざまなすぽーつをけいけんしながらそだちしょうがっこうじだいはろさんぜるすきんこうにたいざいしておりごるふやてにすをならっていた"
        for char in text {
            _ = c.insertAtCursorPosition(String(char), inputStyle: .direct)
            let results = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))
            if c.input.count == text.count {
                XCTAssertEqual(results.mainResults.first?.text, "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた")
            }
        }
    }

    // 1文字ずつ変換する
    // memo: 内部実装としては別のモジュールが呼ばれるのだが、それをテストする方法があまりないかもしれない
    func testRoman2KanaGradualConversion() throws {
        // データリソースの場所を指定する
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        let text = "youshoukikaratenisusuieiyakyuushourinjikenpounadosamazamanasupoーtuwokeikennsinagarasodatishougakkouzidaiharosanzerusukinkounitaizaisiteorigoruhuyatenisuwonaratteita"
        // 許容される変換結果
        let  possibles = [
            "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた",
            "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスをならっていた"
        ]
        for char in text {
            _ = c.insertAtCursorPosition(String(char), inputStyle: .roman2kana)
            let results = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))
            if c.input.count == text.count {
                XCTAssertTrue(possibles.contains(results.mainResults.first!.text))
            }
        }
    }

    // 2,3文字ずつ変換する
    // memo: 内部実装としては別のモジュールが呼ばれるのだが、それをテストする方法があまりないかもしれない
    func testSemiGradualConversion() throws {
        // データリソースの場所を指定する
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        let text = "ようしょうきからてにすすいえいやきゅうしょうりんじけんぽうなどさまざまなすぽーつをけいけんしながらそだちしょうがっこうじだいはろさんぜるすきんこうにたいざいしておりごるふやてにすをならっていた"
        var leftIndex = text.startIndex

        // ランダムに1~5文字ずつ追加していく
        while leftIndex != text.endIndex {
            let count = Int.random(in: 1 ... 5)
            let rightIndex = text.index(leftIndex, offsetBy: count, limitedBy: text.endIndex) ?? text.endIndex
            let prefix = String(text[leftIndex ..< rightIndex])
            _ = c.insertAtCursorPosition(prefix, inputStyle: .direct)
            let results = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))
            leftIndex = rightIndex
            if rightIndex == text.endIndex {
                XCTAssertEqual(results.mainResults.first?.text, "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた")
            }
        }
    }

    // 1文字ずつ入力するが、時折削除を行う
    // memo: 内部実装としてはdeleted_last_nのテストを意図している
    func testGradualConversionWithDelete() throws {
        // データリソースの場所を指定する
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        let text = Array("ようしょうきからてにすすいえいやきゅうしょうりんじけんぽうなどさまざまなすぽーつをけいけんしながらそだちしょうがっこうじだいはろさんぜるすきんこうにたいざいしておりごるふやてにすをならっていた")
        let deleteIndices = [1, 4, 8, 10, 15, 18, 20, 21, 23, 25, 26, 28, 29, 33, 34, 37, 39, 40, 42, 44, 45, 49, 51, 54, 58, 60, 62, 64, 67, 69, 70, 75, 80]
        for (i, char) in text.enumerated() {
            _ = c.insertAtCursorPosition(String(char), inputStyle: .direct)
            let results = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))
            if deleteIndices.contains(i) {
                let count = i % 3 + 1
                _ = c.deleteBackwardFromCursorPosition(count: count)
                _ = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))

                _ = c.insertAtCursorPosition(String(text[i-count+1 ... i]), inputStyle: .direct)
                _ = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))
            }
            if c.input.count == text.count {
                XCTAssertEqual(results.mainResults.first?.text, "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた")
            }
        }
    }

    // 変換結果が比較的一意なテストケースを無数に持ち、一定の割合を正解することを要求する
    // 辞書を更新した結果性能が悪化したら気付ける
    func testAccuracy() throws {
        // データリソースの場所を指定する
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL

        let cases: [(input: String, expect: String)] = [
            ("3がつ8にち", "3月8日"),
            ("いっていのわりあい", "一定の割合"),
            ("あいふぉんをこうにゅうする", "iPhoneを購入する"),
            ("それはくさ", "それは草"),
            ("おにんぎょうさんみたいだね", "お人形さんみたいだね"),
            ("にほんごぶんぽうのけいしきりろん", "日本語文法の形式理論"),
            ("ぷらすちっくをさくげんするひつようがある", "プラスチックを削減する必要がある"),
            ("きりんさんがすきです", "キリンさんが好きです"),
            ("しんらばんしょうをすべるかみとなる", "森羅万象を統べる神となる"),
            ("よねづけんしのしんきょく", "米津玄師の新曲"),
            ("へいろをけんしゅつするもんだい", "閉路を検出する問題"),
            ("それなすぎる", "それなすぎる"),
            ("きたねえんだよやりかたが", "汚ねえんだよやり方が"),
            ("なにわらってんだよ", "何笑ってんだよ"),
            ("えもみがふかい", "エモみが深い"),
            ("とうごてきかなかんじへんかん", "統語的かな漢字変換"),
            ("あなたとふたりでいきをしていたい", "あなたとふたりで息をしていたい"),
            ("こんごきをつけます", "今後気をつけます"),
            ("ごめいわくをおかけしてもうしわけありません", "ご迷惑をおかけして申し訳ありません"),
            ("どうぞよろしくおねがいいたします", "どうぞよろしくお願いいたします"),
            ("らいぶへんかんでにゅうりょくがかいてきです", "ライブ変換で入力が快適です"),
            ("にんちかがくがえがきだすにんげんのすがた", "認知科学が描き出す人間の姿"),
            ("ぱいそんでかかれたそーすこーど", "Pythonで書かれたソースコード"),
            ("SwiftでつくったApp", "Swiftで作ったApp"),
        ]

        var score: Double = 0
        for (input, expect) in cases {
            let converter = KanaKanjiConverter()
            var c = ComposingText()
            _ = c.insertAtCursorPosition(input, inputStyle: .direct)
            let results = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))

            if results.mainResults.first?.text == expect {
                score += 1
            } else if results.mainResults.count > 1 && results.mainResults[2].text == expect {
                score += 0.5
            }
        }
        let accuracy = score / Double(cases.count)
        XCTAssertGreaterThan(0.8, accuracy)
    }

}
