//
//  LearningMemory.swift
//  Keyboard
//
//  Created by β α on 2021/02/01.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

private struct MetadataElement: CustomDebugStringConvertible {
    init(day: UInt16, count: UInt8) {
        self.lastUsedDay = day
        self.lastUpdatedDay = day
        self.count = count
    }

    var lastUsedDay: UInt16
    var lastUpdatedDay: UInt16
    var count: UInt8

    var debugDescription: String {
        "(lastUsedDay: \(lastUsedDay), lastUpdatedDay: \(lastUpdatedDay), count: \(count))"
    }
}

/// 長期記憶用の構造体
struct LongTermLearningMemory {
    static let directoryURL = (try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)) ?? FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
    private static var loudsFileURL: URL {
        directoryURL.appendingPathComponent("memory.louds", isDirectory: false)
    }
    private static var metadataFileURL: URL {
        directoryURL.appendingPathComponent("memory.memorymetadata", isDirectory: false)
    }
    private static var loudsCharsFileURL: URL {
        directoryURL.appendingPathComponent("memory.loudschars2", isDirectory: false)
    }
    private static func loudsTxt3FileURL(_ value: String) -> URL {
        directoryURL.appendingPathComponent("memory\(value).loudstxt3", isDirectory: false)
    }

    static var txtFileSplit: Int { 2048 }
    static let maxMemoryCount = 65536

    private static func BoolToUInt64(_ bools: [Bool]) -> [UInt64] {
        let unit = 64
        let value = bools.count.quotientAndRemainder(dividingBy: unit)
        let _bools = bools + [Bool].init(repeating: true, count: (unit - value.remainder) % unit)
        var result = [UInt64]()
        for i in 0...value.quotient {
            var value: UInt64 = 0
            for j in 0..<unit {
                value += (_bools[i * unit + j] ? 1:0) << (unit - j - 1)
            }
            result.append(value)
        }
        return result
    }

    fileprivate static func valueForMetadata(metadata: MetadataElement) -> PValue {
        return PValue(-1.0 - 3 * (1 - Double(metadata.count) / 255) * (1 - Double(metadata.count) / 255))
    }

    fileprivate struct MetadataBlock {
        var metadata: [MetadataElement]

        func makeBinary() -> Data {
            var data = Data()
            // エントリのカウントを1byteでエンコード
            var count = UInt8(self.metadata.count)
            data.append(contentsOf: Data(bytes: &count, count: MemoryLayout<UInt8>.size))
            var metadata = self.metadata.map {MetadataElement(day: $0.lastUsedDay, count: $0.count)}
            data.append(contentsOf: Data(bytes: &metadata, count: MemoryLayout<MetadataElement>.size * metadata.count))
            return data
        }
    }

    fileprivate struct DataBlock {
        var count: Int {
            data.count
        }
        var ruby: String
        var data: [(word: String, lcid: Int, rcid: Int, mid: Int, score: Float16)]

        init(dicdata: [DicdataElement]) {
            self.ruby = ""
            self.data = []

            for element in dicdata {
                if self.ruby.isEmpty {
                    self.ruby = element.ruby
                }
                self.data.append((element.word, element.lcid, element.rcid, element.mid, element.baseValue))
            }
        }

        func makeLoudstxt3Entry() -> Data {
            var data = Data()
            // エントリのカウントを2byteでエンコード
            var count = UInt16(self.count)
            data.append(contentsOf: Data(bytes: &count, count: MemoryLayout<UInt16>.size))

            // 数値データ部をエンコード
            // 10byteが1つのエントリに対応するので、10*count byte
            for (_, lcid, rcid, mid, score) in self.data {
                assert(0 <= lcid && lcid <= UInt16.max)
                assert(0 <= rcid && rcid <= UInt16.max)
                assert(0 <= mid && mid <= UInt16.max)
                var lcid = UInt16(lcid)
                var rcid = UInt16(rcid)
                var mid = UInt16(mid)
                data.append(contentsOf: Data(bytes: &lcid, count: MemoryLayout<UInt16>.size))
                data.append(contentsOf: Data(bytes: &rcid, count: MemoryLayout<UInt16>.size))
                data.append(contentsOf: Data(bytes: &mid, count: MemoryLayout<UInt16>.size))
                var score = Float32(score)
                data.append(contentsOf: Data(bytes: &score, count: MemoryLayout<Float32>.size))
            }
            // wordをエンコード
            // 最先頭の要素はrubyになる
            let text = ([self.ruby] + self.data.map { $0.word == self.ruby ? "" : $0.word }).joined(separator: "\t")
            data.append(contentsOf: text.data(using: .utf8, allowLossyConversion: false)!)
            return data
        }
    }

    static func reset() throws {
        // 全削除する
        if let ltMetadata = try? Data(contentsOf: metadataFileURL) {
            let entryCount = ltMetadata[0 ..< 4].toArray(of: UInt32.self)[0]

            try FileManager.default.removeItem(at: metadataFileURL)
            try FileManager.default.removeItem(at: loudsFileURL)
            try FileManager.default.removeItem(at: loudsCharsFileURL)
            for loudstxtIndex in 0 ..< Int(entryCount) / txtFileSplit + 1 {
                try FileManager.default.removeItem(at: loudsTxt3FileURL(loudstxtIndex.description))
            }
        }
    }

    static func merge(tempTrie: TemporalLearningMemoryTrie) {
        let startTime = Date()
        let today = LearningManager.today
        var newTrie = tempTrie
        // 構造:
        // dataCount(UInt32), count, data*count, count, data*count, ...
        let ltMetadata = (try? Data(contentsOf: metadataFileURL)) ?? Data([.zero, .zero, .zero, .zero])
        // 最初の4byteはentry countに対応する
        var metadataOffset = 0
        let entryCount = ltMetadata[metadataOffset ..< metadataOffset + 4].toArray(of: UInt32.self)[0]
        metadataOffset += 4

        debug("LongTermLearningMemory merge entryCount", entryCount, ltMetadata.count)

        // それぞれのloudstxt3ファイルに対して処理を行う
        for loudstxtIndex in 0 ..< Int(entryCount) / txtFileSplit + 1 {
            // loudstxt3の数
            guard let loudstxtData = try? Data(contentsOf: loudsTxt3FileURL("\(loudstxtIndex)")) else {
                continue
            }
            let count = Int(loudstxtData[0 ..< 2].toArray(of: UInt16.self)[0])
            let indices = loudstxtData[2 ..< 2 + 4 * count].toArray(of: UInt32.self)
            for i in 0 ..< count {
                // メタデータの読み取り
                // 1byteで項目数
                let itemCount = Int(ltMetadata[metadataOffset ..< metadataOffset + 1].toArray(of: UInt8.self)[0])
                metadataOffset += 1
                let metadata = ltMetadata[metadataOffset ..< metadataOffset + itemCount * 5].toArray(of: MetadataElement.self)
                metadataOffset += itemCount * 5

                // バイナリ内部でのindex
                let startIndex = Int(indices[i])
                let endIndex = i == (indices.endIndex - 1) ? loudstxtData.endIndex : Int(indices[i + 1])
                let elements = LOUDS.parseBinary(binary: loudstxtData[startIndex ..< endIndex])
                // 該当部分を取り出してメタデータに従ってフィルター、trieに追加
                guard let ruby = elements.first?.ruby else {
                    continue
                }
                var newDicdata: [DicdataElement] = []
                var newMetadata: [MetadataElement] = []
                for (dicdataElement, metadataElement) in zip(elements, metadata) {
                    if ruby != dicdataElement.ruby {
                        continue
                    }
                    var dicdataElement = dicdataElement
                    var metadataElement = metadataElement
                    guard today >= metadataElement.lastUpdatedDay else {
                        // 異常対応
                        // 変なデータが入っているとオーバーフローが起こるのでフェイルセーフにする
                        continue
                    }
                    // 16日ごとにカウントを半減させる
                    while today - metadataElement.lastUpdatedDay > 16 {
                        metadataElement.count >>= 1
                        metadataElement.lastUpdatedDay += 16
                    }
                    // カウントがゼロになるか128日以上使っていない単語は除外
                    if metadataElement.count == 0 || today - metadataElement.lastUsedDay >= 128 {
                        continue
                    }
                    dicdataElement.baseValue = valueForMetadata(metadata: metadataElement)
                    newDicdata.append(dicdataElement)
                    newMetadata.append(metadataElement)
                }
                let chars = LearningManager.keyToChars(ruby)
                newTrie.append(dicdata: newDicdata, chars: chars, metadata: newMetadata)
            }
            // メモリ数上限を超過した場合、長いものから捨てる
            if newTrie.dicdata.count > Self.maxMemoryCount {
                break
            }
        }
        // newTrieのデータからLOUDSを作り書き出す
        self.process(trie: newTrie)
        debug("LongTermLearningMemory merge ⏰", Date().timeIntervalSince(startTime), newTrie.dicdata.count)
    }

    fileprivate static func make_loudstxt3(lines: [DataBlock]) -> Data {
        let lc = lines.count    // データ数
        let count = Data(bytes: [UInt16(lc)], count: 2) // データ数をUInt16でマップ

        let data = lines.map { $0.makeLoudstxt3Entry() }
        let body = data.reduce(Data(), +)   // データ

        let header_endIndex: UInt32 = 2 + UInt32(lc) * UInt32(MemoryLayout<UInt32>.size)
        let headerArray = data.dropLast().reduce(into: [header_endIndex]) {array, value in // ヘッダの作成
            array.append(array.last! + UInt32(value.count))
        }

        let header = Data(bytes: headerArray, count: MemoryLayout<UInt32>.size * headerArray.count)
        let binary = count + header + body

        return binary
    }

    static func process(trie: TemporalLearningMemoryTrie) {
        var nodes2Characters: [UInt8] = [0x0, 0x0]
        var dicdata: [DataBlock] = [.init(dicdata: []), .init(dicdata: [])]
        var metadata: [MetadataBlock] = [.init(metadata: []), .init(metadata: [])]
        var bits: [Bool] = [true, false]
        var currentNodes: [(UInt8, Int)] = trie.nodes[0].children.sorted(by: {$0.key < $1.key})
        bits += [Bool](repeating: true, count: currentNodes.count) + [false]
        while !currentNodes.isEmpty {
            currentNodes.forEach {char, nodeIndex in
                nodes2Characters.append(char)
                let dicdataBlock = DataBlock(dicdata: trie.nodes[nodeIndex].dataIndices.map {trie.dicdata[$0]})
                dicdata.append(dicdataBlock)
                metadata.append(MetadataBlock(metadata: trie.nodes[nodeIndex].dataIndices.map {trie.metadata[$0]}))

                bits += [Bool](repeating: true, count: trie.nodes[nodeIndex].children.count) + [false]
            }
            currentNodes = currentNodes.flatMap {(_, nodeIndex) in trie.nodes[nodeIndex].children.sorted(by: {$0.key < $1.key})}
        }

        let bytes = Self.BoolToUInt64(bits)

        do {
            let binary = Data(bytes: bytes, count: bytes.count * 8)
            try binary.write(to: loudsFileURL)
        } catch {
            debug("LongTermLearningMemory process", error)
        }

        do {
            let binary = Data(bytes: nodes2Characters, count: nodes2Characters.count)
            try binary.write(to: loudsCharsFileURL)
        } catch {
            debug("LongTermLearningMemory process", error)
        }

        do {
            var binary = Data()
            binary += Data(bytes: [UInt32(metadata.count)], count: 4) // エントリ数をUInt32でマップ
            let result = metadata.reduce(into: binary) {
                $0.append($1.makeBinary())
            }
            try result.write(to: metadataFileURL)
        } catch {
            debug("LongTermLearningMemory process", error)
        }

        do {
            let count = (dicdata.count) / txtFileSplit
            let indiceses: [Range<Int>] = (0...count).map {
                let start = $0 * txtFileSplit
                let _end = ($0 + 1) * txtFileSplit
                let end = dicdata.count < _end ? dicdata.count:_end
                return start..<end
            }

            for indices in indiceses {
                do {
                    let start = indices.startIndex / txtFileSplit
                    let binary = make_loudstxt3(lines: Array(dicdata[indices]))
                    try binary.write(to: loudsTxt3FileURL("\(start)"), options: .atomic)
                } catch {
                    debug("LongTermLearningMemory process", error)
                }
            }
        }
    }
}

