//
//  ConverterTests.swift
//  azooKeyTests
//
//  Created by ensan on 2023/01/30.
//  Copyright © 2023 ensan. All rights reserved.
//

import KanaKanjiConverterModule
import XCTest

@MainActor final class ConverterTests: XCTestCase {
    func sequentialInput(_ composingText: inout ComposingText, sequence: String, inputStyle: KanaKanjiConverterModule.InputStyle) {
        for char in sequence {
            composingText.insertAtCursorPosition(String(char), inputStyle: inputStyle)
        }
    }

    func requestOptions() -> ConvertRequestOptions {
        ConvertRequestOptions(
            N_best: 5,
            requireJapanesePrediction: true,
            requireEnglishPrediction: false,
            keyboardLanguage: .ja_JP,
            typographyLetterCandidate: false,
            unicodeCandidate: true,
            englishCandidateInRoman2KanaInput: true,
            fullWidthRomanCandidate: false,
            halfWidthKanaCandidate: false,
            learningType: .nothing,
            maxMemoryCount: 0,
            shouldResetMemory: false,
            dictionaryResourceURL: Bundle(for: type(of: self)).bundleURL.appendingPathComponent("Dictionary", isDirectory: true),
            memoryDirectoryURL: URL(fileURLWithPath: ""),
            sharedContainerURL: URL(fileURLWithPath: ""),
            metadata: .init(appVersionString: "Tests")
        )
    }

    func testFullConversion() throws {
        do {
            let converter = KanaKanjiConverter()
            var c = ComposingText()
            c.insertAtCursorPosition("あずーきーはしんじだいのきーぼーどあぷりです", inputStyle: .direct)
            let results = converter.requestCandidates(c, options: requestOptions())
            XCTAssertEqual(results.mainResults.first?.text, "azooKeyは新時代のキーボードアプリです")
        }
        do {
            let converter = KanaKanjiConverter()
            var c = ComposingText()
            c.insertAtCursorPosition("ようしょうきからてにすすいえいやきゅうしょうりんじけんぽうなどさまざまなすぽーつをけいけんしながらそだちしょうがっこうじだいはろさんぜるすきんこうにたいざいしておりごるふやてにすをならっていた", inputStyle: .direct)
            let results = converter.requestCandidates(c, options: requestOptions())
            XCTAssertEqual(results.mainResults.first?.text, "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた")

        }
    }

    // 1文字ずつ変換する
    // memo: 内部実装としては別のモジュールが呼ばれるのだが、それをテストする方法があまりないかもしれない
    func testGradualConversion() throws {
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        let text = "ようしょうきからてにすすいえいやきゅうしょうりんじけんぽうなどさまざまなすぽーつをけいけんしながらそだちしょうがっこうじだいはろさんぜるすきんこうにたいざいしておりごるふやてにすをならっていた"
        for char in text {
            c.insertAtCursorPosition(String(char), inputStyle: .direct)
            let results = converter.requestCandidates(c, options: requestOptions())
            if c.input.count == text.count {
                XCTAssertEqual(results.mainResults.first?.text, "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた")
            }
        }
    }

    // 1文字ずつ変換する
    // memo: 内部実装としては別のモジュールが呼ばれるのだが、それをテストする方法があまりないかもしれない
    func testRoman2KanaGradualConversion() throws {
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        let text = "youshoukikaratenisusuieiyakyuushourinjikenpounadosamazamanasupoーtuwokeikennsinagarasodatishougakkouzidaiharosanzerusukinkounitaizaisiteorigoruhuyatenisuwonaratteita"
        // 許容される変換結果
        let  possibles = [
            "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた",
            "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスをならっていた"
        ]
        for char in text {
            c.insertAtCursorPosition(String(char), inputStyle: .roman2kana)
            let results = converter.requestCandidates(c, options: requestOptions())
            if c.input.count == text.count {
                XCTAssertTrue(possibles.contains(results.mainResults.first!.text))
            }
        }
    }

