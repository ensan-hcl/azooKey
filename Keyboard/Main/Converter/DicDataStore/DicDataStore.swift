//
//  DicDataStore.swift
//  Keyboard
//
//  Created by β α on 2020/09/17.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

private final class LearningMemoryElement{
    var data: DicDataElementProtocol
    var count: Int
    var next: [(index: Int, count: Int)]
    init(data: DicDataElementProtocol, count: Int, next: [(index: Int, count: Int)] = []){
        self.data = data
        self.count = count
        self.next = next
    }
}

private struct LearningMemorys{
    static let memoryCount = 100
    static let memoryFileName = "learningMemory"
    private var values: [LearningMemoryElement]
    private var index2order: [Int]

    private func getMinOrderIndex() -> Int? {
        let pair = self.index2order.enumerated().min(by: {$0.element < $1.element})
        return pair?.offset
    }


    private mutating func updateOrder(at index: Int){
        let order = self.index2order[index]
        if order == self.index2order.endIndex - 1{
            return
        }
        self.index2order = self.index2order.map{
            if $0 < order{
                return $0
            }
            else if $0 == order{
                return self.index2order.endIndex - 1
            }
            else{
                return $0 - 1
            }
        }
    }

    func match<S: StringProtocol>(_ ruby: S) -> DicDataStore.DicData {
        let dicdata = self.values.lazy.filter{$0.data.ruby == ruby}.map{$0.data.adjustedData(PValue($0.count * 3))}
        return Array(dicdata)
    }


    func getSingle(_ data: DicDataElementProtocol) -> Int {
        if let element = self.values.last(where: {$0.data == data}){
            return element.count
        }
        return .zero
    }

    func getPrefixDicData<S: StringProtocol>(_ prefix: S) -> DicDataStore.DicData {
        let dicdata = self.values.lazy.filter{$0.data.ruby != prefix && $0.data.ruby.hasPrefix(prefix)}.map{$0.data.adjustedData(PValue($0.count * 3))}
        return Array(dicdata)
    }

    func getNextData(_ data: DicDataElementProtocol) -> [(next: DicDataElementProtocol, count: Int)] {
        if let element = self.values.last(where: {$0.data == data}){
            return element.next.map{(next: self.values[$0.index].data, count: $0.count)}
        }
        return []
    }

    func matchNext(_ previous: DicDataElementProtocol, next: DicDataElementProtocol) -> Int {
        if let element = self.values.last(where: {$0.data == previous}),
           let index = self.values.lastIndex(where: {$0.data == next}),
           let next = element.next.filter({$0.index == index}).last{
            return next.count
        }
        return .zero
    }

    mutating func update(_ data: [DicDataElementProtocol], lastData: DicDataElementProtocol?){
        if !Store.shared.userSetting.learningType.needUpdateMemory{
            return
        }

        let datalist = ((lastData == nil) ? [] : [lastData!]) + data

        var lastIndex: Int? = nil
        //elementは参照型であることに留意
        datalist.indices.forEach{i in
            let _lastIndex = lastIndex
            if i != .zero || lastData == nil{
                let needMemoryCount = DicDataStore.needWValueMemory(datalist[i])
                let countDelta = needMemoryCount ? 1:0
                if let index = self.values.lastIndex(where: {$0.data == datalist[i]}){
                    self.updateOrder(at: index)
                    lastIndex = index
                    self.values[index].count += countDelta
                }else{
                    if self.values.count < Self.memoryCount{
                        lastIndex = self.values.endIndex
                        self.values.append(LearningMemoryElement(data: datalist[i], count: countDelta))
                        self.index2order.append(self.index2order.count)
                    }else if let minIndex = self.getMinOrderIndex(){
                        self.values.forEach{
                            $0.next = $0.next.lazy.filter{$0.index != minIndex}
                        }
                        self.values[minIndex] = LearningMemoryElement(data: datalist[i], count: countDelta)
                        self.updateOrder(at: minIndex)
                        lastIndex = minIndex
                    }
                }
            }

            guard let prevIndex = _lastIndex,
                  let nextIndex = lastIndex else{
                return
            }

            let prev = self.values[prevIndex]
            if let index = prev.next.firstIndex(where: {$0.index == nextIndex}){
                prev.next[index].count += 1
            }else{
                prev.next.append((index: nextIndex, count: 1))
            }
        }
    }

    mutating func notifyChangeLearningType(_ type: LearningType){
        switch type{
        case .inputAndOutput:
            self.values = Self.load()
            self.values.reserveCapacity(Self.memoryCount + 1)
            self.index2order = Array(values.indices)
        case .onlyOutput:
            self.values = Self.load()
            self.values.reserveCapacity(Self.memoryCount + 1)
            self.index2order = Array(values.indices)
        case .nothing:
            self.values = []
            self.index2order = []
        }
    }