/// 一時記憶用のデータなので、複雑な形状にしない。
struct TemporalLearningMemoryTrie {
    struct Node {
        var dataIndices: [Int] = []      // loudstxt3の中のデータのインデックスリスト
        var children: [UInt8: Int] = [:] // characterのIDからインデックスへのマッピング
    }

    fileprivate var nodes = [Node()]
    fileprivate var dicdata: [DicdataElement] = []
    fileprivate var metadata: [MetadataElement] = []

    /// 同じノードにあることがわかっているデータを一括で追加する場面で利用する関数
    /// 主にマージ時の利用を想定
    fileprivate mutating func append(dicdata: [DicdataElement], chars: [UInt8], metadata: [MetadataElement]) {
        if dicdata.count != metadata.count {
            debug("TemporalLearningMemoryTrie append: count of dicdata and metadata do not match")
            return
        }
        var index = 0
        for char in chars {
            if let nextIndex = nodes[index].children[char] {
                index = nextIndex
            } else {
                let nextIndex = nodes.endIndex
                nodes[index].children[char] = nextIndex
                nodes.append(Node())
                index = nextIndex
            }
        }
        for (dicdataElement, metadataElement) in zip(dicdata, metadata) {
            if let dataIndex = nodes[index].dataIndices.first(where: {Self.sameDicdataIfRubyIsEqual(left: self.dicdata[$0], right: dicdataElement)}) {
                // すでにnodes[index]に同じデータが存在している場合、カウントを加算し、最後に使った日を後の方に変更する
                withMutableValue(&self.metadata[dataIndex]) { currentMetadata in
                    currentMetadata.lastUsedDay = max(currentMetadata.lastUsedDay, metadataElement.lastUsedDay)
                    currentMetadata.lastUpdatedDay = max(currentMetadata.lastUpdatedDay, metadataElement.lastUpdatedDay)
                    currentMetadata.count += min(.max - currentMetadata.count, metadataElement.count)
                }
                self.dicdata[dataIndex] = dicdataElement
            } else {
                // まだnodes[index]に同じデータが存在していない場合、data末尾に新しい要素を追加してnodes[index]を更新する
                let dataIndex = self.dicdata.endIndex
                self.dicdata.append(dicdataElement)
                self.metadata.append(metadataElement)
                nodes[index].dataIndices.append(dataIndex)
            }
        }
    }

