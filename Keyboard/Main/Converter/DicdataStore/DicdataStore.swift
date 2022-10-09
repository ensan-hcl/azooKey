//
//  DicdataStore.swift
//  Keyboard
//
//  Created by β α on 2020/09/17.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

final class OSUserDict {
    var dict: DicdataStore.Dicdata = []
}

final class DicdataStore {
    init() {
        debug("DicdataStoreが初期化されました")
        self.setup()
    }

    typealias Dicdata = [DicdataElement]
    private var ccParsed: [Bool] = .init(repeating: false, count: 1319)
    private var ccLines: [[Int: PValue]] = []
    private var mmValue: [PValue] = []
    private let treshold: PValue = -17

    private var loudses: [String: LOUDS] = [:]
    private var importedLoudses: Set<String> = []
    private var charsID: [Character: UInt8] = [:]
    private var memory: LearningMemorys = LearningMemorys()
    private var zeroHintPredictionDicdata: Dicdata?

    private var osUserDict = OSUserDict()

    internal let maxlength: Int = 20
    private let midCount = 502
    private let cidCount = 1319

    private let numberFormatter = NumberFormatter()
    /// 初期化時のセットアップ用の関数。プロパティリストを読み込み、連接確率リストを読み込んで行分割し保存しておく。
    private func setup() {
        numberFormatter.numberStyle = .spellOut
        numberFormatter.locale = .init(identifier: "ja-JP")
        self.ccLines = [[Int: PValue]].init(repeating: [:], count: cidCount)

        do {
            let string = try String(contentsOfFile: Bundle.main.bundlePath + "/charID.chid", encoding: String.Encoding.utf8)
            charsID = [Character: UInt8].init(uniqueKeysWithValues: string.enumerated().map {($0.element, UInt8($0.offset))})
        } catch {
            debug("ファイルが存在しません: \(error)")
        }
        do {
            let url = Bundle.main.bundleURL.appendingPathComponent("mm.binary")
            do {
                let binaryData = try Data(contentsOf: url, options: [.uncached])
                let ui64array = binaryData.withUnsafeBytes {pointer -> [Float] in
                    return Array(
                        UnsafeBufferPointer(
                            start: pointer.baseAddress!.assumingMemoryBound(to: Float.self),
                            count: pointer.count / MemoryLayout<Float>.size
                        )
                    )
                }
                self.mmValue = ui64array.map {PValue($0)}
            } catch {
                debug("Failed to read the file.")
                self.mmValue = [PValue].init(repeating: .zero, count: self.midCount*self.midCount)
            }
        }
        _ = self.loadLOUDS(identifier: "user")
    }

    func sendToDicdataStore(_ data: KeyboardActionDepartment.DicdataStoreNotification) {
        switch data {
        case .notifyAppearAgain:
            break
        case .reloadUserDict:
            self.reloadUserDict()
        case let .notifyLearningType(type):
            self.memory.notifyChangeLearningType(type)
        case .closeKeyboard:
            self.closeKeyboard()
        case .resetMemory:
            self.memory.reset()
        case let .importOSUserDict(osUserDict):
            self.osUserDict = osUserDict
        }
    }

    private func closeKeyboard() {
        self.memory.save()
    }

    private func reloadUserDict() {
        _ = self.loadLOUDS(identifier: "user")
    }

    /// ペナルティ関数。文字数で決める。
    private func getPenalty(data: DicdataElement) -> PValue {
        return -2.0/PValue(data.word.count)
    }

    /// 計算時に利用。無視すべきデータかどうか。
    private func shouldBeRemoved(value: PValue, wordCount: Int) -> Bool {
        let d = value - self.treshold
        if d < 0 {
            return true
        }
        return 2.0/PValue(wordCount) < -d
    }

    /// 計算時に利用。無視すべきデータかどうか。
    internal func shouldBeRemoved(data: DicdataElement) -> Bool {
        let value = data.value()
        if value <= -30 {
            return true
        }
        let d = value - self.treshold
        if d < 0 {
            return true
        }
        return self.getPenalty(data: data) < -d
    }

    private func loadLOUDS(identifier: String) -> LOUDS? {
        if importedLoudses.contains(identifier) {
            return self.loudses[identifier]
        }

        importedLoudses.insert(identifier)
        if let louds = LOUDS.build(identifier) {
            self.loudses[identifier] = louds
            return louds
        } else {
            debug("loudsの読み込みに失敗、identifierは\(identifier)")
            return nil
        }
    }

    private func perfectMatchLOUDS(identifier: String, key: String) -> [Int] {
        guard let louds = self.loadLOUDS(identifier: identifier) else {
            return []
        }
        return [louds.searchNodeIndex(chars: key.map {self.charsID[$0, default: .max]})].compactMap {$0}
    }