    func save(force: Bool = false){
        if !force && !Store.shared.userSetting.learningType.needUpdateMemory{
            return
        }
        let string: String = self.values.map{
            let nextString = $0.next.map{"\($0.index),\($0.count)"}.joined(separator: "\0")
            return "\($0.count)\t\($0.data.ruby)\t\($0.data.word)\t\($0.data.lcid)\t\($0.data.rcid)\t\($0.data.mid)\t\($0.data.baseValue)\t\(nextString)"
        }.joined(separator: "\n")
        Store.shared.saveTextFile(contents: string, to: Self.memoryFileName)
    }

    mutating func reset(){
        self.values = []
        self.index2order = []
        self.save(force: true)
    }

    init(){
        if UserSettingDepartment.checkResetSetting(){
            //リセットする。
            self.values = []
            self.index2order = []
            self.save(force: true)
        }

        if !Store.shared.userSetting.learningType.needUsingMemory{
            self.values = []
            self.index2order = []
            return
        }

        self.values = Self.load()
        self.values.reserveCapacity(Self.memoryCount + 1)
        self.index2order = Array(values.indices)
    }

    private static func load() -> [LearningMemoryElement]{
        let contents = Store.shared.readTextFile(to: Self.memoryFileName)
        if contents.isEmpty{
            return []
        }

        let values: [LearningMemoryElement] = contents.split(separator: "\n").map{(line: String.SubSequence) in
            let splited: [String.SubSequence] = line.split(separator: "\t", omittingEmptySubsequences: false)
            let count: Int = Int(splited[0]) ?? 1
            let data: DicDataElementProtocol = Self.convertLatticeNodeData(from: splited[1...6])
            if splited[7].isEmpty{
                return LearningMemoryElement(data: data, count: count, next: [])
            }
            let next: [(index: Int, count: Int)] = splited[7].split(separator: "\0").map{
                let tuple = $0.split(separator: ",")
                return (index: Int(tuple[0])!, count: Int(tuple[1])!)
            }
            return LearningMemoryElement(data: data, count: count, next: next)
        }
        return values
    }

    private static func convertLatticeNodeData(from dataString: ArraySlice<String.SubSequence>) -> DicDataElementProtocol {
        let delta = dataString.startIndex
        let LRE = dataString[3+delta].isEmpty
        let SRE = dataString[1+delta].isEmpty
        let V3E = dataString[5+delta].isEmpty
        let ruby = String(dataString[0+delta])
        let word = SRE ? ruby:String(dataString[1+delta])
        let lcid = Int(dataString[2+delta]) ?? .zero
        let rcid = Int(dataString[3+delta]) ?? lcid
        let mid = Int(dataString[4+delta]) ?? .zero
        let value: PValue = PValue(dataString[5+delta]) ?? -30.0
        //取得したデータを辞書に加える。
        let latticeNodeData: DicDataElementProtocol
        if LRE{
            if SRE{
                if V3E{
                    latticeNodeData = LRE_SRE_V3E_DicDataElement(ruby: ruby, cid: lcid, mid: mid, adjust: .zero)
                }else{
                    latticeNodeData = LRE_SRE_DicDataElement(ruby: ruby, cid: lcid, mid: mid, value: value, adjust: .zero)
                }
            }else{
                if V3E{
                    latticeNodeData = LRE_V3E_DicDataElement(string: word, ruby: ruby, cid: lcid, mid: mid, adjust: .zero)
                }else{
                    latticeNodeData = LRE_DicDataElement(word: word, ruby: ruby, cid: lcid, mid: mid, value: value, adjust: .zero)
                }
            }
        }else{
            if SRE{
                if V3E{
                    latticeNodeData = SRE_V3E_DicDataElement(ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, adjust: .zero)
                }else{
                    latticeNodeData = SRE_DicDataElement(ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: value, adjust: .zero)
                }
            }else{
                if V3E{
                    latticeNodeData = V3E_DicDataElement(string: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, adjust:  .zero)
                }else{
                    latticeNodeData = All_DicDataElement(string: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: value, adjust: .zero)
                }
            }
        }
        return latticeNodeData
    }

}


final class DicDataStore{
    init(){
        debug("DicDataStoreが初期化されました")
        self.setup()
    }

    typealias DicData = [DicDataElementProtocol]
    private var ccParsed: Set<Int> = []
    private var ccLines: [[Int: PValue]] = []
    private var mmValue: [PValue] = []
    private let treshold: PValue = -17

    private var loudses: [String: LOUDS] = [:]
    private var charsID: [Character: UInt8] = [:]
    private var memory: LearningMemorys = LearningMemorys()
    private var zeroHintPredictionDicData: DicData? = nil