    /// ルビが同じだとわかっている場合に2つのDicdataElementが同じものか判定する関数
    private static func sameDicdataIfRubyIsEqual(left: DicdataElement, right: DicdataElement) -> Bool {
        return left.lcid == right.lcid && left.rcid == right.rcid && left.word == right.word
    }

    mutating func memorize(dicdataElement: DicdataElement, chars: [UInt8]) {
        var index = 0
        for char in chars {
            if let nextIndex = nodes[index].children[char] {
                index = nextIndex
            } else {
                let nextIndex = nodes.endIndex
                nodes[index].children[char] = nextIndex
                nodes.append(Node())
                index = nextIndex
            }
        }
        // 雑な設定だが200年くらいは持つのでヨシ。
        let day = LearningManager.today
        if let dataIndex = nodes[index].dataIndices.first(where: {Self.sameDicdataIfRubyIsEqual(left: self.dicdata[$0], right: dicdataElement)}) {
            withMutableValue(&self.metadata[dataIndex]) {
                $0.count += min(.max - $0.count, 1)
                // 雑な設定だが200年くらいは持つのでヨシ。
                $0.lastUsedDay = day
            }
        } else {
            let dataIndex = self.dicdata.endIndex
            var dicdataElement = dicdataElement
            let metadataElement = MetadataElement(day: day, count: 1)
            dicdataElement.baseValue = LongTermLearningMemory.valueForMetadata(metadata: metadataElement)
            self.dicdata.append(dicdataElement)
            self.metadata.append(metadataElement)
            nodes[index].dataIndices.append(dataIndex)
        }
    }