    // 2,3文字ずつ変換する
    // memo: 内部実装としては別のモジュールが呼ばれるのだが、それをテストする方法があまりないかもしれない
    func testSemiGradualConversion() throws {
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        let text = "ようしょうきからてにすすいえいやきゅうしょうりんじけんぽうなどさまざまなすぽーつをけいけんしながらそだちしょうがっこうじだいはろさんぜるすきんこうにたいざいしておりごるふやてにすをならっていた"
        var leftIndex = text.startIndex

        // ランダムに1~5文字ずつ追加していく
        while leftIndex != text.endIndex {
            let count = Int.random(in: 1 ... 5)
            let rightIndex = text.index(leftIndex, offsetBy: count, limitedBy: text.endIndex) ?? text.endIndex
            let prefix = String(text[leftIndex ..< rightIndex])
            c.insertAtCursorPosition(prefix, inputStyle: .direct)
            let results = converter.requestCandidates(c, options: requestOptions())
            leftIndex = rightIndex
            if rightIndex == text.endIndex {
                XCTAssertEqual(results.mainResults.first?.text, "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた")
            }
        }
    }

    // 1文字ずつ入力するが、時折削除を行う
    // memo: 内部実装としてはdeleted_last_nのテストを意図している
    func testGradualConversionWithDelete() throws {
        let converter = KanaKanjiConverter()
        var c = ComposingText()
        let text = Array("ようしょうきからてにすすいえいやきゅうしょうりんじけんぽうなどさまざまなすぽーつをけいけんしながらそだちしょうがっこうじだいはろさんぜるすきんこうにたいざいしておりごるふやてにすをならっていた")
        let deleteIndices = [1, 4, 8, 10, 15, 18, 20, 21, 23, 25, 26, 28, 29, 33, 34, 37, 39, 40, 42, 44, 45, 49, 51, 54, 58, 60, 62, 64, 67, 69, 70, 75, 80]
        for (i, char) in text.enumerated() {
            c.insertAtCursorPosition(String(char), inputStyle: .direct)
            let results = converter.requestCandidates(c, options: requestOptions())
            if deleteIndices.contains(i) {
                let count = i % 3 + 1
                c.deleteBackwardFromCursorPosition(count: count)
                _ = converter.requestCandidates(c, options: requestOptions())

                c.insertAtCursorPosition(String(text[i - count + 1 ... i]), inputStyle: .direct)
                _ = converter.requestCandidates(c, options: requestOptions())
            }
            if c.input.count == text.count {
                XCTAssertEqual(results.mainResults.first?.text, "幼少期からテニス水泳野球少林寺拳法など様々なスポーツを経験しながら育ち小学校時代はロサンゼルス近郊に滞在しておりゴルフやテニスを習っていた")
            }
        }
    }

    // 必ず正解すべきテストケース
    func testMustCases() throws {
        // ダイレクト入力
        do {
            let cases: [(input: String, expect: String)] = [
                ("つかっている", "使っている"),
                ("しんだどうぶつ", "死んだ動物"),
                ("けいさん", "計算"),
                ("azooKeyのへんかんのうりょく。", "azooKeyの変換能力。"),
                ("じどうAIそうじゅう。", "自動AI操縦。")
            ]

            // full input
            for (input, expect) in cases {
                let converter = KanaKanjiConverter()
                var c = ComposingText()
                sequentialInput(&c, sequence: input, inputStyle: .direct)
                let results = converter.requestCandidates(c, options: requestOptions())
                XCTAssertEqual(results.mainResults.first?.text, expect)
            }
            // gradual input
            for (input, expect) in cases {
                let converter = KanaKanjiConverter()
                var c = ComposingText()
                for char in input {
                    c.insertAtCursorPosition(String(char), inputStyle: .direct)
                    let results = converter.requestCandidates(c, options: requestOptions())
                    if c.input.count == input.count {
                        XCTAssertEqual(results.mainResults.first?.text, expect)
                    }
                }
            }
        }
        // ローマ字入力
        do {
            let cases: [(input: String, expect: String)] = [
                ("tukatteiru", "使っている"),
                ("sindadoubutu", "死んだ動物"),
                ("keisann", "計算")
            ]

            // full input
            for (input, expect) in cases {
                let converter = KanaKanjiConverter()
                var c = ComposingText()
                sequentialInput(&c, sequence: input, inputStyle: .roman2kana)
                let results = converter.requestCandidates(c, options: requestOptions())
                XCTAssertEqual(results.mainResults.first?.text, expect)
            }

            // gradual input
            for (input, expect) in cases {
                let converter = KanaKanjiConverter()
                var c = ComposingText()
                for char in input {
                    c.insertAtCursorPosition(String(char), inputStyle: .roman2kana)
                    let results = converter.requestCandidates(c, options: requestOptions())
                    if c.input.count == input.count {
                        XCTAssertEqual(results.mainResults.first?.text, expect)
                    }
                }
            }
        }
    }