    internal let maxlength: Int = 20
    private let midCount = 502
    private let midCount = 1319

    private let numberFormatter = NumberFormatter()
    ///初期化時のセットアップ用の関数。プロパティリストを読み込み、連接確率リストを読み込んで行分割し保存しておく。
    private func setup(){
        numberFormatter.numberStyle = .spellOut
        numberFormatter.locale = .init(identifier: "ja-JP")
        self.ccLines = [[Int: PValue]].init(repeating: [:], count: cidCount)

        do{
            let string = try String(contentsOfFile: Bundle.main.bundlePath + "/charID.chid", encoding: String.Encoding.utf8)
            charsID = [Character: UInt8].init(uniqueKeysWithValues: string.enumerated().map{($0.element, UInt8($0.offset))})
        } catch {
            debug("ファイルが存在しません: \(error)")
        }
        do{
            let path = Bundle.main.bundlePath + "/mm.binary"
            do {
                let binaryData = try Data(contentsOf: URL(fileURLWithPath: path), options: [.uncached])
                let ui64array = binaryData.withUnsafeBytes{pointer -> [Float] in
                    return Array(
                        UnsafeBufferPointer(
                            start: pointer.baseAddress!.assumingMemoryBound(to: Float.self),
                            count: pointer.count / MemoryLayout<Float>.size
                        )
                    )
                }
                self.mmValue = ui64array.map{PValue($0)}
            } catch {
                debug("Failed to read the file.")
                self.mmValue = [PValue].init(repeating: .zero, count: self.midCount*self.midCount)
            }
        }
        self.loadLOUDS(identifier: "user")
    }

    func sendToDicDataStore(_ data: Store.DicDataStoreNotification){
        switch data{
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
        }
    }

    private func closeKeyboard(){
        self.memory.save()
    }

    private func reloadUserDict(){
        self.loadLOUDS(identifier: "user")
    }

    ///ペナルティ関数。文字数で決める。
    private func getPenalty(data: DicDataElementProtocol) -> PValue {
        return -2.0/PValue(data.word.count)
    }

    ///計算時に利用。無視すべきデータかどうか。
    private func shouldBeRemoved(value: PValue, wordCount: Int) -> Bool {
        let d = value - self.treshold
        if d < 0{
            return true
        }
        return 2.0/PValue(wordCount) < -d
    }

    ///計算時に利用。無視すべきデータかどうか。
    internal func shouldBeRemoved(data: DicDataElementProtocol) -> Bool {
        if data.adjust.isZero && (
            data is LRE_V3E_DicDataElement ||
            data is V3E_DicDataElement ||
            data is SRE_V3E_DicDataElement
        ){
            return true
        }
        let d = data.value() - self.treshold
        if d < 0{
            return true
        }
        return self.getPenalty(data: data) < -d
    }

    private func loadLOUDS(identifier: String){
        if let louds = LOUDS.build(identifier){
            self.loudses[identifier] = louds
        }else{
            debug("loudsの読み込みに失敗")
        }
    }

    private func perfectMatchLOUDS(identifier: String, key: String) -> [Int] {
        if !self.loudses.keys.contains(identifier){
            self.loadLOUDS(identifier: identifier)
        }
        guard let louds = self.loudses[identifier] else {
            return []
        }
        return [louds.searchNodeIndex(chars: key.map{self.charsID[$0, default: .max]})].compactMap{$0}
    }

    private func throughMatchLOUDS(identifier: String, key: String) -> [Int] {
        if !self.loudses.keys.contains(identifier){
            self.loadLOUDS(identifier: identifier)
        }
        guard let louds = self.loudses[identifier] else {
            return []
        }
        return louds.byfixNodeIndices(chars: key.map{self.charsID[$0, default: .max]})
    }

    private func prefixMatchLOUDS(identifier: String, key: String, depth: Int = .max) -> [Int] {
        if !self.loudses.keys.contains(identifier){
            self.loadLOUDS(identifier: identifier)
        }
        guard let louds = self.loudses[identifier] else {
            return []
        }
        return louds.prefixNodeIndices(chars: key.map{self.charsID[$0, default: .max]}, maxDepth: depth)
    }

    private func getDicData(identifier: String, indices: Set<Int>) -> [DicDataElementProtocol] {
        //split = 2048
        let dict = [Int: [Int]].init(grouping: indices, by: {$0 >> 11})
        let data: [[Substring]] = dict.flatMap{(dictKeyValue) -> [[Substring]] in
            let datablock: [String] = LOUDS.getData(identifier + "\(dictKeyValue.key)", indices: dictKeyValue.value.map{$0 & 2047})
            let strings = datablock.flatMap{$0.split(separator: ",", omittingEmptySubsequences: false)}
            return strings.map{$0.split(separator: "\t", omittingEmptySubsequences: false)}
        }
        return data.filter{$0.count > 5}.map{self.convertDicData(from: $0)}
    }