    func perfectMatch(chars: [UInt8]) -> [DicdataElement] {
        var index = 0
        for char in chars {
            if let nextIndex = nodes[index].children[char] {
                index = nextIndex
            } else {
                return []
            }
        }
        return nodes[index].dataIndices.map {self.dicdata[$0]}
    }

    func throughMatch(chars: [UInt8], depth: Range<Int>) -> [DicdataElement] {
        var index = 0
        var indices: [Int] = []
        for (offset, char) in chars.enumerated() {
            if let nextIndex = nodes[index].children[char] {
                index = nextIndex
                if depth.contains(offset) {
                    indices.append(contentsOf: nodes[index].dataIndices)
                }
            } else {
                return indices.map {self.dicdata[$0]}
            }
        }
        return indices.map {self.dicdata[$0]}
    }

    func prefixMatch(chars: [UInt8]) -> [DicdataElement] {
        var index = 0
        for char in chars {
            if let nextIndex = nodes[index].children[char] {
                index = nextIndex
            } else {
                return []
            }
        }
        var nodeIndices: [Int] = Array(nodes[index].children.values)
        var indices: [Int] = nodes[index].dataIndices
        while let index = nodeIndices.popLast() {
            nodeIndices.append(contentsOf: nodes[index].children.values)
            indices.append(contentsOf: nodes[index].dataIndices)
        }
        return indices.map {self.dicdata[$0]}
    }
}

