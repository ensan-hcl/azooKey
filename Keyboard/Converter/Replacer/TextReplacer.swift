//
//  TextReplacer.swift
//  Keyboard
//
//  Created by ensan on 2023/03/17.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation

/// `TextReplacer`は前後の文脈に基づいて、現在のカーソル位置の語の置き換えを提案するためのモジュールである。
/// 例えば、「tha|nk」と入力があるとき、「think」や「thanks」などを候補として表示することが考えられる。
///
/// 現在の機能は「絵文字」のバリエーションを表示することに限定する。
struct TextReplacer {
    // TODO: prefix trieなどの方が便利だと思う
    private var emojiSearchDict: [String: [String]] = [:]
    private var emojiGroups: [EmojiGroup] = []

    init() {
        let fileURL: URL
        // 読み込むファイルはバージョンごとに変更する必要がある
        if #available(iOS 16.4, *) {
            fileURL = Bundle.main.bundleURL.appendingPathComponent("emoji_all_E15.0.txt.gen", isDirectory: false)
        } else if #available(iOS 15.4, *) {
            fileURL = Bundle.main.bundleURL.appendingPathComponent("emoji_all_E14.0.txt.gen", isDirectory: false)
        } else {
            fileURL = Bundle.main.bundleURL.appendingPathComponent("emoji_all_E13.1.txt.gen", isDirectory: false)
        }
        var emojiSearchDict: [String: [String]] = [:]
        var emojiGroups: [EmojiGroup] = []
        do {
            let string = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = string.split(separator: "\n")
            for line in lines {
                let splited = line.split(separator: "\t", omittingEmptySubsequences: false)
                guard splited.count == 3 else {
                    debug("error", line)
                    self.emojiSearchDict = emojiSearchDict
                    self.emojiGroups = emojiGroups
                    return
                }
                let base = String(splited[0])
                let variations = splited[2].split(separator: ",").map(String.init)
                // 検索クエリを登録
                for query in splited[1].split(separator: ",") {
                    emojiSearchDict[String(query), default: []].append(base)
                    emojiSearchDict[String(query), default: []].append(contentsOf: variations)
                }
                emojiGroups.append(EmojiGroup(base: base, variations: variations))
            }
            self.emojiGroups = emojiGroups
            self.emojiSearchDict = emojiSearchDict
        } catch {
            debug(error)
            self.emojiSearchDict = emojiSearchDict
            self.emojiGroups = emojiGroups
            return
        }
    }

    func getSearchResult(query: String, target: [ConverterBehaviorSemantics.ReplacementTarget]) -> [any ResultViewItemData] {
        // 正規化する
        let query = query.lowercased().toHiragana()
        var results: [any ResultViewItemData] = []
        if target.contains(.emoji) {
            if let candidates = self.emojiSearchDict[query] {
                for candidate in candidates {
                    results.append(SearchResultItem(query: query, text: candidate))
                }
            }
        }
        return results
    }

    struct SearchResultItem: ResultViewItemData {
        var query: String
        var text: String
        var inputable: Bool {
            true
        }
        func getDebugInformation() -> String {
            "SearchResultItem(\(text))"
        }
    }

    func getReplacementCandidate(left: String, center: String, right: String, target: [ConverterBehaviorSemantics.ReplacementTarget]) -> [ReplacementCandidate] {
        var results: [ReplacementCandidate] = []
        if target.contains(.emoji) {
            if center.count == 1, let item = self.emojiGroups.first(where: {$0.all.contains(center)}) {
                // 選択部分の置換
                for emoji in item.all where emoji != center {
                    results.append(ReplacementCandidate(target: center, replace: emoji, base: item.base, targetType: .emoji))
                }
            } else if let last = left.last.map(String.init), let item = self.emojiGroups.first(where: {$0.all.contains(last)}) {
                // 左側の置換
                for emoji in item.all where emoji != last {
                    results.append(ReplacementCandidate(target: last, replace: emoji, base: item.base, targetType: .emoji))
                }
            }
        }
        return results
    }

    /// 「同一」の絵文字のグループ
    private struct EmojiGroup {
        var base: String
        var variations: [String]
        var all: [String] {
            [base] + variations
        }
    }
}

struct ReplacementCandidate: ResultViewItemData {
    var target: String
    var replace: String
    var base: String
    var targetType: ConverterBehaviorSemantics.ReplacementTarget

    var text: String {
        replace
    }
    var inputable: Bool {
        true
    }

    func getDebugInformation() -> String {
        "ReplacementCandidate(\(target)->\(replace))"
    }
}