    ///kana2latticeから参照する。louds版。
    /// - Parameters:
    ///   - inputData: 入力データ
    ///   - from: 起点
    internal func getLOUDSData<T: InputDataProtocol, LatticeNode: LatticeNodeProtocol>(inputData: T, from index: Int) -> [LatticeNode] {
        let start_0 = Date()
        let toIndex = min(inputData.count, index + self.maxlength)
        let segments = (index ..< toIndex).map{inputData[index...$0]}
        let wisedicdata: DicData = (index ..< toIndex).flatMap{self.getWiseDicData(head: segments[$0-index], allowRomanLetter: $0+1 == toIndex)}
        let memorydicdata: DicData = (index ..< toIndex).flatMap{self.getMatch(segments[$0-index])}

        debug("計算所要時間: wisedicdata", -start_0.timeIntervalSinceNow)

        let start_1_1 = Date()
        var string2segment = [String: Int].init()
        //indicesをreverseすることで、stringWithTypoは長さの長い順に並ぶ=removeでヒットしやすくなる
        let stringWithTypoData: [(string: String, penalty: PValue)] = (index ..< toIndex).reversed().flatMap{(end) -> [(string: String, penalty: PValue)] in
            let result = inputData.getRangeWithTypos(index, end)
            result.forEach{
                string2segment[$0.string] = end-index
            }
            return inputData.getRangeWithTypos(index, end)
        }


        let strings = stringWithTypoData.map{$0.string}
        let string2penalty = [String: PValue].init(stringWithTypoData, uniquingKeysWith: {max($0, $1)})
        debug("計算所要時間: 謝り訂正の検索", -start_1_1.timeIntervalSinceNow)   //ここが遅い

        let start_1_2 = Date()
        var stringSet: Set<String> = Set(strings)
        strings.forEach{string in
            if string.count > 4{
                return
            }
            if strings.contains(where: {$0 != string && $0.hasPrefix(string)}){
                stringSet.remove(string)
            }
        }
        debug("計算所要時間: 検索対象の整理", -start_1_2.timeIntervalSinceNow)
        let start_2 = Date()
        //先頭の文字: そこで検索したい文字列の集合
        let group = [Character: [String]].init(grouping: stringSet, by: {$0.first!})

        let indices: [(String, Set<Int>)] = group.map{dic in
            let key = String(dic.key)
            let set = Set(dic.value.flatMap{string in self.throughMatchLOUDS(identifier: key, key: string)})
            return (key, set)
        }

        let userDictIndices = Set(stringSet.flatMap{self.throughMatchLOUDS(identifier: "user", key: $0)})
        debug("計算所要時間: 検索", -start_2.timeIntervalSinceNow)

        let start_3 = Date()
        let dicdata: DicData = (indices + [("user", userDictIndices)]).flatMap{(identifier, value) -> DicData in
            let result: DicData = self.getDicData(identifier: identifier, indices: value).compactMap{(data: DicData.Element) in
                let penalty = string2penalty[data.ruby, default: .zero]
                if penalty.isZero{
                    return data
                }
                let ratio = Self.getTypoPenaltyRatio(data.lcid)
                let pUnit: PValue = self.getPenalty(data: data)/2   //負の値
                let adjust = pUnit * penalty * ratio
                if self.shouldBeRemoved(value: data.value() + adjust, wordCount: data.ruby.count){
                    return nil
                }
                return data.adjustedData(adjust)
            }
            return result
        }
        debug("計算所要時間: 辞書データの生成", -start_3.timeIntervalSinceNow)

        let start_4 = Date()
        if index == .zero{
            let result: [LatticeNode] = (dicdata + wisedicdata + memorydicdata).map{
                let node = LatticeNode(data: $0, romanString: segments[string2segment[$0.ruby, default: 0]])
                node.prevs.append(LatticeNode.RegisteredNode.BOSNode())
                //node.prevs.append(PreviousNodes(LatticeNode.PreviousNode.BOSNode))

                return node
            }
            debug("計算所要時間: ノードの生成", -start_4.timeIntervalSinceNow)
            debug("計算所要時間: 辞書検索全体", -start_0.timeIntervalSinceNow)
            return result

        }else{
            let result: [LatticeNode] = (dicdata + wisedicdata + memorydicdata).map{LatticeNode(data: $0, romanString: segments[string2segment[$0.ruby, default: .zero]])}
            debug("計算所要時間: ノードの生成", -start_4.timeIntervalSinceNow)
            debug("計算所要時間: 辞書検索全体", -start_0.timeIntervalSinceNow)
            return result
        }
    }