    // 変換結果が比較的一意なテストケースを無数に持ち、一定の割合を正解することを要求する
    // 辞書を更新した結果性能が悪化したら気付ける
    func testAccuracy() throws {
        let cases: [(input: String, expect: [String])] = [
            ("3がつ8にち", ["3月8日"]),
            ("いっていのわりあい", ["一定の割合"]),
            ("あいふぉんをこうにゅうする", ["iPhoneを購入する"]),
            ("それはくさ", ["それは草"]),
            ("おにんぎょうさんみたいだね", ["お人形さんみたいだね"]),
            ("にほんごぶんぽうのけいしきりろん", ["日本語文法の形式理論"]),
            ("ぷらすちっくをさくげんするひつようがある", ["プラスチックを削減する必要がある"]),
            ("きりんさんがすきです", ["キリンさんが好きです"]),
            ("しんらばんしょうをすべるかみとなる", ["森羅万象を統べる神となる"]),
            ("よねづけんしのしんきょく", ["米津玄師の新曲"]),
            ("へいろをけんしゅつするもんだい", ["閉路を検出する問題"]),
            ("それなすぎる", ["それなすぎる"]),
            ("きたねえんだよやりかたが", ["汚ねえんだよやり方が"]),
            ("なにわらってんだよ", ["何笑ってんだよ", "なに笑ってんだよ"]),
            ("えもみがふかい", ["エモみが深い"]),
            ("とうごてきかなかんじへんかん", ["統語的かな漢字変換"]),
            ("あなたとふたりでいきをしていたい", ["あなたとふたりで息をしていたい"]),
            ("こんごきをつけます", ["今後気をつけます"]),
            ("ごめいわくをおかけしてもうしわけありません", ["ご迷惑をおかけして申し訳ありません"]),
            ("どうぞよろしくおねがいいたします", ["どうぞよろしくお願いいたします"]),
            ("らいぶへんかんでにゅうりょくがかいてきです", ["ライブ変換で入力が快適です"]),
            ("にんちかがくがえがきだすにんげんのすがた", ["認知科学が描き出す人間の姿"]),
            ("せいしゃいんになりました", ["正社員になりました"]),
            ("しけんにでないえいたんご", ["試験に出ない英単語"]),
            ("あかるくげんきなせいかつ", ["明るく元気な生活"]),
            ("はるがきたのでかふんがつらい", ["春が来たので花粉が辛い"]),
            ("しょうぼうたいがひっしにかじをしょうかした", ["消防隊が必死に火事を消火した"]),
            ("たけとりものがたりはにほんのこてんぶんがくです", ["竹取物語は日本の古典文学です"]),
            ("よとうもやとうもでぃすればちゅうりつ", ["与党も野党もディスれば中立"]),
            ("だいすきなえしさん", ["大好きな絵師さん"]),
            ("ぱいそんでかかれたそーすこーど", ["Pythonで書かれたソースコード"]),
            ("SwiftでつくったApp", ["Swiftで作ったApp"])
        ]

        var score: Double = 0
        for (input, expect) in cases {
            let converter = KanaKanjiConverter()
            var c = ComposingText()
            c.insertAtCursorPosition(input, inputStyle: .direct)
            let results = converter.requestCandidates(c, options: requestOptions())

            if expect.contains(results.mainResults[0].text) {
                score += 1
            } else if results.mainResults.count > 1 && expect.contains(results.mainResults[1].text) {
                score += 0.5
            }
        }
        let accuracy = score / Double(cases.count)
        print("testAccuracy Result: accuracy \(accuracy), score \(score), count \(cases.count)")
        XCTAssertGreaterThan(accuracy, 0.7) // 0.7 < acuracy
    }

