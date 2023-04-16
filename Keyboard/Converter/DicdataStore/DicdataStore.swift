//
//  DicdataStore.swift
//  Keyboard
//
//  Created by ensan on 2020/09/17.
//  Copyright © 2020 ensan. All rights reserved.
//

import Algorithms
import Foundation

final class DicdataStore {
    init() {
        debug("DicdataStoreが初期化されました")
        self.setup()
    }

    /// in unit tests, the URL is replaced for their bundleURL
    static var bundleURL = Bundle.main.bundleURL

    private var ccParsed: [Bool] = .init(repeating: false, count: 1319)
    private var ccLines: [[Int: PValue]] = []
    private var mmValue: [PValue] = []
    private let threshold: PValue = -17

    private var loudses: [String: LOUDS] = [:]
    private var importedLoudses: Set<String> = []
    private var charsID: [Character: UInt8] = [:]
    private var learningManager = LearningManager()
    private var zeroHintPredictionDicdata: [DicdataElement]?

    private var osUserDict: [DicdataElement] = []

    internal let maxlength: Int = 20
    private let midCount = 502
    private let cidCount = 1319

    private var requestOptions: ConvertRequestOptions = .init()

    private let numberFormatter = NumberFormatter()
    /// 初期化時のセットアップ用の関数。プロパティリストを読み込み、連接確率リストを読み込んで行分割し保存しておく。
    private func setup() {
        numberFormatter.numberStyle = .spellOut
        numberFormatter.locale = .init(identifier: "ja-JP")
        self.ccLines = [[Int: PValue]].init(repeating: [:], count: CIDData.totalCount)

        do {
            let string = try String(contentsOf: Self.bundleURL.appendingPathComponent("Dictionary/louds/charID.chid", isDirectory: false), encoding: String.Encoding.utf8)
            charsID = [Character: UInt8].init(uniqueKeysWithValues: string.enumerated().map {($0.element, UInt8($0.offset))})
        } catch {
            debug("ファイルが存在しません: \(error)")
        }
        do {
            let url = Self.bundleURL.appendingPathComponent("Dictionary/mm.binary", isDirectory: false)
            do {
                let binaryData = try Data(contentsOf: url, options: [.uncached])
                self.mmValue = binaryData.toArray(of: Float.self).map(PValue.init)
            } catch {
                debug("Failed to read the file.")
                self.mmValue = [PValue].init(repeating: .zero, count: self.midCount * self.midCount)
            }
        }
        _ = self.loadLOUDS(identifier: "user")
        _ = self.loadLOUDS(identifier: "memory")
    }

    enum Notification {
        case importOSUserDict([DicdataElement])
        case setRequestOptions(ConvertRequestOptions)
        case forgetMemory(Candidate)
        case closeKeyboard
    }

    func sendToDicdataStore(_ data: Notification) {
        switch data {
        case .closeKeyboard:
            self.closeKeyboard()
        case let .importOSUserDict(osUserDict):
            self.osUserDict = osUserDict
        case let .forgetMemory(candidate):
            self.learningManager.forgetMemory(data: candidate.data)
            // loudsの処理があるので、リセットを実施する
            self.reloadMemory()
        case let .setRequestOptions(value):
            self.requestOptions = value
            let shouldReset = self.learningManager.setRequestOptions(options: value)
            if shouldReset {
                self.reloadMemory()
            }
        }
    }

    private func reloadMemory() {
        self.loudses.removeValue(forKey: "memory")
        self.importedLoudses.remove("memory")
    }

    private func reloadUser() {
        self.loudses.removeValue(forKey: "user")
        self.importedLoudses.remove("user")
    }

    private func closeKeyboard() {
        self.learningManager.save()
        // saveしたあとにmemoryのキャッシュされたLOUDSを使い続けないよう、キャッシュから削除する。
        self.reloadMemory()
        self.reloadUser()
    }

    /// ペナルティ関数。文字数で決める。
    private static func getPenalty(data: DicdataElement) -> PValue {
        -2.0 / PValue(data.word.count)
    }

    /// 計算時に利用。無視すべきデータかどうか。
    private func shouldBeRemoved(value: PValue, wordCount: Int) -> Bool {
        let d = value - self.threshold
        if d < 0 {
            return true
        }
        // dは正
        return -2.0 / PValue(wordCount) < -d
    }