    ///kana2latticeから参照する。louds版。
    /// - Parameters:
    ///   - inputData: 入力データ
    ///   - to: 終点
    internal func getLOUDSData<T: InputDataProtocol, LatticeNode: LatticeNodeProtocol>(inputData: T, from fromIndex: Int, to toIndex: Int) -> [LatticeNode] {
        let segment = inputData[fromIndex...toIndex]
        let wisedicdata: DicData = self.getWiseDicData(head: segment, allowRomanLetter: toIndex == inputData.count - 1)
        let memorydicdata: DicData = self.getMatch(segment)

        let stringWithTypoData = inputData.getRangeWithTypos(fromIndex, toIndex)
        let string2penalty = [String: PValue].init(stringWithTypoData, uniquingKeysWith: {max($0, $1)})
        let group = [Character: [String]].init(grouping: stringWithTypoData.map{$0.string}, by: {$0.first!})

        //先頭の文字: そこで検索したい文字列の集合
        let indices: [(String, Set<Int>)] = group.map{dic in
            let key = String(dic.key)
            let set = Set(dic.value.flatMap{string in self.perfectMatchLOUDS(identifier: key, key: string)})
            return (key, set)
        }

        let userDictIndices = Set(stringWithTypoData.flatMap{self.perfectMatchLOUDS(identifier: "user", key: $0.string)})
        let dicdata: DicData = (indices + [("user", userDictIndices)]).flatMap{(identifier, value) -> DicData in
            let result: DicData = self.getDicData(identifier: identifier, indices: value).compactMap{(data: DicData.Element) in
                let penalty = string2penalty[data.ruby, default: .zero]
                if penalty.isZero{
                    return data
                }
                let ratio = Self.getTypoPenaltyRatio(data.lcid)
                let pUnit: PValue = self.getPenalty(data: data)/2   //負の値
                let adjust = pUnit * penalty * ratio
                if self.shouldBeRemoved(value: data.value() + adjust, wordCount: data.ruby.count){
                    return nil
                }
                return data.adjustedData(adjust)
            }
            return result
        }
        if fromIndex == .zero{
            let result: [LatticeNode] = (dicdata + wisedicdata + memorydicdata).map{
                let node = LatticeNode(data: $0, romanString: segment)
                node.prevs.append(LatticeNode.RegisteredNode.BOSNode())
                return node
            }
            return result
        }else{
            let result: [LatticeNode] = (dicdata + wisedicdata + memorydicdata).map{LatticeNode(data: $0, romanString: segment)}
            return result
        }
    }


    internal func getZeroHintPredictionDicData() -> DicData {
        if let dicdata = self.zeroHintPredictionDicData{
            return dicdata
        }
        do{
            let csvString = try String(contentsOfFile: Bundle.main.bundlePath + "/p_null.csv", encoding: String.Encoding.utf8)
            let csvLines = csvString.split(separator: "\n")
            let csvData = csvLines.map{$0.split(separator: ",", omittingEmptySubsequences: false)}
            let dicdata: DicData = csvData.map{convertDicData(from: $0)}
            self.zeroHintPredictionDicData = dicdata
            return dicdata
        } catch {
            debug(error)
            self.zeroHintPredictionDicData = []
            return []
        }
    }

    ///辞書から予測変換データを読み込む関数
    /// - Parameters:
    ///   - head: 辞書を引く文字列
    /// - Returns:
    ///   発見されたデータのリスト。
    internal func getPredictionLOUDSDicData<S: StringProtocol>(head: S) -> DicData {
        let count = head.count
        if count == .zero{
            return []
        }
        if count == 1{
            do {
                let csvString = try String(contentsOfFile: Bundle.main.bundlePath + "/p_\(head).csv", encoding: String.Encoding.utf8)
                let csvLines = csvString.split(separator: "\n")
                let csvData = csvLines.map{$0.split(separator: ",", omittingEmptySubsequences: false)}
                let dicdata: DicData = csvData.map{self.convertDicData(from: $0)}
                return dicdata
            } catch  {
                debug("ファイルが存在しません: \(error)")
                return []
            }
        }else if count == 2{
            let first = String(head.first!)
            //最大700件に絞ることによって低速化を回避する。
            //FIXME: 場当たり的な対処。改善が求められる。
            let prefixIndices = self.prefixMatchLOUDS(identifier: first, key: String(head), depth: 5).prefix(700)
            return self.getDicData(identifier: first, indices: Set(prefixIndices))
        }else{
            let first = String(head.first!)
            let prefixIndices = self.prefixMatchLOUDS(identifier: first, key: String(head)).prefix(700)
            return self.getDicData(identifier: first, indices: Set(prefixIndices))
        }
    }