    private func throughMatchLOUDS(identifier: String, key: String) -> [Int] {
        guard let louds = self.loadLOUDS(identifier: identifier) else {
            return []
        }
        return louds.byfixNodeIndices(chars: key.map {self.charsID[$0, default: .max]})
    }

    private func prefixMatchLOUDS(identifier: String, key: String, depth: Int = .max) -> [Int] {
        guard let louds = self.loadLOUDS(identifier: identifier) else {
            return []
        }
        return louds.prefixNodeIndices(chars: key.map {self.charsID[$0, default: .max]}, maxDepth: depth)
    }

    private func getDicdata(identifier: String, indices: Set<Int>) -> Dicdata {
        // split = 2048
        let dict = [Int: [Int]].init(grouping: indices, by: {$0 >> 11})
        var data: Dicdata = []
        for (key, value) in dict {
            let strings = LOUDS.getData(identifier + "\(key)", indices: value.map {$0 & 2047})
                .flatMap {$0.split(separator: ",", omittingEmptySubsequences: false)}
            data.reserveCapacity(data.count + strings.count)
            for string in strings {
                let splited = string.split(separator: "\t", omittingEmptySubsequences: false)
                if splited.count <= 5 {
                    continue
                }
                data.append(self.convertDicdata(from: splited))
            }
        }
        return data
    }

    /// kana2latticeから参照する。
    /// - Parameters:
    ///   - inputData: 入力データ
    ///   - from: 起点
    ///   - toIndexRange: `from ..< (toIndexRange)`の範囲で辞書ルックアップを行う。
    internal func getLOUDSDataInRange(inputData: ComposingText, from fromIndex: Int, toIndexRange: Range<Int>? = nil) -> [LatticeNode] {
        // ⏱0.426499 : 辞書読み込み_全体
        let toIndexLeft = toIndexRange?.startIndex ?? fromIndex
        let toIndexRight = toIndexRange?.endIndex ?? (min(inputData.input.count, fromIndex + self.maxlength))
        if fromIndex > toIndexLeft || toIndexLeft >= toIndexRight {
            return []
        }
        let segments = (fromIndex ..< toIndexRight).reduce(into: []) { (segments: inout [String], rightIndex: Int) in
            segments.append((segments.last ?? "") + String(inputData.input[rightIndex].character.toKatakana()))
        }
        // MARK: 誤り訂正の対象を列挙する。比較的重い処理。
        var (stringWithTypoData, string2segment) = inputData.getRangesWithTypos(fromIndex, rightIndexRange: (toIndexLeft ..< toIndexRight))
        let string2penalty = [String: PValue].init(stringWithTypoData, uniquingKeysWith: {max($0, $1)})

        // MARK: 検索対象を列挙していく。prefixの共通するものを削除して検索をなるべく減らすことが目的。
        // ⏱0.021212 : 辞書読み込み_検索対象列挙
        // prefixの共通するものを削除して検索をなるべく減らす
        let strings = stringWithTypoData.map { $0.string }
        let stringSet = strings.reduce(into: Set(strings)) { (`set`, string) in
            if string.count > 4 {
                return
            }
            if set.contains(where: {$0.hasPrefix(string) && $0 != string}) {
                set.remove(string)
            }
        }

        // MARK: 列挙した検索対象から、順に検索を行う。この時点ではindicesを取得するのみ。
        // ⏱0.222327 : 辞書読み込み_検索
        // 先頭の文字: そこで検索したい文字列の集合
        let group = [Character: [String]].init(grouping: stringSet, by: {$0.first!})

        var indices: [(String, Set<Int>)] = group.map {dic in
            let key = String(dic.key)
            let set = dic.value.flatMapSet {string in self.throughMatchLOUDS(identifier: key, key: string)}
            return (key, set)
        }
        indices.append(("user", stringSet.flatMapSet {self.throughMatchLOUDS(identifier: "user", key: $0)}))

        // MARK: 検索によって得たindicesから辞書データを実際に取り出していく
        // ⏱0.077118 : 辞書読み込み_辞書データ生成
        var dicdata: Dicdata = []
        for (identifier, value) in indices {
            let result = self.getDicdata(identifier: identifier, indices: value)
            dicdata.reserveCapacity(dicdata.count + result.count)
            for data in result {
                let penalty = string2penalty[data.ruby, default: .zero]
                if penalty.isZero {
                    dicdata.append(data)
                    continue
                }
                let ratio = Self.penaltyRatio[data.lcid]
                let pUnit: PValue = self.getPenalty(data: data)/2   // 負の値
                let adjust = pUnit * penalty * ratio
                if self.shouldBeRemoved(value: data.value() + adjust, wordCount: data.ruby.count) {
                    continue
                }
                dicdata.append(data.adjustedData(adjust))
            }
        }

        for i in toIndexLeft ..< toIndexRight {
            do {
                let result = self.getWiseDicdata(head: segments[i-fromIndex], allowRomanLetter: i+1 == toIndexRight)
                for item in result {
                    string2segment[item.ruby] = i
                }
                dicdata.append(contentsOf: result)
            }
            do {
                let result = self.getMatch(segments[i-fromIndex])
                for item in result {
                    string2segment[item.ruby] = i
                }
                dicdata.append(contentsOf: result)
            }
            do {
                let result = self.getMatchOSUserDict(segments[i-fromIndex])
                for item in result {
                    string2segment[item.ruby] = i
                }
                dicdata.append(contentsOf: result)
            }
        }

        if fromIndex == .zero {
            let result: [LatticeNode] = dicdata.map {
                let node = LatticeNode(data: $0, inputRange: fromIndex ..< string2segment[$0.ruby, default: fromIndex] + 1)
                node.prevs.append(RegisteredNode.BOSNode())
                return node
            }
            return result
        } else {
            let result: [LatticeNode] = dicdata.map {LatticeNode(data: $0, inputRange: fromIndex ..< string2segment[$0.ruby, default: fromIndex] + 1)}
            return result
        }
    }