final class LearningManager {
    private static var char2UInt8: [Character: UInt8] = {
        do {
            let chidURL = Bundle.main.bundleURL.appendingPathComponent("charID.chid", isDirectory: false)
            let string = try String(contentsOf: chidURL, encoding: .utf8)
            return [Character: UInt8].init(uniqueKeysWithValues: string.enumerated().map {($0.element, UInt8($0.offset))})
        } catch {
            debug("ファイルが存在しません: \(error)")
            return [:]
        }
    }()

    static var today: UInt16 {
        UInt16(Int(Date().timeIntervalSince1970) / 86400) - 19000
    }

    static func keyToChars(_ key: some StringProtocol) -> [UInt8] {
        return key.map {char2UInt8[$0, default: 0]}
    }

    private var temporaryMemory: TemporalLearningMemoryTrie = .init()
    @KeyboardSetting(.learningType) private var learningType

    var enabled: Bool {
        return self.learningType.needUsingMemory
    }

    init() {
        if MemoryResetCondition.shouldReset() {
            try? LongTermLearningMemory.reset()
        }
        @KeyboardSetting(.learningType) var learningType
        if !learningType.needUsingMemory {
            return
        }
    }

    func temporaryPerfectMatch(key: some StringProtocol) -> [DicdataElement] {
        if !learningType.needUsingMemory {
            return []
        }
        let chars = Self.keyToChars(key)
        return self.temporaryMemory.perfectMatch(chars: chars)
    }

    func temporaryThroughMatch(key: some StringProtocol, depth: Range<Int>) -> [DicdataElement] {
        if !learningType.needUsingMemory {
            return []
        }
        let chars = Self.keyToChars(key)
        return self.temporaryMemory.throughMatch(chars: chars, depth: depth)
    }

    func temporaryPrefixMatch(key: some StringProtocol) -> [DicdataElement] {
        if !learningType.needUsingMemory {
            return []
        }
        let chars = Self.keyToChars(key)
        return self.temporaryMemory.prefixMatch(chars: chars)
    }