    /// 計算時に利用。無視すべきデータかどうか。
    internal func shouldBeRemoved(data: DicdataElement) -> Bool {
        let d = data.value() - self.threshold
        if d < 0 {
            return true
        }
        return Self.getPenalty(data: data) < -d
    }

    private func loadLOUDS(identifier: String) -> LOUDS? {
        if importedLoudses.contains(identifier) {
            return self.loudses[identifier]
        }

        importedLoudses.insert(identifier)
        if let louds = LOUDS.load(identifier) {
            self.loudses[identifier] = louds
            return louds
        } else {
            debug("loudsの読み込みに失敗、identifierは\(identifier)")
            return nil
        }
    }

    private func perfectMatchLOUDS(identifier: String, charIDs: [UInt8]) -> [Int] {
        guard let louds = self.loadLOUDS(identifier: identifier) else {
            return []
        }
        return [louds.searchNodeIndex(chars: charIDs)].compactMap {$0}
    }

    private func throughMatchLOUDS(identifier: String, charIDs: [UInt8], depth: Range<Int>) -> [Int] {
        guard let louds = self.loadLOUDS(identifier: identifier) else {
            return []
        }
        let result = louds.byfixNodeIndices(chars: charIDs)
        // result[1]から始まるので、例えば3..<5 (3文字と4文字)の場合は1文字ずつずらして4..<6の範囲をもらう
        return Array(result[min(depth.lowerBound + 1, result.endIndex) ..< min(depth.upperBound + 1, result.endIndex)])
    }

    private func prefixMatchLOUDS(identifier: String, charIDs: [UInt8], depth: Int = .max) -> [Int] {
        guard let louds = self.loadLOUDS(identifier: identifier) else {
            return []
        }
        return louds.prefixNodeIndices(chars: charIDs, maxDepth: depth)
    }

    private func getDicdataFromLoudstxt3(identifier: String, indices: Set<Int>) -> [DicdataElement] {
        debug("getDicdataFromLoudstxt3", identifier, indices)
        // split = 2048
        let dict = [Int: [Int]].init(grouping: indices, by: {$0 >> 11})
        var data: [DicdataElement] = []
        for (key, value) in dict {
            data.append(contentsOf: LOUDS.getDataForLoudstxt3(identifier + "\(key)", indices: value.map {$0 & 2047}))
        }
        return data
    }