    /// MIDベースの文節単位計算でどれだけ同音異義語の判断が向上しているか確認する。
    func testMeaningBasedConversionAccuracy() throws {
        let cases: [(input: String, expect: String)] = [
            ("しょうぼう、しょうか、ほのお", "消防、消火、炎"),
            ("いえき、しょうか、こうそ", "胃液、消化、酵素"),

            ("さいばん、こうそ、さいこうさい", "裁判、控訴、最高裁"),
            ("すいみん、こうそ、けんこう", "睡眠、酵素、健康"),

            ("かたち、こうし、もよう", "形、格子、模様"),
            ("そりゅうし、こうし、げんし", "素粒子、光子、原子"),
            ("せんせい、こうし、じゅぎょう", "先生、講師、授業"),
            ("けんり、こうし、ぎむ", "権利、行使、義務"),

            ("じこ、しぼう、てんごく", "事故、死亡、天国"),
            ("とくほ、しぼう、ねんしょう", "トクホ、脂肪、燃焼"),
            ("おんしゃ、しぼう、だいがく", "御社、志望、大学"),

            ("しょくぶつ、しゅし、かふん", "植物、種子、花粉"),
            ("ぎろん、しゅし、ろんてん", "議論、趣旨、論点"),
            ("しんたい、しゅし、てさき", "身体、手指、手先"),

            ("とくしゃ、おんしゃ、しけい", "特赦、恩赦、死刑"),
            ("かんじ、おんしゃ、ぶっきょう", "漢字、音写、仏教"),
            ("しゅうでん、きしゃ、ていしゃ", "終電、汽車、停車"),
            ("はっぴょう、きしゃ、しつもん", "発表、記者、質問"),

            ("がくぶ、しゅうし、はかせ", "学部、修士、博士"),
            ("にゅうきん、しゅうし、かくにん", "入金、収支、確認"),
            ("じかん、しゅうし、ふそく", "時間、終始、不足"),

            ("ないかく、しじ、ていめい", "内閣、支持、低迷"),
            ("じょうし、しじ、ぶか", "上司、指示、部下"),

            ("てんこう、きしょう、じょうほう", "天候、気象、情報"),
            ("かれ、きしょう、りょうこう", "彼、気性、良好"),
            ("れあめたる、きしょう、じゅうよう", "レアメタル、希少、重要"),
            ("あさ、きしょう、しっぱい", "朝、起床、失敗"),

            ("かみ、へんざい、ばんぶつ", "神、遍在、万物"),
            ("とみ、へんざい、けいざい", "富、偏在、経済"),

            ("おうよう、きそ、はってん", "応用、基礎、発展"),
            ("たいほ、きそ、さいばん", "逮捕、起訴、裁判"),

            ("じこ、ちめい、しぼう", "事故、致命、死亡"),
            ("ちず、ちめい、ちり", "地図、地名、地理"),

            ("つみ、りょうしん、かしゃく", "罪、良心、呵責"),
            ("ちち、りょうしん、はは", "父、両親、母"),

            ("せいじ、さんかく、みんしゅう", "政治、参画、民衆"),
            ("すうがく、さんかく、しかく", "数学、三角、四角"),

            ("さんかく、しかく、ろっかく", "三角、四角、六角"),
            ("じゅけん、しかく、べんきょう", "受験、資格、勉強"),
            ("ちょうかく、しかく、きゅうかく", "聴覚、視覚、嗅覚"),
            ("あんさつ、しかく、すぱい", "暗殺、刺客、スパイ"),
            ("どうろ、しかく、ちゅうい", "道路、死角、注意"),

            ("せいじ、かくしん、かくめい", "政治、革新、革命"),
            ("しゅちょう、かくしん、ぎろん", "主張、核心、議論"),
            ("せいこう、かくしん、おうえん", "成功、確信、応援"),

            ("せいじ、せいとう、せんきょ", "政治、政党、選挙"),
            ("せいぎ、せいとう、だとう", "正義、正当、妥当"),
            ("おうけ、せいとう、しょうめい", "王家、正統、証明"),
            ("てすと、せいとう、さいてん", "テスト、正答、採点"),

            ("くーでたー、せんきょ、ていこう", "クーデター、占拠、抵抗"),
            ("かいさん、せんきょ、かいし", "解散、選挙、開始"),

            ("まつり、さいてん、えんにち", "祭り、祭典、縁日"),
            ("てすと、さいてん、まるつけ", "テスト、採点、丸つけ"),

            ("やきゅう、しゅうきゅう、てにす", "野球、蹴球、テニス"),
            ("かいしゃ、しゅうきゅう、ふつか", "会社、週休、二日"),

            ("もじ、かんじ、ぞくじ", "文字、漢字、俗字"),
            ("きぶん、かんじ、きもち", "気分、感じ、気持ち"),
            ("しゅさい、かんじ、のみかい", "主催、幹事、飲み会"),

            ("ぎろん、よち、ざんぞん", "議論、余地、残存"),
            ("よげん、よち、みらい", "予言、予知、未来"),

            ("もしゃ、せいぶつ、すけっち", "模写、静物、スケッチ"),
            ("どうぶつ、せいぶつ、しよくぶつ", "動物、生物、植物"),

            ("けんぼう、かいせい、ろんぎ", "憲法、改正、論議"),
            ("みょうじ、かいせい、かいめい", "苗字、改姓、改名"),
            ("ほんじつ、かいせい、てんき", "本日、快晴、天気"),
            ("ぶれーき、かいせい、えんじん", "ブレーキ、回生、エンジン"),

            ("なまえ、かいめい、てつづき", "名前、改名、手続き"),
            ("けんきゅう、かいめい、ろんぶん", "研究、解明、論文"),

            ("ごみ、ほうき、きんし", "ゴミ、放棄、禁止"),
            ("べんごし、ほうき、ほうりつ", "弁護士、法規、法律"),
            ("まじょ、ほうき、まほう", "魔女、箒、魔法"),
            ("みんしゅう、ほうき、かくめい", "民衆、蜂起、革命"),

            ("こうじ、しこう、ごねん", "工事、施工、5年"),
            ("しんぽう、しこう、しがつ", "新法、施行、4月"),
            ("てつがく、しこう、ぎろん", "哲学、思考、議論"),
            ("かくりつ、しこう、かいすう", "確率、試行、回数"),
            ("あじわい、しこう、わいん", "味わい、嗜好、ワイン"),

            ("たいほ、こうりゅう、さいばん", "逮捕、勾留、裁判"),
            ("でんげん、こうりゅう、ちょくりゅう", "電源、交流、直流"),

            ("いでんし、ぶんか、きのう", "遺伝子、分化、機能"),
            ("かがく、ぶんか、ぶんげい", "科学、文化、文芸"),

            ("かがく、ゆうき、むき", "化学、有機、無機"),
            ("いし、ゆうき、しんねん", "意思、勇気、信念"),

            ("かわべ、いし、いわ", "川辺、石、岩"),
            ("しんねん、いし、しそう", "信念、意思、思想"),
            ("びょういん、いし、しんさつ", "病院、医師、診察"),

            ("しかい、しんこう、こうえん", "司会、進行、講演"),
            ("せんそう、しんこう、しんりゃく", "戦争、侵攻、侵略"),
            ("しゅうきょう、しんこう、しんねん", "宗教、信仰、信念"),
            ("きんねん、しんこう、しゅうきょう", "近年、新興、宗教"),

            ("びょういん、しかい、はいしゃ", "病院、歯科医、歯医者"),
            ("もや、しかい、あっか", "モヤ、視界、悪化"),
            ("ばんぐみ、しかい、げいにん", "番組、司会、芸人"),

            ("こども、こうえん、おにごっこ", "子供、公園、鬼ごっこ"),
            ("せいじか、こうえん、しちょう", "政治家、講演、視聴"),
            ("ちけっと、こうえん、よやく", "チケット、公演、予約"),

            ("くるま、はいしゃ、すくらっぷ", "車、廃車、スクラップ"),
            ("むしば、はいしゃ、ちりょう", "虫歯、歯医者、治療"),
            ("こんてすと、はいしゃ、ふっかつ", "コンテスト、敗者、復活"),
            ("むりょう、はいしゃ、たくしー", "無料、配車、タクシー"),

            ("じんせい、しょうがい、ろうねん", "人生、生涯、老年"),
            ("ちょうかく、しょうがい、ほじょ", "聴覚、障害、補助"),

            ("ぐんたい、ぶたい、ぜんめつ", "軍隊、部隊、全滅"),
            ("あいどる、ぶたい、おうえん", "アイドル、舞台、応援"),

            ("けいざい、かぶ、げらく", "経済、株、下落"),
            ("やさい、かぶ、りょうり", "野菜、カブ、料理"),
            ("ぺーじ、かぶ、がぞう", "ページ、下部、画像"),

            ("きまつ、かだい、ていしゅつ", "期末、課題、提出"),
            ("のうりょく、かだい、ひょうか", "能力、過大、評価"),

            ("しんらばんしょうをすべるかみ", "森羅万象を統べる神"),
            ("こおりをすべるすけーと", "氷を滑るスケート"),
            ("おわらいをすべるげいにん", "お笑いをスベる芸人"),

            ("ざっしにのるないよう", "雑誌に載る内容"),
            ("くるまにのるひと", "車に乗る人"),

            ("つなみ、てんさい、わざわい", "津波、天災、災い"),
            ("さいのう、てんさい、のうりょく", "才能、天才、能力"),
            ("がぞう、てんさい、きょか", "画像、転載、許可"),

            ("ひょうしき、きんし、かんばん", "標識、禁止、看板"),
            ("こんたくと、きんし、ろうがん", "コンタクト、近視、老眼"),
            ("せいぶつ、きんし、ばくてりあ", "生物、菌糸、バクテリア"),

            ("しょり、こうそく、はんてい", "処理、高速、判定"),
            ("ぶつり、こうそく、げんかい", "物理、光速、限界"),
            ("しんたい、こうそく、たいほ", "身体、拘束、逮捕"),
            ("がっこう、こうそく、るーる", "学校、校則、ルール"),

            ("しへい、こうか、じゅうえん", "紙幣、硬貨、10円"),
            ("ねだん、こうか、かいとり", "値段、高価、買取"),
            ("くすり、こうか、けんしょう", "薬、効果、検証"),
            ("でんちゅう、こうか、かせん", "電柱、高架、架線"),
            ("がっこう、こうか、がっしょう", "学校、校歌、合唱"),
            ("ぱらしゅーと、こうか、らっか", "パラシュート、降下、落下"),

            ("がぞう、かこう、へんしゅう", "画像、加工、編集"),
            ("じょうしょう、かこう、けんしょう", "上昇、下降、減少"),
            ("かせん、かこう、かわべ", "河川、河口、川辺"),
            ("かざん、かこう、ふんか", "火山、火口、噴火"),

            ("いっとうしょう、けんしょう、おうぼ", "一等賞、懸賞、応募"),
            ("かせつ、けんしょう、じっし", "仮説、検証、実施"),
            ("けんぽう、けんしょう、じょうやく", "憲法、憲章、条約"),

            ("じんこう、げんしょう、りゆう", "人口、減少、理由"),
            ("かがく、げんしょう、けんきゅう", "科学、現象、研究"),

            ("ないふ、きょうき、さつがい", "ナイフ、凶器、殺害"),
            ("せいしん、きょうき、はっきょう", "精神、狂気、発狂"),

            ("しゅうきょう、きょうぎ、きょうそ", "宗教、教義、教祖"),
            ("たいおう、きょうぎ、けんとう", "対応、協議、検討"),
            ("すぽーつ、きょうぎ、しょうぶ", "スポーツ、競技、勝負"),
            ("じしょ、きょうぎ、いみ", "辞書、狭義、意味"),

            ("じんじゃ、じしゃ、ぶっきよう", "神社、寺社、仏教"),
            ("へいしゃ、じしゃ、せいひん", "弊社、自社、製品"),

            ("こうぎょう、きかく、とういつ", "工業、規格、統一"),
            ("いべんと、きかく、かいさい", "イベント、企画、開催"),

            ("めがさめたあさ", "目が覚めた朝"),
            ("ねつがさめたりょうり", "熱が冷めた料理"),

            ("どうぶつがないたこえ。", "動物が鳴いた声。"),
            ("かれがないたこえ。", "彼が泣いた声。"),

            ("りょうりがあついのでさます", "料理が熱いので冷ます"),
            ("だいこんがあついのでうすくきる", "大根が厚いので薄く切る"),
            ("へやがあついのですずしくする", "部屋が暑いので涼しくする"),

            ("みらい、こだい、げんだい", "未来、古代、現代"),
            ("せんでん、こだい、こうこく", "宣伝、誇大、広告"),

            ("かじょう、せいさん、しゅうりょう", "過剰、生産、終了"),
            ("さんげき、せいさん、じけん", "惨劇、凄惨、事件"),
            ("けいひ、せいさん、れしーと", "経費、生産、レシート"),

            ("しんぷ、せいしょく、きょうかい", "神父、聖職、教会"),
            ("こうび、せいしょく、しゅっさん", "交尾、生殖、出産"),

            ("やさいをきるほうちょう", "野菜を切る包丁"),
            ("きものをきるしゅみ", "着物を着る趣味"),

            ("さーびす、たいかい、てつづき", "サービス、退会、手続き"),
            ("はなび、たいかい、ゆかた", "花火、大会、浴衣"),

            ("しゅみ、はいかい、はいく", "趣味、俳諧、俳句"),
            ("ろうじん、はいかい、にんちしょう", "老人、徘徊、認知症"),

            ("おやににたかお", "親に似た顔"),
            ("じっくりにたにく", "じっくり煮た肉"),

            ("ちりょう、なんこう、しゅじゅつ", "治療、難航、手術"),
            ("ぬりぐすり、なんこう、ききめ", "塗り薬、軟膏、効き目"),

            ("ようえき、ようかい、ようしつ", "溶液、溶解、溶質"),
            ("おばけ、ようかい、ゆうれい", "お化け、妖怪、幽霊"),

            ("りょうち、りょうかい、りょうど", "領地、領海、領土"),
            ("おーけー、りょうかい、しょうち", "OK、了解、承知"),

            ("がっこう、こうしょう、ばっじ", "学校、校章、バッジ"),
            ("かいぎ、こうしょう、しっぱい", "会議、交渉、失敗"),

            ("ようちえん、ようじ、よういく", "幼稚園、幼児、養育"),
            ("きんきゅう、ようじ、きたく", "緊急、用事、帰宅"),

            ("おやぶん、こぶん", "親分、子分"),
            ("かんぶん、こぶん", "漢文、古文")
        ]

        var score: Double = 0
        for (input, expect) in cases {
            let converter = KanaKanjiConverter()
            var c = ComposingText()
            c.insertAtCursorPosition(input, inputStyle: .direct)
            var options = requestOptions()
            options.requireJapanesePrediction = false
            let results = converter.requestCandidates(c, options: options)

            if results.mainResults[0].text == expect {
                score += 1
            } else if results.mainResults.count > 1 && results.mainResults[1].text == expect {
                score += 0.5
            }
        }
        let accuracy = score / Double(cases.count)
        print("testMeaningBasedConversionAccuracy Result: accuracy \(accuracy), score \(score), count \(cases.count)")
        XCTAssertGreaterThan(accuracy, 0.7) // 0.7 < accuracy
    }
}
