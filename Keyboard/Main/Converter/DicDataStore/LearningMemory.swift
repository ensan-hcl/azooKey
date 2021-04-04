//
//  LearningMemory.swift
//  Keyboard
//
//  Created by β α on 2021/02/01.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

private struct DicDataElementCore: Hashable {
    internal init(data: DicdataElement) {
        self.word = data.word
        self.ruby = data.ruby
        self.lcid = data.lcid
        self.rcid = data.rcid
    }

    let word: String
    let ruby: String
    let lcid: Int
    let rcid: Int
}

private final class LearningMemoryElement {
    var data: DicdataElement
    var count: Int
    var next: [(index: Int, count: Int)]
    init(data: DicdataElement, count: Int, next: [(index: Int, count: Int)] = []) {
        self.data = data
        self.count = count
        self.next = next
    }
}

struct LearningMemorys {
    static let memoryCount = 100
    static let memoryFileName = "learningMemory"
    private var values: [LearningMemoryElement]
    private var index2order: [Int]  // index→values内の位置
    private var core2Index: [DicDataElementCore: Int]

    private func getMinOrderIndex() -> Int? {
        let pair = self.index2order.enumerated().min(by: {$0.element < $1.element})
        return pair?.offset
    }

    private static func matchAdjust(memory: LearningMemoryElement) -> PValue {
        let matchCount = PValue(memory.count)
        let rubyCount = PValue(memory.data.ruby.count)
        return matchCount * (4 - 3.5 / rubyCount)
    }

    private mutating func updateOrder(at index: Int) {
        let order = self.index2order[index]
        if order == self.index2order.endIndex - 1 {
            return
        }
        self.index2order = self.index2order.map {
            if $0 < order {
                return $0
            } else if $0 == order {
                return self.index2order.endIndex - 1
            } else {
                return $0 - 1
            }
        }
    }

    func match<S: StringProtocol>(_ ruby: S) -> DicDataStore.DicData {
        let dicdata = self.values.lazy.filter {$0.data.ruby == ruby}.map {$0.data.adjustedData(Self.matchAdjust(memory: $0))}
        return Array(dicdata)
    }

    func getSingle(_ data: DicdataElement) -> Int {
        if let index = self.core2Index[.init(data: data)] {
            return values[index].count
        }
        return .zero
    }

    func getPrefixDicData<S: StringProtocol>(_ prefix: S) -> DicDataStore.DicData {
        let dicdata = self.values.lazy.filter {$0.data.ruby != prefix && $0.data.ruby.hasPrefix(prefix)}.map {$0.data.adjustedData(Self.matchAdjust(memory: $0))}
        return Array(dicdata)
    }

    func getNextData(_ data: DicdataElement) -> [(next: DicdataElement, count: Int)] {
        if let index = self.core2Index[.init(data: data)] {
            return values[index].next.map {(next: self.values[$0.index].data, count: $0.count)}
        }
        return []
    }

    func matchNext(_ previous: DicdataElement, next: DicdataElement) -> Int {
        if let nextIndex = self.core2Index[.init(data: next)],
           let previousIndex = self.core2Index[.init(data: previous)],
           let next = values[previousIndex].next.last(where: {$0.index == nextIndex}) {
            return next.count
        }
        return .zero
    }