    private func convertDicData(from dataString: [Substring]) -> DicDataElementProtocol {
        let LRE = dataString[3].isEmpty
        let SRE = dataString[1].isEmpty
        let V3E = dataString[5].isEmpty
        let ruby = String(dataString[0])
        let string = SRE ? ruby:String(dataString[1])
        let lcid = Int(dataString[2]) ?? .zero
        let rcid = Int(dataString[3]) ?? lcid
        let mid = Int(dataString[4]) ?? .zero
        let value: PValue = PValue(dataString[5]) ?? -30.0
        let adjust: PValue = PValue(self.getSingleMemory(All_DicDataElement(string: string, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: value)) * 3)
        //取得したデータを辞書に加える。
        let latticeNodeData: DicDataElementProtocol
        if LRE{
            if SRE{
                if V3E{
                    latticeNodeData = LRE_SRE_V3E_DicDataElement(ruby: ruby, cid: lcid, mid: mid, adjust: adjust)
                }else{
                    latticeNodeData = LRE_SRE_DicDataElement(ruby: ruby, cid: lcid, mid: mid, value: value, adjust: adjust)
                }
            }else{
                if V3E{
                    latticeNodeData = LRE_V3E_DicDataElement(string: string, ruby: ruby, cid: lcid, mid: mid, adjust: adjust)
                }else{
                    latticeNodeData = LRE_DicDataElement(word: string, ruby: ruby, cid: lcid, mid: mid, value: value, adjust: adjust)
                }
            }
        }else{
            if SRE{
                if V3E{
                    latticeNodeData = SRE_V3E_DicDataElement(ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, adjust: adjust)
                }else{
                    latticeNodeData = SRE_DicDataElement(ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: value, adjust: adjust)
                }
            }else{
                if V3E{
                    latticeNodeData = V3E_DicDataElement(string: string, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, adjust: adjust)
                }else{
                    latticeNodeData = All_DicDataElement(string: string, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: value, adjust: adjust)
                }
            }
        }
        return latticeNodeData
    }

    ///補足的な辞書情報を得る。
    private func getWiseDicData(head: String, allowRomanLetter: Bool) -> DicData {
        var result: DicData = []
        result.append(contentsOf: self.getJapaneseNumberDicData(head: head))
        if let number = Float(head){
            result.append(LRE_SRE_DicDataElement(ruby: head, cid: 1295, mid: 361, value: -14))
            if number.truncatingRemainder(dividingBy: 1) == 0{
                let int = Int(number)
                if int < Int(1E18) && -Int(1E18) < int, let kansuji = self.numberFormatter.string(from: NSNumber(value: int)){
                    result.append(LRE_DicDataElement(word: kansuji, ruby: head, cid: 1295, mid: 361, value: -16))
                }
            }
        }

        if Store.shared.keyboardModel.tabState == .abc && head.onlyRomanAlphabet{
            result.append(LRE_SRE_DicDataElement(ruby: head, cid: 1288, mid: 40, value: -14))
        }
        if Store.shared.keyboardModel.tabState != .abc && Store.shared.inputStyle == .roman{
            if let katakana = Roman2Kana.katakanaChanges[head], let hiragana = Roman2Kana.hiraganaChanges[head]{
                result.append(LRE_DicDataElement(word: hiragana, ruby: katakana, cid: 1288, mid: 501, value: -13))
                result.append(LRE_SRE_DicDataElement(ruby: katakana, cid: 1288, mid: 501, value: -14))
            }
        }

        if head.count == 1, let hira = head.applyingTransform(.hiraganaToKatakana, reverse: true), allowRomanLetter || !head.onlyRomanAlphabet{
            if head == hira{
                result.append(LRE_SRE_DicDataElement(ruby: head, cid: 1288, mid: 501, value: -14))
            }else{
                result.append(LRE_DicDataElement(word: hira, ruby: head, cid: 1288, mid: 501, value: -13))
                result.append(LRE_SRE_DicDataElement(ruby: head, cid: 1288, mid: 501, value: -14))
            }
        }
        return result
    }


    private func loadCCBinary(path: String) -> [(Int32, Float)] {
        do {
            let binaryData = try Data(contentsOf: URL(fileURLWithPath: path), options: [.uncached])
            let ui64array = binaryData.withUnsafeBytes{pointer -> [(Int32, Float)] in
                return Array(
                    UnsafeBufferPointer(
                        start: pointer.baseAddress!.assumingMemoryBound(to: (Int32, Float).self),
                        count: pointer.count / MemoryLayout<(Int32, Float)>.size
                    )
                )
            }
            return ui64array
        } catch {
            debug("Failed to read the file.")
            return []
        }
    }

    private func getMatch<S: StringProtocol>(_ ruby: S) -> DicData {
        return self.memory.match(ruby)
    }

    internal func getSingleMemory(_ data: DicDataElementProtocol) -> Int {
        return self.memory.getSingle(data)
    }