    /// kana2latticeから参照する。louds版。
    /// - Parameters:
    ///   - inputData: 入力データ
    ///   - from: 始点
    ///   - to: 終点
    internal func getLOUDSData(inputData: ComposingText, from fromIndex: Int, to toIndex: Int) -> [LatticeNode] {
        if toIndex - fromIndex > self.maxlength || fromIndex > toIndex {
            return []
        }
        let segment = inputData.input[fromIndex...toIndex].reduce(into: ""){$0.append($1.character)}.toKatakana()

        let stringWithTypoData = inputData.getRangeWithTypos(fromIndex, toIndex)
        let string2penalty = [String: PValue].init(stringWithTypoData, uniquingKeysWith: {max($0, $1)})

        // MARK: 検索によって得たindicesから辞書データを実際に取り出していく
        // 先頭の文字: そこで検索したい文字列の集合
        let group = [Character: [String]].init(grouping: stringWithTypoData.map {$0.string}, by: {$0.first!})

        var indices: [(String, Set<Int>)] = group.map {dic in
            let key = String(dic.key)
            let set = dic.value.flatMapSet { string in
                self.perfectMatchLOUDS(identifier: key, key: string)
            }
            return (key, set)
        }
        let set = stringWithTypoData.flatMapSet { (string, _) in
            self.perfectMatchLOUDS(identifier: "user", key: string)
        }
        indices.append(("user", set))
        var dicdata: Dicdata = []
        for (identifier, value) in indices {
            let result: Dicdata = self.getDicdata(identifier: identifier, indices: value).compactMap {(data: Dicdata.Element) in
                let penalty = string2penalty[data.ruby, default: .zero]
                if penalty.isZero {
                    return data
                }
                let ratio = Self.penaltyRatio[data.lcid]
                let pUnit: PValue = self.getPenalty(data: data)/2   // 負の値
                let adjust = pUnit * penalty * ratio
                if self.shouldBeRemoved(value: data.value() + adjust, wordCount: data.ruby.count) {
                    return nil
                }
                return data.adjustedData(adjust)
            }
            dicdata.append(contentsOf: result)
        }

        dicdata.append(contentsOf: self.getWiseDicdata(head: segment, allowRomanLetter: toIndex == inputData.input.count - 1))
        dicdata.append(contentsOf: self.getMatch(segment))
        dicdata.append(contentsOf: self.getMatchOSUserDict(segment))
        if fromIndex == .zero {
            let result: [LatticeNode] = dicdata.map {
                let node = LatticeNode(data: $0, inputRange: fromIndex ..< toIndex+1)
                node.prevs.append(RegisteredNode.BOSNode())
                return node
            }
            return result
        } else {
            let result: [LatticeNode] = dicdata.map {LatticeNode(data: $0, inputRange: fromIndex ..< toIndex+1)}
            return result
        }
    }

