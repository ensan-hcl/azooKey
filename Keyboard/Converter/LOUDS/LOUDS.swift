//
//  LOUDS.swift
//  Keyboard
//
//  Created by ensan on 2020/09/30.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

private extension UInt64 {
    static let prefixOne: UInt64 = 1 << 63
}

/// LOUDS
struct LOUDS {
    private typealias Unit = UInt64
    private static let unit = 64
    private static let uExp = 6

    private let bits: [Unit]
    private let indices: Range<Int>
    private let char2nodeIndices: [[Int]]
    /// 0の数（1の数ではない）
    private let rankLarge: [Int]

    init(bytes: [UInt64], nodeIndex2ID: [UInt8]) {
        self.bits = bytes
        self.char2nodeIndices = nodeIndex2ID.enumerated().reduce(into: .init(repeating: [], count: 1 << 8)) { list, data in
            list[Int(data.element)].append(data.offset)
        }
        self.indices = self.bits.indices
        self.rankLarge = bytes.reduce(into: [0]) {
            $0.append(($0.last ?? 0) &+ (Self.unit &- $1.nonzeroBitCount))
        }
    }

    /// parentNodeIndex個の0を探索し、その次から1個増えるまでのIndexを返す。
    private func childNodeIndices(from parentNodeIndex: Int) -> Range<Int> {
        // 求めるのは、
        // startIndex == 自身の左側にparentNodeIndex個の0があるような最小のindex
        // endIndex == 自身の左側にparentNodeIndex+1個の0があるような最小のindex
        // すなわち、childNodeIndicesである。
        // まずstartIndexを発見し、そこから0が現れる点を探すことでendIndexを見つける方針で実装している。

        // 探索パート①
        // rankLargeは左側の0の数を示すので、difを取っている
        // まず最低限の絞り込みを行う。leftを探索する。
        // 探しているのは、startIndexが含まれるbitsのindex `i`
        var left = (parentNodeIndex >> Self.uExp) &- 1
        while true {
            let dif = parentNodeIndex &- self.rankLarge[left &+ 1]
            if dif >= Self.unit {
                left &+= dif >> Self.uExp
            } else {
                break
            }
        }
        guard let i = (left &+ 1 ..< self.bits.count).first(where: {(index: Int) in self.rankLarge[index &+ 1] >= parentNodeIndex}) else {
            return 0 ..< 0
        }

        return self.bits.withUnsafeBufferPointer {(buffer: UnsafeBufferPointer<Unit>) -> Range<Int> in
            // 探索パート②
            // 目標は`k`の発見
            // 今のbyteの中を探索し、超過分(dif)の0を手に入れたところでkが確定する。
            let byte = buffer[i]
            let dif = self.rankLarge[i &+ 1] &- parentNodeIndex   // 0の数の超過分
            var count = Unit(Self.unit &- byte.nonzeroBitCount) // 0の数
            var k = Self.unit

            for c in 0 ..< Self.unit {
                if count == dif {
                    k = c
                    break
                }
                // byteの上からc桁めが0なら == (byte << 0)が100………00より小さければ == 最初の1桁を一番下に持ってきた値そのもの
                count &-= (byte << c) < Unit.prefixOne ? 1:0
            }

            let start = (i << Self.uExp) &+ k &- parentNodeIndex &+ 1
            if dif == .zero {
                var j = i &+ 1
                while buffer[j] == Unit.max {
                    j &+= 1
                }
                let byte2 = buffer[j]
                // 最初の0を探す作業
                let a = (0 ..< Self.unit).first(where: {(byte2 << $0) < Unit.prefixOne})
                return start ..< (j << Self.uExp) &+ (a ?? 0) &- parentNodeIndex &+ 1
            } else {
                // 次の0を探す作業
                let a = (k ..< Self.unit).first(where: {(byte << $0) < Unit.prefixOne})
                return start ..< (i << Self.uExp) &+ (a ?? 0) &- parentNodeIndex &+ 1
            }
        }
    }

    /// charIndexを取得する
    /// `childNodeIndices`と差し引きして、二分探索部分の速度への影響は高々0.02秒ほど
    private func searchCharNodeIndex(from parentNodeIndex: Int, char: UInt8) -> Int? {
        // char2nodeIndicesには単調増加性があるので二分探索が成立する
        let childNodeIndices = self.childNodeIndices(from: parentNodeIndex)
        let nodeIndices = self.char2nodeIndices[Int(char)]
        var left = nodeIndices.startIndex
        var right = nodeIndices.endIndex
        while left < right {
            let mid = (left + right) >> 1
            if childNodeIndices.startIndex <= nodeIndices[mid] {
                right = mid
            } else {
                left = mid + 1
            }
        }
        if left < nodeIndices.endIndex && childNodeIndices.contains(nodeIndices[left]) {
            return nodeIndices[left]
        } else {
            return nil
        }
    }

    internal func searchNodeIndex(chars: [UInt8]) -> Int? {
        var index = 1
        for char in chars {
            if let nodeIndex = self.searchCharNodeIndex(from: index, char: char) {
                index = nodeIndex
            } else {
                return nil
            }
        }
        return index
    }

    private func prefixNodeIndices(nodeIndex: Int, depth: Int = 0, maxDepth: Int) -> [Int] {
        var childNodeIndices = Array(self.childNodeIndices(from: nodeIndex))
        if depth == maxDepth {
            return childNodeIndices
        }
        for index in childNodeIndices {
            childNodeIndices.append(contentsOf: self.prefixNodeIndices(nodeIndex: index, depth: depth + 1, maxDepth: maxDepth))
        }
        return childNodeIndices
    }

    internal func prefixNodeIndices(chars: [UInt8], maxDepth: Int) -> [Int] {
        guard let nodeIndex = self.searchNodeIndex(chars: chars) else {
            return []
        }
        return self.prefixNodeIndices(nodeIndex: nodeIndex, maxDepth: maxDepth)
    }

    /// charsの前方に一致するエントリのindexを全て集める
    /// 例えばcharsが「しんせいしゃ」だったら「し」や「しん」や「しんせ」に対応するエントリのindexも含む
    /// 以前はreduceで実装していたが、速度的に変わらないので読みやすさのためにforとfirstで書き換えた
    internal func byfixNodeIndices(chars: [UInt8]) -> [Int] {
        var indices = [1]
        for char in chars {
            if let nodeIndex = self.searchCharNodeIndex(from: indices.last!, char: char) {
                indices.append(nodeIndex)
            } else {
                break
            }
        }
        return indices
    }
}