    internal func getPrefixMemory<S: StringProtocol>(_ prefix: S) -> DicData {
        return self.memory.getPrefixDicData(prefix)
    }

    internal func getMatch(_ previous: DicDataElementProtocol, next: DicDataElementProtocol) -> Int {
        return self.memory.matchNext(previous, next: next)
    }

    internal func getNextMemory(_ data: DicDataElementProtocol) -> [(next: DicDataElementProtocol, count: Int)] {
        return self.memory.getNextData(data)
    }

    //学習を反映する
    internal func updateLearningData(_ candidate: Candidate, with previous: DicDataElementProtocol?){
        self.memory.update(candidate.data, lastData: previous)
    }
    ///class idから連接確率を得る関数
    /// - Parameters:
    ///   - former: 左側の語のid
    ///   - latter: 右側の語のid
    /// - Returns:
    ///   連接確率の対数。
    /// - 要求があった場合ごとにファイルを読み込んで
    internal func getCCValue(_ former: Int, _ latter: Int) -> PValue {
        if ccParsed.contains(former){
            let defaultValue = ccLines[former][-1, default: -25]
            return ccLines[former][latter, default: defaultValue]
        }
        let add: PValue = 3
        let path = Bundle.main.bundlePath + "/\(former).binary"
        let values = loadCCBinary(path: path)
        ccLines[former] = [Int: PValue].init(uniqueKeysWithValues: values.map{(Int($0.0), PValue($0.1) + add)})
        ccParsed.update(with: former)
        return ccLines[former][latter, default: -25]
    }

    ///meaning idから意味連接尤度を得る関数
    /// - Parameters:
    ///   - former: 左側の語のid
    ///   - latter: 右側の語のid
    /// - Returns:
    ///   意味連接確率の対数。
    /// - 要求があった場合ごとに確率値をパースして取得する。
    internal func getMMValue(_ former: Int, _ latter: Int) -> PValue {
        if former == 500 || latter == 500{
            return 0
        }
        return self.mmValue[former * self.midCount + latter]
    }

