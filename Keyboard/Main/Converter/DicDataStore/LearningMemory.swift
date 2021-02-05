//
//  LearningMemory.swift
//  Keyboard
//
//  Created by β α on 2021/02/01.
//  Copyright © 2021 DevEn3. All rights reserved.
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

struct LearningMemorys{
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
        if !SettingData.shared.learningType.needUpdateMemory{
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
        if !force && !SettingData.shared.learningType.needUpdateMemory{
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
        if SettingData.checkResetSetting(){
            //リセットする。
            self.values = []
            self.index2order = []
            self.save(force: true)
        }

        if !SettingData.shared.learningType.needUsingMemory{
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