    /// kana2latticeから参照する。
    /// - Parameters:
    ///   - inputData: 入力データ
    ///   - from: 起点
    ///   - toIndexRange: `from ..< (toIndexRange)`の範囲で辞書ルックアップを行う。
    internal func getLOUDSDataInRange(inputData: ComposingText, from fromIndex: Int, toIndexRange: Range<Int>? = nil) -> [LatticeNode] {
        let toIndexLeft = toIndexRange?.startIndex ?? fromIndex
        let toIndexRight = min(toIndexRange?.endIndex ?? inputData.input.count, fromIndex + self.maxlength)
        debug("getLOUDSDataInRange", fromIndex, toIndexRange?.description ?? "nil", toIndexLeft, toIndexRight)
        if fromIndex > toIndexLeft || toIndexLeft >= toIndexRight {
            debug("getLOUDSDataInRange: index is wrong")
            return []
        }

        let segments = (fromIndex ..< toIndexRight).reduce(into: []) { (segments: inout [String], rightIndex: Int) in
            segments.append((segments.last ?? "") + String(inputData.input[rightIndex].character.toKatakana()))
        }
        // MARK: 誤り訂正の対象を列挙する。非常に重い処理。
        var stringToInfo = inputData.getRangesWithTypos(fromIndex, rightIndexRange: toIndexLeft ..< toIndexRight)

        // MARK: 検索対象を列挙していく。
        let stringSet = stringToInfo.keys.map {($0, $0.map {self.charsID[$0, default: .max]})}
        let (minCharIDsCount, maxCharIDsCount) = stringSet.lazy.map {$0.1.count}.minAndMax() ?? (0, -1)
        // 先頭の文字: そこで検索したい文字列の集合
        let group = [Character: [(String, [UInt8])]].init(grouping: stringSet, by: {$0.0.first!})

        let depth = minCharIDsCount - 1 ..< maxCharIDsCount
        var indices: [(String, Set<Int>)] = group.map {dic in
            let key = String(dic.key)
            let set = dic.value.flatMapSet {(_, charIDs) in self.throughMatchLOUDS(identifier: key, charIDs: charIDs, depth: depth)}
            return (key, set)
        }
        indices.append(("user", stringSet.flatMapSet {self.throughMatchLOUDS(identifier: "user", charIDs: $0.1, depth: depth)}))
        if learningManager.enabled {
            indices.append(("memory", stringSet.flatMapSet {self.throughMatchLOUDS(identifier: "memory", charIDs: $0.1, depth: depth)}))
        }
        // MARK: 検索によって得たindicesから辞書データを実際に取り出していく
        var dicdata: [DicdataElement] = []
        for (identifier, value) in indices {
            let result: [DicdataElement] = self.getDicdataFromLoudstxt3(identifier: identifier, indices: value).compactMap { (data) -> DicdataElement? in
                let penalty = stringToInfo[data.ruby, default: (0, .zero)].penalty
                if penalty.isZero {
                    return data
                }
                let ratio = Self.penaltyRatio[data.lcid]
                let pUnit: PValue = Self.getPenalty(data: data) / 2   // 負の値
                let adjust = pUnit * penalty * ratio
                if self.shouldBeRemoved(value: data.value() + adjust, wordCount: data.ruby.count) {
                    return nil
                }
                return data.adjustedData(adjust)
            }
            dicdata.append(contentsOf: result)
        }
        dicdata.append(contentsOf: stringSet.flatMap {self.learningManager.temporaryThroughMatch(charIDs: $0.1, depth: depth)})

        for i in toIndexLeft ..< toIndexRight {
            do {
                let result = self.getWiseDicdata(convertTarget: segments[i - fromIndex], allowRomanLetter: i + 1 == toIndexRight, inputData: inputData, inputRange: fromIndex ..< i)
                for item in result {
                    stringToInfo[item.ruby] = (i, 0)
                }
                dicdata.append(contentsOf: result)
            }
            do {
                let result = self.getMatchOSUserDict(segments[i - fromIndex])
                for item in result {
                    stringToInfo[item.ruby] = (i, 0)
                }
                dicdata.append(contentsOf: result)
            }
        }
        if fromIndex == .zero {
            let result: [LatticeNode] = dicdata.compactMap {
                guard let endIndex = stringToInfo[$0.ruby]?.endIndex else {
                    return nil
                }
                let node = LatticeNode(data: $0, inputRange: fromIndex ..< endIndex + 1)
                node.prevs.append(RegisteredNode.BOSNode())
                return node
            }
            return result
        } else {
            let result: [LatticeNode] = dicdata.compactMap {
                guard let endIndex = stringToInfo[$0.ruby]?.endIndex else {
                    return nil
                }
                return LatticeNode(data: $0, inputRange: fromIndex ..< endIndex + 1)
            }
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
        let segment = inputData.input[fromIndex...toIndex].reduce(into: "") {$0.append($1.character)}.toKatakana()

        let string2penalty = inputData.getRangeWithTypos(fromIndex, toIndex)

        // MARK: 検索によって得たindicesから辞書データを実際に取り出していく
        // 先頭の文字: そこで検索したい文字列の集合
        let strings = string2penalty.keys.map {
            (key: $0, charIDs: $0.map {self.charsID[$0, default: .max]})
        }
        let group = [Character: [(key: String, charIDs: [UInt8])]].init(grouping: strings, by: {$0.key.first!})

        var indices: [(String, Set<Int>)] = group.map {dic in
            let head = String(dic.key)
            let set = dic.value.flatMapSet { (_, charIDs) in
                self.perfectMatchLOUDS(identifier: head, charIDs: charIDs)
            }
            return (head, set)
        }
        do {
            let set = strings.flatMapSet { (_, charIDs) in
                self.perfectMatchLOUDS(identifier: "user", charIDs: charIDs)
            }
            indices.append(("user", set))
        }
        if learningManager.enabled {
            let set = strings.flatMapSet { (_, charIDs) in
                self.perfectMatchLOUDS(identifier: "memory", charIDs: charIDs)
            }
            indices.append(("memory", set))
        }
        var dicdata: [DicdataElement] = []
        for (identifier, value) in indices {
            let result: [DicdataElement] = self.getDicdataFromLoudstxt3(identifier: identifier, indices: value).compactMap { (data) -> DicdataElement? in
                let penalty = string2penalty[data.ruby, default: .zero]
                if penalty.isZero {
                    return data
                }
                let ratio = Self.penaltyRatio[data.lcid]
                let pUnit: PValue = Self.getPenalty(data: data) / 2   // 負の値
                let adjust = pUnit * penalty * ratio
                if self.shouldBeRemoved(value: data.value() + adjust, wordCount: data.ruby.count) {
                    return nil
                }
                return data.adjustedData(adjust)
            }
            dicdata.append(contentsOf: result)
        }
        dicdata.append(contentsOf: strings.flatMap {self.learningManager.temporaryPerfectMatch(charIDs: $0.charIDs)})
        dicdata.append(contentsOf: self.getWiseDicdata(convertTarget: segment, allowRomanLetter: toIndex == inputData.input.count - 1, inputData: inputData, inputRange: fromIndex ..< toIndex + 1))
        dicdata.append(contentsOf: self.getMatchOSUserDict(segment))

        debug("getLOUDSData", "\(fromIndex) ..< \(toIndex + 1)", dicdata.contains {$0.word == "使っ"})

        if fromIndex == .zero {
            let result: [LatticeNode] = dicdata.map {
                let node = LatticeNode(data: $0, inputRange: fromIndex ..< toIndex + 1)
                node.prevs.append(RegisteredNode.BOSNode())
                return node
            }
            return result
        } else {
            let result: [LatticeNode] = dicdata.map {LatticeNode(data: $0, inputRange: fromIndex ..< toIndex + 1)}
            return result
        }
    }

    internal func getZeroHintPredictionDicdata() -> [DicdataElement] {
        if let dicdata = self.zeroHintPredictionDicdata {
            return dicdata
        }
        do {
            let csvString = try String(contentsOf: Self.bundleURL.appendingPathComponent("Dictionary/p/p_null.csv", isDirectory: false), encoding: String.Encoding.utf8)
            let csvLines = csvString.split(separator: "\n")
            let csvData = csvLines.map {$0.split(separator: ",", omittingEmptySubsequences: false)}
            let dicdata: [DicdataElement] = csvData.map {self.parseLoudstxt2FormattedEntry(from: $0)}
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
    internal func getPredictionLOUDSDicdata(key: some StringProtocol) -> [DicdataElement] {
        let count = key.count
        if count == .zero {
            return []
        }
        // 1文字に対する予測変換は検索が難しいので、特別に用意した辞書を用いて実施する
        if count == 1 {
            do {
                let csvString = try String(contentsOf: Self.bundleURL.appendingPathComponent("Dictionary/p/p_\(key).csv", isDirectory: false), encoding: String.Encoding.utf8)
                let csvLines = csvString.split(separator: "\n")
                let csvData = csvLines.map {$0.split(separator: ",", omittingEmptySubsequences: false)}
                let dicdata: [DicdataElement] = csvData.map {self.parseLoudstxt2FormattedEntry(from: $0)}
                return dicdata
            } catch {
                debug("ファイルが存在しません: \(error)")
                return []
            }
        } else if count == 2 {
            var result: [DicdataElement] = []
            let first = String(key.first!)
            let charIDs = key.map {self.charsID[$0, default: .max]}
            // 最大700件に絞ることによって低速化を回避する。
            let prefixIndices = self.prefixMatchLOUDS(identifier: first, charIDs: charIDs, depth: 5).prefix(700)
            result.append(contentsOf: self.getDicdataFromLoudstxt3(identifier: first, indices: Set(prefixIndices)))
            let userDictIndices = self.prefixMatchLOUDS(identifier: "user", charIDs: charIDs, depth: 5).prefix(700)
            result.append(contentsOf: self.getDicdataFromLoudstxt3(identifier: "user", indices: Set(userDictIndices)))
            if learningManager.enabled {
                let memoryDictIndices = self.prefixMatchLOUDS(identifier: "memory", charIDs: charIDs, depth: 5).prefix(700)
                result.append(contentsOf: self.getDicdataFromLoudstxt3(identifier: "memory", indices: Set(memoryDictIndices)))
                result.append(contentsOf: self.learningManager.temporaryPrefixMatch(charIDs: charIDs))
            }
            return result
        } else {
            var result: [DicdataElement] = []
            let first = String(key.first!)
            let charIDs = key.map {self.charsID[$0, default: .max]}
            // 最大700件に絞ることによって低速化を回避する。
            let prefixIndices = self.prefixMatchLOUDS(identifier: first, charIDs: charIDs).prefix(700)
            result.append(contentsOf: self.getDicdataFromLoudstxt3(identifier: first, indices: Set(prefixIndices)))
            let userDictIndices = self.prefixMatchLOUDS(identifier: "user", charIDs: charIDs).prefix(700)
            result.append(contentsOf: self.getDicdataFromLoudstxt3(identifier: "user", indices: Set(userDictIndices)))
            if learningManager.enabled {
                let memoryDictIndices = self.prefixMatchLOUDS(identifier: "memory", charIDs: charIDs).prefix(700)
                result.append(contentsOf: self.getDicdataFromLoudstxt3(identifier: "memory", indices: Set(memoryDictIndices)))
                result.append(contentsOf: self.learningManager.temporaryPrefixMatch(charIDs: charIDs))
            }
            return result
        }
    }

    private func parseLoudstxt2FormattedEntry(from dataString: [some StringProtocol]) -> DicdataElement {
        let ruby = String(dataString[0])
        let word = dataString[1].isEmpty ? ruby:String(dataString[1])
        let lcid = Int(dataString[2]) ?? .zero
        let rcid = Int(dataString[3]) ?? lcid
        let mid = Int(dataString[4]) ?? .zero
        let value: PValue = PValue(dataString[5]) ?? -30.0
        return DicdataElement(word: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: value)
    }

    /// 補足的な辞書情報を得る。
    ///  - parameters:
    ///     - convertTarget: カタカナ変換済みの文字列
    /// - note
    ///     - 入力全体をカタカナとかひらがなに変換するやつは、Converter側でやっているので注意。
    private func getWiseDicdata(convertTarget: String, allowRomanLetter: Bool, inputData: ComposingText, inputRange: Range<Int>) -> [DicdataElement] {
        var result: [DicdataElement] = []
        result.append(contentsOf: self.getJapaneseNumberDicdata(head: convertTarget))
        if inputData.input[..<inputRange.startIndex].last?.character.isNumber != true && inputData.input[inputRange.endIndex...].first?.character.isNumber != true, let number = Float(convertTarget) {
            result.append(DicdataElement(ruby: convertTarget, cid: CIDData.数.cid, mid: MIDData.小さい数字.mid, value: -14))
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                let int = Int(number)
                if int < Int(1E18) && -Int(1E18) < int, let kansuji = self.numberFormatter.string(from: NSNumber(value: int)) {
                    result.append(DicdataElement(word: kansuji, ruby: convertTarget, cid: CIDData.数.cid, mid: MIDData.小さい数字.mid, value: -16))
                }
            }
        }

        // headを英単語として候補に追加する
        if requestOptions.keyboardLanguage == .en_US && convertTarget.onlyRomanAlphabet {
            result.append(DicdataElement(ruby: convertTarget, cid: CIDData.固有名詞.cid, mid: MIDData.英単語.mid, value: -14))
        }
        // 入力を全てひらがな、カタカナに変換したものを候補に追加する
        // ローマ字変換の場合、先頭を単体でひらがな・カタカナ化した候補も追加
        if requestOptions.keyboardLanguage != .en_US && inputData.input[inputRange].allSatisfy({$0.inputStyle == .roman2kana}) {
            if let katakana = Roman2Kana.katakanaChanges[convertTarget], let hiragana = Roman2Kana.hiraganaChanges[convertTarget] {
                result.append(DicdataElement(word: hiragana, ruby: katakana, cid: CIDData.固有名詞.cid, mid: MIDData.一般.mid, value: -13))
                result.append(DicdataElement(ruby: katakana, cid: CIDData.固有名詞.cid, mid: MIDData.一般.mid, value: -14))
            }
        }

        if convertTarget.count == 1, allowRomanLetter || !convertTarget.onlyRomanAlphabet {
            let hira = convertTarget.toKatakana()
            if convertTarget == hira {
                result.append(DicdataElement(ruby: convertTarget, cid: CIDData.固有名詞.cid, mid: MIDData.一般.mid, value: -14))
            } else {
                result.append(DicdataElement(word: hira, ruby: convertTarget, cid: CIDData.固有名詞.cid, mid: MIDData.一般.mid, value: -13))
                result.append(DicdataElement(ruby: convertTarget, cid: CIDData.固有名詞.cid, mid: MIDData.一般.mid, value: -14))
            }
        }

        // 記号変換
        if convertTarget.count == 1, let first = convertTarget.first {
            var value: PValue = -14
            let hs = Self.fullwidthToHalfwidth[first, default: first]

            if hs != first {
                result.append(DicdataElement(word: convertTarget, ruby: convertTarget, cid: CIDData.記号.cid, mid: MIDData.一般.mid, value: value))
                value -= 5.0
                result.append(DicdataElement(word: String(hs), ruby: convertTarget, cid: CIDData.記号.cid, mid: MIDData.一般.mid, value: value))
                value -= 5.0
            }
            if let fs = Self.halfwidthToFullwidth[first], fs != first {
                result.append(DicdataElement(word: convertTarget, ruby: convertTarget, cid: CIDData.記号.cid, mid: MIDData.一般.mid, value: value))
                value -= 5.0
                result.append(DicdataElement(word: String(fs), ruby: convertTarget, cid: CIDData.記号.cid, mid: MIDData.一般.mid, value: value))
                value -= 5.0
            }
            for group in Self.weakRelatingSymbolGroups where group.contains(hs) {
                for symbol in group where symbol != hs {
                    result.append(DicdataElement(word: String(symbol), ruby: convertTarget, cid: CIDData.記号.cid, mid: MIDData.一般.mid, value: value))
                    value -= 5.0
                    if let fs = Self.halfwidthToFullwidth[symbol] {
                        result.append(DicdataElement(word: String(fs), ruby: convertTarget, cid: CIDData.記号.cid, mid: MIDData.一般.mid, value: value))
                        value -= 5.0
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
        ["高", "髙"], // ハシゴダカ
        ["斎", "斉", "齋", "齊"],
        ["澤", "沢"],
        ["気", "氣"],
        ["澁", "渋"],
        ["対", "對"],
        ["辻", "辻󠄀"],
        ["禰󠄀", "禰"],
        ["煉󠄁", "煉"],
        ["崎", "﨑"], // タツザキ
        ["栄", "榮"],
        ["吉", "𠮷"], // ツチヨシ
        ["橋", "𣘺", "槗", "𫞎"],
        ["浜", "濱", "濵"],
        ["鴎", "鷗"],
        ["学", "學"],
        ["角", "⻆"],
        ["亀", "龜"],
        ["桜", "櫻"],
        ["真", "眞"],

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
        ["÷", "➗" ],
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
        ["√", "∛", "∜"]  // 根号
    ]

    private func loadCCBinary(url: URL) -> [(Int32, Float)] {
        do {
            let binaryData = try Data(contentsOf: url, options: [.uncached])
            return binaryData.toArray(of: (Int32, Float).self)
        } catch {
            debug("Failed to read the file.", error)
            return []
        }
    }

    /// OSのユーザ辞書からrubyに等しい語を返す。
    private func getMatchOSUserDict(_ ruby: some StringProtocol) -> [DicdataElement] {
        self.osUserDict.filter {$0.ruby == ruby}
    }

    /// OSのユーザ辞書からrubyに先頭一致する語を返す。
    internal func getPrefixMatchOSUserDict(_ ruby: some StringProtocol) -> [DicdataElement] {
        self.osUserDict.filter {$0.ruby.hasPrefix(ruby)}
    }

    // 学習を反映する
    // TODO: previousの扱いを改善したい
    internal func updateLearningData(_ candidate: Candidate, with previous: DicdataElement?) {
        if let previous {
            self.learningManager.update(data: [previous] + candidate.data)
        } else {
            self.learningManager.update(data: candidate.data)
        }
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
            let url = Self.bundleURL.appendingPathComponent("Dictionary/cb/\(former).binary", isDirectory: false)
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
        Self.possibleLOUDS.contains(character)
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
    ///   そこが文節の境界であるかどうか。
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
    private static let INPOSITION_wordIDs: Set<Int> = Set<Int>(Array(561..<868)
                                                                + Array(1283..<1297)
                                                                + Array(1306..<1310)
                                                                + Array(11..<53)
                                                                + Array(555..<557)
                                                                + Array(1281..<1283)
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
        // 非自立動詞
        if 895...1280 ~= data.lcid || 895...1280 ~= data.rcid {
            return true
        }
        // 非自立名詞
        if 1297...1305 ~= data.lcid || 1297...1305 ~= data.rcid {
            return true
        }
        // 内容語かどうか
        return wordTypes[data.lcid] == 1 || wordTypes[data.rcid] == 1
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

    // 学習を有効にする語彙を決める。
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
