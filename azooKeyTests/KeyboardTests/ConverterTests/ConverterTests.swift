//
//  ConverterTests.swift
//  azooKeyTests
//
//  Created by β α on 2023/01/30.
//  Copyright © 2023 DevEn3. All rights reserved.
//

import XCTest

final class ConverterTests: XCTestCase {
    func testFullConversion() throws {
        // データリソースの場所を指定する
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        _ = c.insertAtCursorPosition("あずーきーはしんじだいのきーぼーどあぷりです", inputStyle: .direct)
        let results = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))
        XCTAssertEqual(results.mainResults.first?.text, "azooKeyは新時代のキーボードアプリです")
    }

    // 1文字ずつ変換する
    // memo: 内部実装としては別のモジュールが呼ばれるのだが、それをテストする方法があまりないかもしれない
    func testGradualConversion() throws {
        // データリソースの場所を指定する
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        let text = "あずーきーはしんじだいのきーぼーどあぷりです"
        for char in text {
            _ = c.insertAtCursorPosition(String(char), inputStyle: .direct)
            let results = converter.requestCandidates(c, options: ConvertRequestOptions(N_best: 5, requireJapanesePrediction: true))
            if c.convertTarget == text {
                XCTAssertEqual(results.mainResults.first?.text, "azooKeyは新時代のキーボードアプリです")
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
