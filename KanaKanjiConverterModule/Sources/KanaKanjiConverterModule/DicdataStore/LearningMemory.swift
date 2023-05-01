//
//  LearningMemory.swift
//  Keyboard
//
//  Created by ensan on 2021/02/01.
//  Copyright © 2021 ensan. All rights reserved.
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
    private static func pauseFileURL(directoryURL: URL) -> URL {
        directoryURL.appendingPathComponent(".pause", isDirectory: false)
    }
    private static func loudsFileURL(asTemporaryFile: Bool, directoryURL: URL) -> URL {
        if asTemporaryFile {
            return directoryURL.appendingPathComponent("memory.louds.2", isDirectory: false)
        } else {
            return directoryURL.appendingPathComponent("memory.louds", isDirectory: false)
        }
    }
    private static func metadataFileURL(asTemporaryFile: Bool, directoryURL: URL) -> URL {
        if asTemporaryFile {
            return directoryURL.appendingPathComponent("memory.memorymetadata.2", isDirectory: false)
        } else {
            return directoryURL.appendingPathComponent("memory.memorymetadata", isDirectory: false)
        }
    }
    private static func loudsCharsFileURL(asTemporaryFile: Bool, directoryURL: URL) -> URL {
        if asTemporaryFile {
            return directoryURL.appendingPathComponent("memory.loudschars2.2", isDirectory: false)
        } else {
            return directoryURL.appendingPathComponent("memory.loudschars2", isDirectory: false)
        }
    }
    private static func loudsTxt3FileURL(_ value: String, asTemporaryFile: Bool, directoryURL: URL) -> URL {
        if asTemporaryFile {
            return directoryURL.appendingPathComponent("memory\(value).loudstxt3.2", isDirectory: false)
        } else {
            return directoryURL.appendingPathComponent("memory\(value).loudstxt3", isDirectory: false)
        }
    }
    private static func fileExist(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
    /// 上書きする関数
    /// - Parameters:
    ///   - fromURL: 上書きする内容を持ったファイル。消去はされない。
    ///   - toURL: 上書きされるファイル。元あったファイルは消去され、`fromURL`で指定された中身になる。
    private static func overwrite(from fromURL: URL, to toURL: URL) throws {
        // これは成功してもしなくても良い
        // - ファイルが存在して削除ができない場合はエラーにしたいが、その後のcopyが失敗するので問題ない。
        // - ファイルが存在せず削除ができない場合はエラーにしたくないが、その後のcopyが成功するので問題ない。
        try? FileManager.default.removeItem(at: toURL)
        // `.2`ファイルは残したままreplaceを実施する。
        try FileManager.default.copyItem(at: fromURL, to: toURL)
    }

    /// 学習が壊れた状態にあるか判定する関数
    ///  - note: 壊れている場合、一時的に学習をオフにすると良い。
    static func memoryCollapsed(directoryURL: URL) -> Bool {
        fileExist(pauseFileURL(directoryURL: directoryURL))
    }

    static var txtFileSplit: Int { 2048 }
    static var maxMemoryCount: Int = 8192

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

    /// - note:
    ///   この関数は出現数(`metadata.count`)と単語の長さ(`dicdata.ruby.count`)に基づいてvalueを決める。
    ///   出現数が大きいほどvalueは大きくなり、単語が長いほどvalueは大きくなる。
    ///   特に、単語の長さが1のとき、値域は`[-5, -8]`となる。一方単語の長さが2であれば値域は`[-3, -6]`であり、長さ4ならば`[-2, -5]`となる。
    fileprivate static func valueForData(metadata: MetadataElement, dicdata: DicdataElement) -> PValue {
        let d = 1 - Double(metadata.count) / 255
        return PValue(-1 - 4 / Double(dicdata.ruby.count) - 3 * pow(d, 3))
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

    /// 関連するファイルを全て削除する
    static func reset(directoryURL: URL) throws {
        // 全削除する
        let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        for file in fileURLs {
            if file.isFileURL && (
                // 学習データファイル
                file.path.hasSuffix(".loudstxt3")
                    || file.path.hasSuffix(".loudschars2")
                    || file.path.hasSuffix(".memorymetadata")
                    || file.path.hasSuffix(".louds")
                    // 一時ファイル
                    || file.path.hasSuffix(".loudstxt3.2")
                    || file.path.hasSuffix(".loudschars2.2")
                    || file.path.hasSuffix(".memorymetadata.2")
                    || file.path.hasSuffix(".louds.2")
                    // .pauseファイル
                    || file.path.hasSuffix(".pause")
                    // 古い学習機能のデータファイル
                    || file.path.hasSuffix("learningMemory.txt")
            ) {
                try FileManager.default.removeItem(at: file)
            }
        }
    }

    /// 一時記憶と長期記憶の学習データをマージする
    static func merge(tempTrie: TemporalLearningMemoryTrie, forgetTargets: [DicdataElement] = [], directoryURL: URL) throws {
        // MARK: `.pause`ファイルが存在する場合、`merge`を行う前に`.2`ファイルの復活を試み、失敗した場合は`merge`を諦める。
        if fileExist(pauseFileURL(directoryURL: directoryURL)) {
            debug("LongTermLearningMemory merge collapsion detected, trying recovery...")
            try overwriteTempFiles(
                directoryURL: directoryURL,
                loudsFileTemp: nil,
                loudsCharsFileTemp: nil,
                metadataFileTemp: nil,
                loudsTxt3FileCount: nil,
                removingRead2File: true
            )
        }

        // MARK: ここで、前回のファイルの更新は問題なく成功していることが確認できる
        let startTime = Date()
        let today = LearningManager.today
        var newTrie = tempTrie
        // 構造:
        // dataCount(UInt32), count, data*count, count, data*count, ...
        // MARK: 読み出しは、`metadataFile`が存在しなかった場合（学習が一切ない場合）に失敗する。
        let ltMetadata = (try? Data(contentsOf: metadataFileURL(asTemporaryFile: false, directoryURL: directoryURL))) ?? Data([.zero, .zero, .zero, .zero])
        // 最初の4byteはentry countに対応する
        var metadataOffset = 0
        let entryCount = ltMetadata[metadataOffset ..< metadataOffset + 4].toArray(of: UInt32.self)[0]
        metadataOffset += 4

        debug("LongTermLearningMemory merge entryCount", entryCount, ltMetadata.count)

        // それぞれのloudstxt3ファイルに対して処理を行う
        for loudstxtIndex in 0 ..< Int(entryCount) / txtFileSplit + 1 {
            // loudstxt3の数
            let loudstxtData: Data
            do {
                loudstxtData = try Data(contentsOf: loudsTxt3FileURL("\(loudstxtIndex)", asTemporaryFile: false, directoryURL: directoryURL))
            } catch {
                debug("LongTermLearningMemory merge failed to read \(loudstxtIndex)", error)
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
                    // 忘却対象である場合は弾く
                    if forgetTargets.contains(dicdataElement) {
                        continue
                    }
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
                    // 32日ごとにカウントを半減させる
                    while today - metadataElement.lastUpdatedDay > 32 {
                        metadataElement.count >>= 1
                        metadataElement.lastUpdatedDay += 32
                    }
                    // カウントがゼロになるか128日以上使っていない単語は除外
                    if metadataElement.count == 0 || today - metadataElement.lastUsedDay >= 128 {
                        continue
                    }
                    dicdataElement.baseValue = valueForData(metadata: metadataElement, dicdata: dicdataElement)
                    newDicdata.append(dicdataElement)
                    newMetadata.append(metadataElement)
                }
                guard let chars = LearningManager.keyToChars(ruby) else {
                    continue
                }
                newTrie.append(dicdata: newDicdata, chars: chars, metadata: newMetadata)
            }
            // メモリ数上限を超過した場合、長いものから捨てる
            if newTrie.dicdata.count > Self.maxMemoryCount {
                break
            }
        }
        // newTrieのデータからLOUDSを作り書き出す
        try self.update(trie: newTrie, directoryURL: directoryURL)
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

    enum UpdateError: Error {
        /// `.pause`が存在するため更新を停止する場合
        case pauseFileExist
    }

    /// ファイルを安全に書き出すため、以下の手順を取る
    ///
    /// 1. 各ファイルを`memory.louds.2`のように書き出す
    /// 2. `.pause`を書き出す
    /// 3. それぞれの`.2`を元ファイルの位置にコピーする
    /// 4. `.pause`を削除する
    ///
    /// このとき、読み出し側では
    /// * `.pause`がない場合、`.2`のつかないファイルを読み出す。
    /// * `.pause`がある場合、適当なタイミングで上記ステップの`3`以降を再実行する。また、`.pause`がある場合、学習機能を停止する。
    ///
    /// 上記手順では`.pause`がない間は`.2`のつかないファイルが整合性を保っており、`.pause`がある場合は`.2`のつくファイルが整合性を保っているため、常に整合性を保ったファイルを維持することができる。
    ///
    /// 例えば1のステップの実行中にエラーが生じた場合、次回キーボードを開いた際は単に更新前のファイルを読み込む。
    ///
    /// 3のステップの実行中にエラーが生じた場合、次回キーボードを開いた際は学習を停止状態にする。ついで閉じる際に再度ステップ3を実行することで、安全に全てのファイルを更新することができる。
    static func update(trie: TemporalLearningMemoryTrie, directoryURL: URL) throws {
        // MARK: `.pause`の存在を確認し、存在していれば失敗させる
        // この場合、先に復活作業を実施すべきである
        guard !fileExist(pauseFileURL(directoryURL: directoryURL)) else {
            throw UpdateError.pauseFileExist
        }

        // MARK: 各ファイルを`.2`で書き出す
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
        let loudsFileTemp = loudsFileURL(asTemporaryFile: true, directoryURL: directoryURL)
        do {
            let binary = Data(bytes: bytes, count: bytes.count * 8)
            try binary.write(to: loudsFileTemp)
        }

        let loudsCharsFileTemp = loudsCharsFileURL(asTemporaryFile: true, directoryURL: directoryURL)
        do {
            let binary = Data(bytes: nodes2Characters, count: nodes2Characters.count)
            try binary.write(to: loudsCharsFileTemp)
        }
        let metadataFileTemp = metadataFileURL(asTemporaryFile: true, directoryURL: directoryURL)
        do {
            var binary = Data()
            binary += Data(bytes: [UInt32(metadata.count)], count: 4) // エントリ数をUInt32でマップ
            let result = metadata.reduce(into: binary) {
                $0.append($1.makeBinary())
            }
            try result.write(to: metadataFileTemp)
        }

        let loudsTxt3FileCount: Int
        do {
            loudsTxt3FileCount = ((dicdata.count) / txtFileSplit) + 1
            let indiceses: [Range<Int>] = (0..<loudsTxt3FileCount).map {
                let start = $0 * txtFileSplit
                let _end = ($0 + 1) * txtFileSplit
                let end = dicdata.count < _end ? dicdata.count:_end
                return start..<end
            }

            for indices in indiceses {
                do {
                    let start = indices.startIndex / txtFileSplit
                    let binary = make_loudstxt3(lines: Array(dicdata[indices]))
                    try binary.write(to: loudsTxt3FileURL("\(start)", asTemporaryFile: true, directoryURL: directoryURL), options: .atomic)
                }
            }
        }

        // MARK: `.pause`ファイルを書き出す
        try Data().write(to: pauseFileURL(directoryURL: directoryURL))

        // MARK: 各`.2`のファイルで元のファイルを上書きする
        try overwriteTempFiles(
            directoryURL: directoryURL,
            loudsFileTemp: loudsFileTemp,
            loudsCharsFileTemp: loudsCharsFileTemp,
            metadataFileTemp: metadataFileTemp,
            loudsTxt3FileCount: loudsTxt3FileCount,
            // MARK: 成功の場合、`.pause`ファイルも削除する
            removingRead2File: true
        )
    }

    /// - note: 上書きが全て成功するまで、一時ファイルは削除してはいけない。安全のため、`.pause`を除きそもそも一時ファイルを一切削除しないようにする。
    private static func overwriteTempFiles(directoryURL: URL, loudsFileTemp: URL?, loudsCharsFileTemp: URL?, metadataFileTemp: URL?, loudsTxt3FileCount: Int?, removingRead2File: Bool) throws {
        try overwrite(
            from: loudsCharsFileTemp ?? loudsCharsFileURL(asTemporaryFile: true, directoryURL: directoryURL),
            to: loudsCharsFileURL(asTemporaryFile: false, directoryURL: directoryURL)
        )
        try overwrite(
            from: metadataFileTemp ?? metadataFileURL(asTemporaryFile: true, directoryURL: directoryURL),
            to: metadataFileURL(asTemporaryFile: false, directoryURL: directoryURL)
        )
        if let loudsTxt3FileCount {
            for i in  0 ..< loudsTxt3FileCount {
                try overwrite(
                    from: loudsTxt3FileURL("\(i)", asTemporaryFile: true, directoryURL: directoryURL),
                    to: loudsTxt3FileURL("\(i)", asTemporaryFile: false, directoryURL: directoryURL)
                )
            }
        } else {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            for file in fileURLs {
                if file.isFileURL && file.path.hasSuffix(".loudstxt3.2") {
                    try overwrite(from: file, to: URL(fileURLWithPath: String(file.path.dropLast(2))))
                }
            }
        }
        // 読み出し側で最初に読み出されるのは`.louds`なので、これを最後に書き出す方が安全
        try overwrite(
            from: loudsFileTemp ?? loudsFileURL(asTemporaryFile: true, directoryURL: directoryURL),
            to: loudsFileURL(asTemporaryFile: false, directoryURL: directoryURL)
        )
        if removingRead2File {
            try FileManager.default.removeItem(at: pauseFileURL(directoryURL: directoryURL))
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
        left.lcid == right.lcid && left.rcid == right.rcid && left.word == right.word
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
            dicdataElement.baseValue = LongTermLearningMemory.valueForData(metadata: metadataElement, dicdata: dicdataElement)
            self.dicdata.append(dicdataElement)
            self.metadata.append(metadataElement)
            nodes[index].dataIndices.append(dataIndex)
        }
    }

    @discardableResult
    mutating func forget(dicdataElement: DicdataElement, chars: [UInt8]) -> Bool {
        var index = 0
        for char in chars {
            if let nextIndex = nodes[index].children[char] {
                index = nextIndex
            } else {
                // 存在しない場合
                return false
            }
        }
        // 存在する場合
        // dataIndicesから削除する(dicdataの方は触らない)
        nodes[index].dataIndices.removeAll(where: {self.dicdata[$0] == dicdataElement})
        return true
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
    private static func updateChar2Int8(bundleURL: URL) {
        do {
            let chidURL = bundleURL.appendingPathComponent("Dictionary/louds/charID.chid", isDirectory: false)
            let string = try String(contentsOf: chidURL, encoding: .utf8)
            Self.char2UInt8 = [Character: UInt8].init(uniqueKeysWithValues: string.enumerated().map {($0.element, UInt8($0.offset))})
        } catch {
            debug("ファイルが存在しません: \(error)")
        }
    }
    private static var char2UInt8: [Character: UInt8] = [:]

    static var today: UInt16 {
        UInt16(Int(Date().timeIntervalSince1970) / 86400) - 19000
    }

    static func keyToChars(_ key: some StringProtocol) -> [UInt8]? {
        var chars: [UInt8] = []
        chars.reserveCapacity(key.count)
        for character in key {
            if let char = char2UInt8[character] {
                chars.append(char)
            } else {
                return nil
            }
        }
        return chars
    }

    private var temporaryMemory: TemporalLearningMemoryTrie = .init()
    private var options: ConvertRequestOptions = .default
    private var memoryCollapsed: Bool = false

    var enabled: Bool {
        (!self.memoryCollapsed) && self.options.learningType.needUsingMemory
    }

    init() {
        self.memoryCollapsed = LongTermLearningMemory.memoryCollapsed(directoryURL: self.options.memoryDirectoryURL)
        if memoryCollapsed {
            // 学習データが壊れている状態であることを警告する
            debug("LearningManager init: Memory Collapsed")
        }
        if !options.learningType.needUsingMemory {
            return
        }
        Self.updateChar2Int8(bundleURL: options.bundleURL)
    }

    /// - Returns: Whether cache should be reseted or not.
    func setRequestOptions(options: ConvertRequestOptions) -> Bool {
        // 変更があったら`char2Int8`を読み込み直す
        if options.bundleURL != self.options.bundleURL {
            Self.updateChar2Int8(bundleURL: options.bundleURL)
        }
        self.options = options
        LongTermLearningMemory.maxMemoryCount = options.maxMemoryCount

        switch options.learningType {
        case .inputAndOutput, .onlyOutput: break
        case .nothing:
            self.temporaryMemory = TemporalLearningMemoryTrie()
        }

        // リセットチェックも実施
        if options.shouldResetMemory {
            self.reset()
            self.options.shouldResetMemory = false
            return true
        }
        return false
    }

    func temporaryPerfectMatch(charIDs: [UInt8]) -> [DicdataElement] {
        if !options.learningType.needUsingMemory {
            return []
        }
        return self.temporaryMemory.perfectMatch(chars: charIDs)
    }

    func temporaryThroughMatch(charIDs: [UInt8], depth: Range<Int>) -> [DicdataElement] {
        if !options.learningType.needUsingMemory {
            return []
        }
        return self.temporaryMemory.throughMatch(chars: charIDs, depth: depth)
    }

    func temporaryPrefixMatch(charIDs: [UInt8]) -> [DicdataElement] {
        if !options.learningType.needUsingMemory {
            return []
        }
        return self.temporaryMemory.prefixMatch(chars: charIDs)
    }

    func update(data: [DicdataElement]) {
        if !options.learningType.needUpdateMemory {
            return
        }
        // 単語単位
        for datum in data where DicdataStore.needWValueMemory(datum) {
            guard let chars = Self.keyToChars(datum.ruby) else {
                continue
            }
            self.temporaryMemory.memorize(dicdataElement: datum, chars: chars)
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
                            // firstClauseを押し出す
                            firstClause = secondClause
                            secondClause = datum
                            guard let chars = Self.keyToChars(element.ruby) else {
                                continue
                            }
                            debug("LearningManager update first/second", element)
                            self.temporaryMemory.memorize(dicdataElement: element, chars: chars)
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
                if let chars = Self.keyToChars(element.ruby) {
                    debug("LearningManager update first/second rest", element)
                    self.temporaryMemory.memorize(dicdataElement: element, chars: chars)
                }
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
        guard let chars = Self.keyToChars(element.ruby) else {
            return
        }
        debug("LearningManager update all", element)
        self.temporaryMemory.memorize(dicdataElement: element, chars: chars)
    }

    /// データに含まれる語彙の学習をリセットする関数
    func forgetMemory(data: [DicdataElement]) {
        // 1. temporary memoryを削除する
        for element in data {
            guard let chars = Self.keyToChars(element.ruby) else {
                continue
            }
            self.temporaryMemory.forget(dicdataElement: element, chars: chars)
        }
        // 2. longterm memoryを削除する
        do {
            try LongTermLearningMemory.merge(tempTrie: self.temporaryMemory, forgetTargets: data, directoryURL: self.options.memoryDirectoryURL)
            // マージが済んだので、temporaryMemoryを空にする
            self.temporaryMemory = TemporalLearningMemoryTrie()
        } catch {
            // アップデートに失敗した場合、そのまま諦める。
            debug("LearningManager resetLearning: Failed to save LongTermLearningMemory", error)
        }
        // 状態を更新する
        self.memoryCollapsed = LongTermLearningMemory.memoryCollapsed(directoryURL: self.options.memoryDirectoryURL)
    }

    func save() {
        if !options.learningType.needUpdateMemory {
            return
        }
        do {
            try LongTermLearningMemory.merge(tempTrie: self.temporaryMemory, directoryURL: self.options.memoryDirectoryURL)
            // マージが済んだので、temporaryMemoryを空にする
            self.temporaryMemory = TemporalLearningMemoryTrie()
        } catch {
            // アップデートに失敗した場合、そのまま諦める。
            debug("LearningManager save: Failed to save LongTermLearningMemory", error)
        }
        // 状態を更新する
        self.memoryCollapsed = LongTermLearningMemory.memoryCollapsed(directoryURL: self.options.memoryDirectoryURL)
    }

    func reset() {
        self.temporaryMemory = TemporalLearningMemoryTrie()
        do {
            try LongTermLearningMemory.reset(directoryURL: self.options.memoryDirectoryURL)
        } catch {
            debug("LearningManager reset failed", error)
        }
    }
}