    func update(data: [DicdataElement]) {
        if !learningType.needUpdateMemory {
            return
        }
        // 単語単位
        for datum in data where DicdataStore.needWValueMemory(datum) {
            self.temporaryMemory.memorize(dicdataElement: datum, chars: Self.keyToChars(datum.ruby))
        }

        if data.count == 1 {
            return
        }
        // 文節単位bigram
        do {
            var firstClause: DicdataElement?
            var secondClause: DicdataElement?
            for datum in data {
                if var newFirstClause = firstClause {
                    if var newSecondClause = secondClause {
                        if DicdataStore.isClause(newFirstClause.rcid, datum.lcid) {
                            // firstClauseとsecondClauseがあって文節境界である場合, bigramを作って学習に入れる
                            let element = DicdataElement(
                                word: newFirstClause.word + newSecondClause.word,
                                ruby: newFirstClause.ruby + newSecondClause.ruby,
                                lcid: newFirstClause.lcid,
                                rcid: newFirstClause.rcid,
                                mid: newSecondClause.mid,
                                value: newFirstClause.baseValue + newSecondClause.baseValue
                            )
                            debug("LearningManager update first/second", element)
                            self.temporaryMemory.memorize(dicdataElement: element, chars: LearningManager.keyToChars(element.ruby))
                            // firstClauseを押し出す
                            firstClause = secondClause
                            secondClause = datum
                        } else {
                            // firstClauseとsecondClauseがあって文節境界でない場合, secondClauseをアップデート
                            newSecondClause.word.append(contentsOf: datum.word)
                            newSecondClause.ruby.append(contentsOf: datum.ruby)
                            newSecondClause.rcid = datum.rcid
                            if DicdataStore.includeMMValueCalculation(datum) {
                                newSecondClause.mid = datum.mid
                            }
                            newSecondClause.baseValue += datum.baseValue
                            secondClause = newSecondClause
                        }
                    } else {
                        if DicdataStore.isClause(newFirstClause.rcid, datum.lcid) {
                            // firstClauseがあって文節境界である場合, secondClauseを作る
                            secondClause = datum
                        } else {
                            // firstClauseがあって文節境界でない場合, firstClauseをアップデート
                            newFirstClause.word.append(contentsOf: datum.word)
                            newFirstClause.ruby.append(contentsOf: datum.ruby)
                            newFirstClause.rcid = datum.rcid
                            if DicdataStore.includeMMValueCalculation(datum) {
                                newFirstClause.mid = datum.mid
                            }
                            newFirstClause.baseValue += datum.baseValue
                            firstClause = newFirstClause
                        }
                    }
                } else {
                    firstClause = datum
                }
            }
            if let firstClause, let secondClause {
                let element = DicdataElement(
                    word: firstClause.word + secondClause.word,
                    ruby: firstClause.ruby + secondClause.ruby,
                    lcid: firstClause.lcid,
                    rcid: firstClause.rcid,
                    mid: secondClause.mid,
                    value: firstClause.baseValue + secondClause.baseValue
                )
                self.temporaryMemory.memorize(dicdataElement: element, chars: LearningManager.keyToChars(element.ruby))
                debug("LearningManager update first/second rest", element)
            }
        }
        // 全体
        let element = DicdataElement(
            word: data.reduce(into: "") {$0.append(contentsOf: $1.word)},
            ruby: data.reduce(into: "") {$0.append(contentsOf: $1.ruby)},
            lcid: data.first?.lcid ?? CIDData.一般名詞.cid,
            rcid: data.last?.rcid ?? CIDData.一般名詞.cid,
            mid: data.last?.mid ?? MIDData.一般.mid,
            value: data.reduce(into: 0) {$0 += $1.baseValue}
        )
        debug("LearningManager update all", element)
        self.temporaryMemory.memorize(dicdataElement: element, chars: LearningManager.keyToChars(element.ruby))

    }

    func notifyChangeLearningType(_ type: LearningType) {
        switch type {
        case .inputAndOutput, .onlyOutput: break
        case .nothing:
            self.temporaryMemory = TemporalLearningMemoryTrie()
        }
    }

    func save() {
        if !learningType.needUpdateMemory {
            return
        }
        LongTermLearningMemory.merge(tempTrie: self.temporaryMemory)
    }

    func reset() {
        self.temporaryMemory = TemporalLearningMemoryTrie()
        try? LongTermLearningMemory.reset()
        @KeyboardSetting(.learningType) var learningType
        self._learningType = _learningType
    }
}