    mutating func update(_ data: [DicdataElement], lastData: DicdataElement?) {
        if !SettingData.shared.learningType.needUpdateMemory {
            return
        }

        let datalist = ((lastData == nil) ? [] : [lastData!]) + data

        var lastIndex: Int?
        // elementは参照型であることに留意
        datalist.indices.forEach {i in
            let _lastIndex = lastIndex
            if i != .zero || lastData == nil {
                let needMemoryCount = DicDataStore.needWValueMemory(datalist[i])
                let countDelta = needMemoryCount ? 1:0
                // すでにデータが存在している場合
                if let index = core2Index[.init(data: datalist[i])] {
                    self.updateOrder(at: index)
                    lastIndex = index
                    self.values[index].count += countDelta
                } else {
                    // 最大数に満たない場合
                    if self.values.count < Self.memoryCount {
                        lastIndex = self.values.endIndex
                        let data = datalist[i]
                        self.values.append(LearningMemoryElement(data: data, count: countDelta))
                        self.index2order.append(self.index2order.count)
                        self.core2Index[.init(data: data)] = self.index2order.count - 1
                        // 最大数になっている場合、最も古いデータを更新する
                    } else if let minIndex = self.getMinOrderIndex() {
                        self.values.forEach {
                            $0.next = $0.next.lazy.filter {$0.index != minIndex}
                        }
                        let data = datalist[i]
                        let oldData = values[minIndex].data
                        self.core2Index.removeValue(forKey: .init(data: oldData))
                        self.values[minIndex] = LearningMemoryElement(data: data, count: countDelta)
                        self.core2Index[.init(data: data)] = minIndex
                        self.updateOrder(at: minIndex)
                        lastIndex = minIndex
                    }
                }
            }

            guard let prevIndex = _lastIndex,
                  let nextIndex = lastIndex else {
                return
            }

            let prev = self.values[prevIndex]
            if let index = prev.next.firstIndex(where: {$0.index == nextIndex}) {
                prev.next[index].count += 1
            } else {
                prev.next.append((index: nextIndex, count: 1))
            }
        }
    }

    mutating func notifyChangeLearningType(_ type: LearningType) {
        switch type {
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

    func save(force: Bool = false) {
        if !force && !SettingData.shared.learningType.needUpdateMemory {
            return
        }
        let string: String = self.values.map {
            let nextString = $0.next.map {"\($0.index),\($0.count)"}.joined(separator: "\0")
            return "\($0.count)\t\($0.data.ruby.escaped())\t\($0.data.word.escaped())\t\($0.data.lcid)\t\($0.data.rcid)\t\($0.data.mid)\t\($0.data.baseValue)\t\(nextString)"
        }.joined(separator: "\n")
        FileTools.saveTextFile(contents: string, to: Self.memoryFileName)
    }

    mutating func reset() {
        self.values = []
        self.index2order = []
        self.core2Index = [:]
        self.save(force: true)
    }

    init() {
        if SettingData.checkResetSetting() {
            // リセットする。
            self.values = []
            self.index2order = []
            self.core2Index = [:]
            self.save(force: true)
        }

        if !SettingData.shared.learningType.needUsingMemory {
            self.values = []
            self.index2order = []
            self.core2Index = [:]
            return
        }
        let values = Self.load()
        self.values = values
        self.values.reserveCapacity(Self.memoryCount + 1)
        self.index2order = Array(values.indices)
        self.core2Index = values.indices.reduce(into: [:]) {dictionary, i in
            dictionary[.init(data: values[i].data)] = i
        }
    }

    private static func load() -> [LearningMemoryElement] {
        let contents = FileTools.readTextFile(to: Self.memoryFileName)
        if contents.isEmpty {
            return []
        }

        let values: [LearningMemoryElement] = contents.split(separator: "\n").compactMap {(line: String.SubSequence) in
            let splited: [String.SubSequence] = line.split(separator: "\t", omittingEmptySubsequences: false)
            if splited.count < 7 {
                return nil
            }
            let count: Int = Int(splited[0]) ?? 1
            let data: DicdataElement = Self.convertLatticeNodeData(from: splited[1...6])
            if splited[7].isEmpty {
                return LearningMemoryElement(data: data, count: count, next: [])
            }
            let next: [(index: Int, count: Int)] = splited[7].split(separator: "\0").map {
                let tuple = $0.split(separator: ",")
                return (index: Int(tuple[0])!, count: Int(tuple[1])!)
            }
            return LearningMemoryElement(data: data, count: count, next: next)
        }
        return values
    }

    private static func convertLatticeNodeData(from dataString: ArraySlice<String.SubSequence>) -> DicdataElement {
        let delta = dataString.startIndex
        let SRE = dataString[1+delta].isEmpty
        let ruby = String(dataString[0+delta]).unescaped()
        let word = SRE ? ruby:String(dataString[1+delta]).unescaped()
        let lcid = Int(dataString[2+delta]) ?? .zero
        let rcid = Int(dataString[3+delta]) ?? lcid
        let mid = Int(dataString[4+delta]) ?? .zero
        let value: PValue = PValue(dataString[5+delta]) ?? -30.0
        return DicdataElement(word: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: value, adjust: .zero)
    }

}