    internal func getZeroHintPredictionDicdata() -> Dicdata {
        if let dicdata = self.zeroHintPredictionDicdata {
            return dicdata
        }
        do {
            let csvString = try String(contentsOfFile: Bundle.main.bundlePath + "/p_null.csv", encoding: String.Encoding.utf8)
            let csvLines = csvString.split(separator: "\n")
            let csvData = csvLines.map {$0.split(separator: ",", omittingEmptySubsequences: false)}
            let dicdata: Dicdata = csvData.map {convertDicdata(from: $0)}
            self.zeroHintPredictionDicdata = dicdata
            return dicdata
        } catch {
            debug(error)
            self.zeroHintPredictionDicdata = []
            return []
        }
    }

    /// 辞書から予測変換データを読み込む関数
    /// - Parameters:
    ///   - head: 辞書を引く文字列
    /// - Returns:
    ///   発見されたデータのリスト。
    internal func getPredictionLOUDSDicdata(head: some StringProtocol) -> Dicdata {
        let count = head.count
        if count == .zero {
            return []
        }
        if count == 1 {
            do {
                let csvString = try String(contentsOfFile: Bundle.main.bundlePath + "/p_\(head).csv", encoding: String.Encoding.utf8)
                let csvLines = csvString.split(separator: "\n")
                let csvData = csvLines.map {$0.split(separator: ",", omittingEmptySubsequences: false)}
                let dicdata: Dicdata = csvData.map {self.convertDicdata(from: $0)}
                return dicdata
            } catch {
                debug("ファイルが存在しません: \(error)")
                return []
            }
        } else if count == 2 {
            let first = String(head.first!)
            // 最大700件に絞ることによって低速化を回避する。
            // FIXME: 場当たり的な対処。改善が求められる。
            let prefixIndices = self.prefixMatchLOUDS(identifier: first, key: String(head), depth: 5).prefix(700)
            return self.getDicdata(identifier: first, indices: Set(prefixIndices))
        } else {
            let first = String(head.first!)
            let prefixIndices = self.prefixMatchLOUDS(identifier: first, key: String(head)).prefix(700)
            return self.getDicdata(identifier: first, indices: Set(prefixIndices))
        }
    }

    private func convertDicdata(from dataString: [some StringProtocol]) -> DicdataElement {
        let ruby = String(dataString[0])
        let word = dataString[1].isEmpty ? ruby:String(dataString[1])
        let lcid = Int(dataString[2]) ?? .zero
        let rcid = Int(dataString[3]) ?? lcid
        let mid = Int(dataString[4]) ?? .zero
        let value: PValue = PValue(dataString[5]) ?? -30.0
        let element = DicdataElement(word: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: value)
        let adjust: PValue = PValue(self.getSingleMemory(element) * 3)
        return element.adjustedData(adjust)
    }

    /// 補足的な辞書情報を得る。
    ///  - parameters:
    ///     - head: 先頭の単語の文字列
    /// - note
    ///     - 入力全体をカタカナとかひらがなに変換するやつは、Converter側でやっているので注意。
    private func getWiseDicdata(head: String, allowRomanLetter: Bool) -> Dicdata {
        var result: Dicdata = []
        result.append(contentsOf: self.getJapaneseNumberDicdata(head: head))
        if let number = Float(head) {
            result.append(DicdataElement(ruby: head, cid: CIDData.数.cid, mid: 361, value: -14))
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                let int = Int(number)
                if int < Int(1E18) && -Int(1E18) < int, let kansuji = self.numberFormatter.string(from: NSNumber(value: int)) {
                    result.append(DicdataElement(word: kansuji, ruby: head, cid: CIDData.数.cid, mid: 361, value: -16))
                }
            }
        }

        // headを英単語として候補に追加する
        if VariableStates.shared.keyboardLanguage == .en_US && head.onlyRomanAlphabet {
            result.append(DicdataElement(ruby: head, cid: CIDData.固有名詞.cid, mid: 40, value: -14))
        }
        // 入力を全てひらがな、カタカナに変換したものを候補に追加する
        // ローマ字変換の場合、先頭を単体でひらがな・カタカナ化した候補も追加
        if VariableStates.shared.keyboardLanguage != .en_US && VariableStates.shared.inputStyle == .roman2kana {
            if let katakana = Roman2Kana.katakanaChanges[head], let hiragana = Roman2Kana.hiraganaChanges[head] {
                result.append(DicdataElement(word: hiragana, ruby: katakana, cid: CIDData.固有名詞.cid, mid: 501, value: -13))
                result.append(DicdataElement(ruby: katakana, cid: CIDData.固有名詞.cid, mid: 501, value: -14))
            }
        }

        if head.count == 1, allowRomanLetter || !head.onlyRomanAlphabet {
            let hira = head.toKatakana()
            if head == hira {
                result.append(DicdataElement(ruby: head, cid: CIDData.固有名詞.cid, mid: 501, value: -14))
            } else {
                result.append(DicdataElement(word: hira, ruby: head, cid: CIDData.固有名詞.cid, mid: 501, value: -13))
                result.append(DicdataElement(ruby: head, cid: CIDData.固有名詞.cid, mid: 501, value: -14))
            }
        }