    //誤り訂正候補の構築の際、ファイルが存在しているか事前にチェックし、存在していなければ以後の計算を打ち切ることで、計算を減らす。
    internal static func existFile<S: StringProtocol>(identifier: S) -> Bool {
        let fileName = identifier.prefix(1)
        let path = Bundle.main.bundlePath + "/" + fileName + ".louds"
        return FileManager.default.fileExists(atPath: path)
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
    ///class idから、文節かどうかを判断する関数。
    /// - Parameters:
    ///   - c_former: 左側の語のid
    ///   - c_latter: 右側の語のid
    /// - Returns:
    ///   そこが文節であるかどうか。
    internal static func isClause(_ former: Int, _ latter: Int) -> Bool {
        //EOSが基本多いので、この順の方がヒット率が上がると思われる。
        let latter_wordtype = Self.judgeWordType(cid: latter)
        if latter_wordtype == 3{
            return false
        }
        let former_wordtype = Self.judgeWordType(cid: former)
        if former_wordtype == 3  {
            return false
        }
        if latter_wordtype == 0{
            return former_wordtype != 0
        }
        if latter_wordtype == 1{
            return former_wordtype != 0
        }
        return false
    }
    
    private static let BOS_EOS_wordIDs: Set<Int> = [0,1316]
    private static let PREPOSITION_wordIDs: Set<Int> = [1315, 6, 557, 558, 559, 560]
    private static let INPOSITION_wordIDs: Set<Int> = Set<Int>((561..<868).map{$0}
                                            + (1283..<1297).map{$0}
                                            + (1306..<1310).map{$0}
                                            + (11..<53).map{$0}
                                            + (555..<557).map{$0}
                                            + (1281..<1283).map{$0}
                                            ).union([1314, 3, 2, 4, 5, 1, 9])
    /*
    private static let POSTPOSITION_wordIDs: Set<Int> = Set<Int>((7...8).map{$0}
                                            + (54..<555).map{$0}
                                            + (868..<1281).map{$0}
                                            + (1297..<1306).map{$0}
                                            + (1310..<1314).map{$0}
                                            ).union([10])
     */
    internal static func includeMMValueCalculation(_ data: DicDataElementProtocol) -> Bool {
        //LREでない場合はfalseを返す。
        if     data is SRE_DicDataElement
                || data is SRE_V3E_DicDataElement
                || data is V3E_DicDataElement
                || data is BOSEOSDicDataElement
                || data is All_DicDataElement
        {
            return false
        }
        //非自立動詞
        if 895...1280 ~= data.lcid{
            return true
        }
        //非自立名刺
        if 1297...1305 ~= data.lcid{
            return true
        }
        //内容語かどうか
        return Self.INPOSITION_wordIDs.contains(data.lcid)
    }

    internal static func getTypoPenaltyRatio(_ lcid: Int) -> PValue {
        //助詞147...368, 助動詞369...554
        if 147...554 ~= lcid{
            return 2.5
        }
        return 1
    }


    //カウントをゼロにすべき語の種類
    internal static func needWValueMemory(_ data: DicDataElementProtocol) -> Bool {
        //助詞、助動詞
        if 147...554 ~= data.lcid{
            return false
        }
        //接頭辞
        if 557...560 ~= data.lcid{
            return false
        }
        //接尾名詞を除去
        if 1297...1305 ~= data.lcid{
            return false
        }
        //記号を除去
        if 6...9 ~= data.lcid{
            return false
        }
        if 0 == data.lcid || 1316 == data.lcid{
            return false
        }

        return true
    }

    ///
    /// - Returns:
    ///   - 3 when BOS/EOS
    ///   - 0 when preposition
    ///   - 1 when core
    ///   - 2 when postposition
    internal static func judgeWordType(cid: Int) -> Int {
        if Self.BOS_EOS_wordIDs.contains(cid){
            return 3    //BOS/EOS
        }
        if Self.PREPOSITION_wordIDs.contains(cid){
            return 0    //前置
        }
        if Self.INPOSITION_wordIDs.contains(cid) {
            return 1 //内容
        }
        return 2   //後置
    }


    internal static let possibleNexts: [String: [String]] = [
            "x":["ァ","ィ","ゥ","ェ","ォ","ッ","ャ","ュ","ョ","ヮ"],
            "l":["ァ","ィ","ゥ","ェ","ォ","ッ","ャ","ュ","ョ","ヮ"],
            "xt":["ッ"],
            "lt":["ッ"],
            "xts":["ッ"],
            "lts":["ッ"],
            "xy":["ャ","ュ","ョ"],
            "ly":["ャ","ュ","ョ"],
            "xw":["ヮ"],
            "lw":["ヮ"],
            "v":["ヴ"],
            "k":["カ","キ","ク","ケ","コ"],
            "q":["クァ","クィ","クゥ","クェ","クォ"],
            "qy":["クャ","クィ","クュ","クェ","クョ"],
            "qw":["クヮ","クィ","クゥ","クェ","クォ"],
            "ky":["キャ","キィ","キュ","キェ","キョ"],
            "g":["ガ","ギ","グ","ゲ","ゴ"],
            "gy":["ギャ","ギィ","ギュ","ギェ","ギョ"],
            "s":["サ","シ","ス","セ","ソ"],
            "sy":["シャ","シィ","シュ","シェ","ショ"],
            "sh":["シャ","シィ","シュ","シェ","ショ"],
            "z":["ザ","ジ","ズ","ゼ","ゾ"],
            "zy":["ジャ","ジィ","ジュ","ジェ","ジョ"],
            "j":["ジ"],
            "t":["タ","チ","ツ","テ","ト"],
            "ty":["チャ","チィ","チュ","チェ","チョ"],
            "ts":["ツ"],
            "th":["テャ","ティ","テュ","テェ","テョ"],
            "tw":["トァ","トィ","トゥ","トェ","トォ"],
            "cy":["チャ","チィ","チュ","チェ","チョ"],
            "ch":["チ"],
            "d":["ダ","ヂ","ヅ","デ","ド"],
            "dy":["ヂ"],
            "dh":["デャ","ディ","デュ","デェ","デョ"],
            "dw":["ドァ","ドィ","ドゥ","ドェ","ドォ"],
            "n":["ナ","ニ","ヌ","ネ","ノ","ン"],
            "ny":["ニャ","ニィ","ニュ","ニェ","ニョ"],
            "h":["ハ","ヒ","フ","ヘ","ホ"],
            "hy":["ヒャ","ヒィ","ヒュ","ヒェ","ヒョ"],
            "hw":["ファ","フィ","フェ","フォ"],
            "f":["フ"],
            "b":["バ","ビ","ブ","ベ","ボ"],
            "by":["ビャ","ビィ","ビュ","ビェ","ビョ"],
            "p":["パ","ピ","プ","ペ","ポ"],
            "py":["ピャ","ピィ","ピュ","ピェ","ピョ"],
            "m":["マ","ミ","ム","メ","モ"],
            "my":["ミャ","ミィ","ミュ","ミェ","ミョ"],
            "y":["ヤ","ユ","イェ","ヨ"],
            "r":["ラ","リ","ル","レ","ロ"],
            "ry":["リャ","リィ","リュ","リェ","リョ"],
            "w":["ワ","ウィ","ウェ","ヲ"],
            "wy":["ヰ","ヱ"],
        ]
}
