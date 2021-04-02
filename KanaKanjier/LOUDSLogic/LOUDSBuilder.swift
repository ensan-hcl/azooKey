//
//  LOUDSBuilder.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/13.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
extension LOUDSBuilder {
    static var char2UInt8: [Character: UInt8] = [:]

    static func loadCharID() {
        do {
            let string = try String(contentsOfFile: Bundle.main.bundlePath + "/charID.chid", encoding: String.Encoding.utf8)
            Self.char2UInt8 = [Character: UInt8].init(uniqueKeysWithValues: string.enumerated().map {($0.element, UInt8($0.offset))})
        } catch {
            debug("ファイルが存在しません: \(error)")
        }

    }

    static func getID(from char: Character) -> UInt8? {
        return Self.char2UInt8[char]
    }
}

struct LOUDSBuilder {
    let txtFileSplit: Int
    let templateData: [TemplateData]

    init(txtFileSplit: Int) {
        self.txtFileSplit = txtFileSplit
        Self.loadCharID()

        if let data = TemplateData.load() {
            self.templateData = data
        } else {
            self.templateData = []
        }
    }

    private func BoolToUInt64(_ bools: [Bool]) -> [UInt64] {
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

    func loadUserDictInfo() -> (paths: [String], blocks: [String], useradds: [UserDictionaryData]) {
        let paths: [String]
        if let list = UserDefaults.standard.array(forKey: "additional_dict") as? [String] {
            paths = list.compactMap {AdditionalDict.init(rawValue: $0)}.flatMap {$0.dictFileIdentifiers}
        } else {
            paths = []
        }

        let blocks: [String]
        if let list = UserDefaults.standard.array(forKey: "additional_dict_blocks") as? [String] {
            blocks = list.compactMap {AdditionalDictBlockTarget.init(rawValue: $0)}.flatMap {$0.target}
        } else {
            blocks = []
        }

        let useradds: [UserDictionaryData]
        if let dictionary = UserDictionary.get() {
            useradds = dictionary.items
        } else {
            useradds = []
        }

        return (paths, blocks, useradds)
    }

    func parseTemplate<S: StringProtocol>(_ word: S) -> String {
        if let range = word.range(of: "\\{\\{.*?\\}\\}", options: .regularExpression) {
            let center: String
            if let data = templateData.first(where: {$0.name == word[range].dropFirst(2).dropLast(2)}) {
                center = data.literal.export()
            } else {
                center = String(word[range])
            }

            let left = word[word.startIndex..<range.lowerBound]
            let right = word[range.upperBound..<word.endIndex]
            return parseTemplate(left) + center + parseTemplate(right)
        } else {
            return word.escaped()
        }
    }

    func makeDictionaryForm(_ data: UserDictionaryData) -> [String] {
        let katakanaRuby = data.ruby.applyingTransform(.hiraganaToKatakana, reverse: false)!
        if data.isVerb {
            let cid = 772
            let conjuctions = ConjuctionBuilder.getConjugations(data: (word: data.word, ruby: katakanaRuby, cid: cid), addStandardForm: true)
            return conjuctions.map {
                "\($0.ruby)\t\(parseTemplate($0.word))\t\($0.cid)\t\($0.cid)\t\(501)\t-5.0000"
            }
        }
        let cid: Int
        if data.isPersonName {
            cid = 1289
        } else if data.isPlaceName {
            cid = 1293
        } else {
            cid = 1288
        }
        return ["\(katakanaRuby)\t\(parseTemplate(data.word))\t\(cid)\t\(cid)\t\(501)\t-5.0000"]
    }

    func make_loudstxt2(lines: [String]) -> Data {
        let lc = lines.count    // データ数
        let count = Data(bytes: [UInt16(lc)], count: 2) // データ数をUInt16でマップ

        let data = lines.map {$0.data(using: .utf8) ?? Data()}
        let body = data.reduce(Data(), +)   // データ

        let header_endIndex: UInt32 = 2 + UInt32(lc) * UInt32(MemoryLayout<UInt32>.size)
        let headerArray = data.dropLast().reduce(into: [header_endIndex]) {array, value in // ヘッダの作成
            array.append(array.last! + UInt32(value.count))
        }

        let header = Data(bytes: headerArray, count: MemoryLayout<UInt32>.size * headerArray.count)
        let binary = count + header + body

        return binary
    }

    func process(to identifier: String = "user") {
        let trieroot = TrieNode<Character, Int>()

        let (paths, blocks, useradds) = self.loadUserDictInfo()

        var csvLines: [Substring] = []
        do {
            for path in paths {
                let string = try String(contentsOfFile: Bundle.main.bundlePath + "/" + path, encoding: String.Encoding.utf8)
                csvLines.append(contentsOf: string.split(separator: "\n"))
            }
            csvLines.append(contentsOf: useradds.flatMap {self.makeDictionaryForm($0)}.map {Substring($0)})
            let csvData = csvLines.map {$0.components(separatedBy: "\t")}
            csvData.indices.forEach {index in
                if !blocks.contains(csvData[index][1]) {
                    trieroot.insertValue(for: csvData[index][0], value: index)
                }
            }
        } catch {
            debug("ファイルが存在しません: \(error)")
            csvLines = []
            return
        }

        let directoryPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!

        let binaryFilePath = directoryPath.appendingPathComponent("\(identifier).louds").path
        let loudsCharsFilePath = directoryPath.appendingPathComponent("\(identifier).loudschars2").path
        let loudsTxtFilePath: (String) -> String = {directoryPath.appendingPathComponent("\(identifier + $0).loudstxt").path}
        let loudsTxt2FilePath: (String) -> String = {directoryPath.appendingPathComponent("\(identifier + $0).loudstxt2").path}

        var currentID = 0
        var nodes2Characters: [Character] = ["\0", "\0"]
        var data: [String] = ["\0", "\0"]
        var bits: [Bool] = [true, false]
        trieroot.id = currentID
        currentID += 1
        var currentNodes: [(Character, TrieNode<Character, Int>)] = trieroot.children.map {($0.key, $0.value)}.sorted(by: {$0.0 < $1.0})
        bits += [Bool].init(repeating: true, count: trieroot.children.count) + [false]
        while !currentNodes.isEmpty {
            currentNodes.forEach {char, node in
                node.id = currentID
                nodes2Characters.append(char)
                let stringData: String = Array(node.value).sorted().map {csvLines[$0]}.joined(separator: ",")

                data.append(stringData)
                bits += [Bool].init(repeating: true, count: node.children.count) + [false]
                currentID += 1
            }
            currentNodes = currentNodes.flatMap {$0.1.children.map {($0.key, $0.value)}.sorted(by: {$0.0 < $1.0})}
        }

        let bytes = BoolToUInt64(bits)

        do {
            let binary = Data(bytes: bytes, count: bytes.count * 8)
            try binary.write(to: URL(fileURLWithPath: binaryFilePath))
        } catch {
            debug(error)
        }

        do {
            let uint8s = nodes2Characters.map {Self.getID(from: $0) ?? 0}    // エラー回避。0は"\0"に対応し、呼ばれることはない。
            let binary = Data(bytes: uint8s, count: uint8s.count)
            try binary.write(to: URL(fileURLWithPath: loudsCharsFilePath))
        } catch {
            debug(error)
        }

        do {
            let count = (data.count) / txtFileSplit
            let indiceses: [Range<Int>] = (0...count).map {
                let start = $0 * txtFileSplit
                let _end = ($0 + 1) * txtFileSplit
                let end = data.count < _end ? data.count:_end
                return start..<end
            }

            for indices in indiceses {
                do {
                    let start = indices.startIndex / txtFileSplit
                    let binary = make_loudstxt2(lines: Array(data[indices]))
                    try binary.write(to: URL(fileURLWithPath: loudsTxt2FilePath("\(start)")), options: .atomic)
                    try FileManager.default.removeItem(atPath: loudsTxtFilePath("\(start)"))
                } catch {
                    debug(error)
                }
            }

            Store.shared.messageManager.done(.ver1_5_update_loudstxt)
        }
    }

}