        // 記号変換
        if head.count == 1, let first = head.first {
            var value: PValue = -14
            let hs = Self.fullwidthToHalfwidth[first, default: first]

            if hs != first {
                result.append(DicdataElement(word: head, ruby: head, cid: CIDData.記号.cid, mid: 501, value: value))
                value -= 0.1
                result.append(DicdataElement(word: String(hs), ruby: head, cid: CIDData.記号.cid, mid: 501, value: value))
                value -= 0.1
            }
            if let fs = Self.halfwidthToFullwidth[first], fs != first {
                result.append(DicdataElement(word: head, ruby: head, cid: CIDData.記号.cid, mid: 501, value: value))
                value -= 0.1
                result.append(DicdataElement(word: String(fs), ruby: head, cid: CIDData.記号.cid, mid: 501, value: value))
                value -= 0.1
            }
            for group in Self.weakRelatingSymbolGroups where group.contains(hs) {
                for symbol in group where symbol != hs {
                    result.append(DicdataElement(word: String(symbol), ruby: head, cid: CIDData.記号.cid, mid: 501, value: value))
                    value -= 0.1
                    if let fs = Self.halfwidthToFullwidth[symbol] {
                        result.append(DicdataElement(word: String(fs), ruby: head, cid: CIDData.記号.cid, mid: 501, value: value))
                        value -= 0.1
                    }
                }
            }
        }
        return result
    }

    // 記号に対する半角・全角変換
    private static let (fullwidthToHalfwidth, halfwidthToFullwidth) = zip(
        "＋ー＊＝・！＃％＆＇＂〜｜￡＄￥＠｀；：＜＞，．＼／＿￣－",
        "＋ー＊＝・！＃％＆＇＂〜｜￡＄￥＠｀；：＜＞，．＼／＿￣－".applyingTransform(.fullwidthToHalfwidth, reverse: false)!
    )
    .reduce(into: ([Character: Character](), [Character: Character]())) { (results: inout ([Character: Character], [Character: Character]), values: (Character, Character)) in
        results.0[values.0] = values.1
        results.1[values.1] = values.0
    }

    // 弱い類似(矢印同士のような関係)にある記号をグループにしたもの
    // 例えば→に対して⇒のような記号はより類似度が強いため、上位に出したい。これを実現する必要が生じた場合はstrongRelatingSymbolGroupsを新設する。
    // 宣言順不同
    // 1つを入れると他が出る、というイメージ
    // 半角と全角がある場合は半角のみ
    private static let weakRelatingSymbolGroups: [[Character]] = [
        // 異体字セレクト用 (試験実装)
        ["高", "髙"],
        ["斎", "斉", "齋", "齊"],
        ["澤", "沢"],
        ["気", "氣"],
        ["澁", "渋"],
        ["対", "對"],
        ["辻󠄀", "辻󠄀"],

        // 記号変換
        ["☆", "★", "♡", "☾", "☽"],  // 星
        ["^", "＾"],  // ハット
        ["¥", "$", "¢", "€", "£", "₿"], // 通貨
        ["%", "‰"], // パーセント
        ["°", "℃", "℉"],
        ["◯"], // 図形
        ["*", "※", "✳︎", "✴︎"],   // こめ
        ["・", "…", "‥", "•"],
        ["+", "±", "⊕"],
        ["×", "❌", "✖️"],
        ["÷", "➗",],
        ["<", "≦", "≪", "〈", "《", "‹", "«"],
        [">", "≧", "≫", "〉", "》", "›", "»"],
        ["=", "≒", "≠", "≡"],
        [":", ";"],
        ["!", "❗️", "❣️", "‼︎", "⁉︎", "❕", "‼️", "⁉️", "¡"],
        ["?", "❓", "⁉︎", "⁇", "❔", "⁉️", "¿"],
        ["〒", "〠", "℡", "☎︎"],
        ["々", "ヾ", "ヽ", "ゝ", "ゞ", "〃", "仝", "〻"],
        ["〆", "〼", "ゟ", "ヿ"], // 特殊仮名
        ["♂", "♀", "⚢", "⚣", "⚤", "⚥", "⚦", "⚧", "⚨", "⚩", "⚪︎", "⚲"], // ジェンダー記号
        ["→", "↑", "←", "↓", "↙︎", "↖︎", "↘︎", "↗︎", "↔︎", "↕︎", "↪︎", "↩︎", "⇆"], // 矢印
        ["♯", "♭", "♪", "♮", "♫", "♬", "♩", "𝄞", "𝄞"],  // 音符
        ["√", "∛", "∜"],  // 根号
    ]

    private func loadCCBinary(url: URL) -> [(Int32, Float)] {
        do {
            let binaryData = try Data(contentsOf: url, options: [.uncached])
            let ui64array = binaryData.withUnsafeBytes {pointer -> [(Int32, Float)] in
                return Array(
                    UnsafeBufferPointer(
                        start: pointer.baseAddress!.assumingMemoryBound(to: (Int32, Float).self),
                        count: pointer.count / MemoryLayout<(Int32, Float)>.size
                    )
                )
            }
            return ui64array
        } catch {
            debug("Failed to read the file.", error)
            return []
        }
    }

    /// OSのユーザ辞書からrubyに等しい語を返す。
    private func getMatchOSUserDict(_ ruby: some StringProtocol) -> Dicdata {
        return self.osUserDict.dict.filter {$0.ruby == ruby}
    }

    /// OSのユーザ辞書からrubyに先頭一致する語を返す。
    internal func getPrefixMatchOSUserDict(_ ruby: some StringProtocol) -> Dicdata {
        return self.osUserDict.dict.filter {$0.ruby.hasPrefix(ruby)}
    }

    /// rubyに等しい語を返す。
    private func getMatch(_ ruby: some StringProtocol) -> Dicdata {
        return self.memory.match(ruby)
    }
    /// rubyに等しい語の回数を返す。
    internal func getSingleMemory(_ data: DicdataElement) -> Int {
        return self.memory.getSingle(data)
    }
    /// rubyを先頭にもつ語を返す。
    internal func getPrefixMemory(_ prefix: some StringProtocol) -> Dicdata {
        return self.memory.getPrefixDicdata(prefix)
    }
    /// 二つの語の並び回数を返す。
    internal func getMatch(_ previous: DicdataElement, next: DicdataElement) -> Int {
        return self.memory.matchNext(previous, next: next)
    }
    /// 一つの後から連結する次の語を返す。
    internal func getNextMemory(_ data: DicdataElement) -> [(next: DicdataElement, count: Int)] {
        return self.memory.getNextData(data)
    }

    // 学習を反映する
    internal func updateLearningData(_ candidate: Candidate, with previous: DicdataElement?) {
        self.memory.update(candidate.data, lastData: previous)
    }
    /// class idから連接確率を得る関数
    /// - Parameters:
    ///   - former: 左側の語のid
    ///   - latter: 右側の語のid
    /// - Returns:
    ///   連接確率の対数。
    /// - 要求があった場合ごとにファイルを読み込んで
    /// 速度: ⏱0.115224 : 変換_処理_連接コスト計算_CCValue
    internal func getCCValue(_ former: Int, _ latter: Int) -> PValue {
        if !ccParsed[former] {
            let url = Bundle.main.bundleURL.appendingPathComponent("\(former).binary")
            let values = loadCCBinary(url: url)
            ccLines[former] = [Int: PValue].init(uniqueKeysWithValues: values.map {(Int($0.0), PValue($0.1))})
            ccParsed[former] = true
        }
        let defaultValue = ccLines[former][-1, default: -25]
        return ccLines[former][latter, default: defaultValue]
    }

    /// meaning idから意味連接尤度を得る関数
    /// - Parameters:
    ///   - former: 左側の語のid
    ///   - latter: 右側の語のid
    /// - Returns:
    ///   意味連接確率の対数。
    /// - 要求があった場合ごとに確率値をパースして取得する。
    internal func getMMValue(_ former: Int, _ latter: Int) -> PValue {
        if former == 500 || latter == 500 {
            return 0
        }
        return self.mmValue[former * self.midCount + latter]
    }

    private static let possibleLOUDS: Set<Character> = [
        "　", "￣", "‐", "―", "〜", "・", "、", "…", "‥", "。", "‘", "’", "“", "”", "〈", "〉", "《", "》", "「", "」", "『", "』", "【", "】", "〔", "〕", "‖", "*", "′", "〃", "※", "´", "¨", "゛", "゜", "←", "→", "↑", "↓", "─", "■", "□", "▲", "△", "▼", "▽", "◆", "◇", "○", "◎", "●", "★", "☆", "々", "ゝ", "ヽ", "ゞ", "ヾ", "ー", "〇", "ァ", "ア", "ィ", "イ", "ゥ", "ウ", "ヴ", "ェ", "エ", "ォ", "オ", "ヵ", "カ", "ガ", "キ", "ギ", "ク", "グ", "ヶ", "ケ", "ゲ", "コ", "ゴ", "サ", "ザ", "シ", "ジ", "〆", "ス", "ズ", "セ", "ゼ", "ソ", "ゾ", "タ", "ダ", "チ", "ヂ", "ッ", "ツ", "ヅ", "テ", "デ", "ト", "ド", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "バ", "パ", "ヒ", "ビ", "ピ", "フ", "ブ", "プ", "ヘ", "ベ", "ペ", "ホ", "ボ", "ポ", "マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ョ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ヮ", "ワ", "ヰ", "ヱ", "ヲ", "ン", "仝", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "！", "？", "(", ")", "#", "%", "&", "^", "_", "'", "\""
    ]

    // 誤り訂正候補の構築の際、ファイルが存在しているか事前にチェックし、存在していなければ以後の計算を打ち切ることで、計算を減らす。
    internal static func existLOUDS(for character: Character) -> Bool {
        return Self.possibleLOUDS.contains(character)
    }

    /*
     文節の切れ目とは

     * 後置機能語→前置機能語
     * 後置機能語→内容語
     * 内容語→前置機能語
     * 内容語→内容語

     となる。逆に文節の切れ目にならないのは

     * 前置機能語→内容語
     * 内容語→後置機能語

     の二通りとなる。

     */
    /// class idから、文節かどうかを判断する関数。
    /// - Parameters:
    ///   - c_former: 左側の語のid
    ///   - c_latter: 右側の語のid
    /// - Returns:
    ///   そこが文節であるかどうか。
    internal static func isClause(_ former: Int, _ latter: Int) -> Bool {
        // EOSが基本多いので、この順の方がヒット率が上がると思われる。
        let latter_wordtype = Self.wordTypes[latter]
        if latter_wordtype == 3 {
            return false
        }
        let former_wordtype = Self.wordTypes[former]
        if former_wordtype == 3 {
            return false
        }
        if latter_wordtype == 0 {
            return former_wordtype != 0
        }
        if latter_wordtype == 1 {
            return former_wordtype != 0
        }
        return false
    }

    /// wordTypesの初期化時に使うのみ。
    private static let BOS_EOS_wordIDs: Set<Int> = [CIDData.BOS.cid, CIDData.EOS.cid]
    /// wordTypesの初期化時に使うのみ。
    private static let PREPOSITION_wordIDs: Set<Int> = [1315, 6, 557, 558, 559, 560]
    /// wordTypesの初期化時に使うのみ。
    private static let INPOSITION_wordIDs: Set<Int> = Set<Int>((561..<868).map {$0}
                                                                + (1283..<1297).map {$0}
                                                                + (1306..<1310).map {$0}
                                                                + (11..<53).map {$0}
                                                                + (555..<557).map {$0}
                                                                + (1281..<1283).map {$0}
    ).union([1314, 3, 2, 4, 5, 1, 9])

    /*
     private static let POSTPOSITION_wordIDs: Set<Int> = Set<Int>((7...8).map{$0}
     + (54..<555).map{$0}
     + (868..<1281).map{$0}
     + (1297..<1306).map{$0}
     + (1310..<1314).map{$0}
     ).union([10])
     */

    /// - Returns:
    ///   - 3 when BOS/EOS
    ///   - 0 when preposition
    ///   - 1 when core
    ///   - 2 when postposition
    /// - データ1つあたり1Bなので、1.3KBくらいのメモリを利用する。
    static let wordTypes = (0...1319).map(_judgeWordType)

    /// wordTypesの初期化時に使うのみ。
    private static func _judgeWordType(cid: Int) -> UInt8 {
        if Self.BOS_EOS_wordIDs.contains(cid) {
            return 3    // BOS/EOS
        }
        if Self.PREPOSITION_wordIDs.contains(cid) {
            return 0    // 前置
        }
        if Self.INPOSITION_wordIDs.contains(cid) {
            return 1 // 内容
        }
        return 2   // 後置
    }

    internal static func includeMMValueCalculation(_ data: DicdataElement) -> Bool {
        // LREでない場合はfalseを返す。
        if !data.isLRE {
            return false
        }
        // 非自立動詞
        if 895...1280 ~= data.lcid {
            return true
        }
        // 非自立名詞
        if 1297...1305 ~= data.lcid {
            return true
        }
        // 内容語かどうか
        return wordTypes[data.lcid] == 1
    }

    /// - データ1つあたり2Bなので、2.6KBくらいのメモリを利用する。
    static let penaltyRatio = (0...1319).map(_getTypoPenaltyRatio)

    /// penaltyRatioの初期化時に使うのみ。
    internal static func _getTypoPenaltyRatio(_ lcid: Int) -> PValue {
        // 助詞147...368, 助動詞369...554
        if 147...554 ~= lcid {
            return 2.5
        }
        return 1
    }

    // カウントをゼロにすべき語の種類
    internal static func needWValueMemory(_ data: DicdataElement) -> Bool {
        // 助詞、助動詞
        if 147...554 ~= data.lcid {
            return false
        }
        // 接頭辞
        if 557...560 ~= data.lcid {
            return false
        }
        // 接尾名詞を除去
        if 1297...1305 ~= data.lcid {
            return false
        }
        // 記号を除去
        if 6...9 ~= data.lcid {
            return false
        }
        if 0 == data.lcid || 1316 == data.lcid {
            return false
        }

        return true
    }

    internal static let possibleNexts: [String: [String]] = [
        "x": ["ァ", "ィ", "ゥ", "ェ", "ォ", "ッ", "ャ", "ュ", "ョ", "ヮ"],
        "l": ["ァ", "ィ", "ゥ", "ェ", "ォ", "ッ", "ャ", "ュ", "ョ", "ヮ"],
        "xt": ["ッ"],
        "lt": ["ッ"],
        "xts": ["ッ"],
        "lts": ["ッ"],
        "xy": ["ャ", "ュ", "ョ"],
        "ly": ["ャ", "ュ", "ョ"],
        "xw": ["ヮ"],
        "lw": ["ヮ"],
        "v": ["ヴ"],
        "k": ["カ", "キ", "ク", "ケ", "コ"],
        "q": ["クァ", "クィ", "クゥ", "クェ", "クォ"],
        "qy": ["クャ", "クィ", "クュ", "クェ", "クョ"],
        "qw": ["クヮ", "クィ", "クゥ", "クェ", "クォ"],
        "ky": ["キャ", "キィ", "キュ", "キェ", "キョ"],
        "g": ["ガ", "ギ", "グ", "ゲ", "ゴ"],
        "gy": ["ギャ", "ギィ", "ギュ", "ギェ", "ギョ"],
        "s": ["サ", "シ", "ス", "セ", "ソ"],
        "sy": ["シャ", "シィ", "シュ", "シェ", "ショ"],
        "sh": ["シャ", "シィ", "シュ", "シェ", "ショ"],
        "z": ["ザ", "ジ", "ズ", "ゼ", "ゾ"],
        "zy": ["ジャ", "ジィ", "ジュ", "ジェ", "ジョ"],
        "j": ["ジ"],
        "t": ["タ", "チ", "ツ", "テ", "ト"],
        "ty": ["チャ", "チィ", "チュ", "チェ", "チョ"],
        "ts": ["ツ"],
        "th": ["テャ", "ティ", "テュ", "テェ", "テョ"],
        "tw": ["トァ", "トィ", "トゥ", "トェ", "トォ"],
        "cy": ["チャ", "チィ", "チュ", "チェ", "チョ"],
        "ch": ["チ"],
        "d": ["ダ", "ヂ", "ヅ", "デ", "ド"],
        "dy": ["ヂャ", "ヂィ", "ヂュ", "ヂェ", "ヂョ"],
        "dh": ["デャ", "ディ", "デュ", "デェ", "デョ"],
        "dw": ["ドァ", "ドィ", "ドゥ", "ドェ", "ドォ"],
        "n": ["ナ", "ニ", "ヌ", "ネ", "ノ", "ン"],
        "ny": ["ニャ", "ニィ", "ニュ", "ニェ", "ニョ"],
        "h": ["ハ", "ヒ", "フ", "ヘ", "ホ"],
        "hy": ["ヒャ", "ヒィ", "ヒュ", "ヒェ", "ヒョ"],
        "hw": ["ファ", "フィ", "フェ", "フォ"],
        "f": ["フ"],
        "b": ["バ", "ビ", "ブ", "ベ", "ボ"],
        "by": ["ビャ", "ビィ", "ビュ", "ビェ", "ビョ"],
        "p": ["パ", "ピ", "プ", "ペ", "ポ"],
        "py": ["ピャ", "ピィ", "ピュ", "ピェ", "ピョ"],
        "m": ["マ", "ミ", "ム", "メ", "モ"],
        "my": ["ミャ", "ミィ", "ミュ", "ミェ", "ミョ"],
        "y": ["ヤ", "ユ", "イェ", "ヨ"],
        "r": ["ラ", "リ", "ル", "レ", "ロ"],
        "ry": ["リャ", "リィ", "リュ", "リェ", "リョ"],
        "w": ["ワ", "ウィ", "ウェ", "ヲ"],
        "wy": ["ヰ", "ヱ"]
    ]
}
