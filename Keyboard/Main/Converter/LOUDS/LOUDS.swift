//
//  LOUDS.swift
//  Keyboard
//
//  Created by β α on 2020/09/30.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

/// LOUDS
struct LOUDS{
    typealias Unit = UInt64
    private static let unit = 64
    private static let uExp = 6

    private let bits: [Unit]
    private let indices: Range<Int>
    private let nodeIndex2ID: [UInt8]
    private let rankLarge: [Int]

    init(bytes: [Unit], nodeIndex2ID: [UInt8]){
        self.bits = bytes
        self.nodeIndex2ID = nodeIndex2ID
        self.indices = self.bits.indices
        self.rankLarge = bytes.reduce(into: [0]){
            $0.append(($0.last ?? 0) &+ (Self.unit &- $1.nonzeroBitCount))
        }
    }

    private func childNodeIndices(from parentNodeIndex: Int) -> Range<Int> {
        var left = -1
        while true{
            let dif = parentNodeIndex &- self.rankLarge[left &+ 1]
            if dif >= Self.unit{
                left &+= dif >> Self.uExp
            }else{
                break
            }
        }
        guard let i = (left &+ 1 ..< self.bits.count).first(where: {(index: Int) in self.rankLarge[index &+ 1] >= parentNodeIndex}) else{
            return 0..<0
        }

        return self.bits.withUnsafeBufferPointer{(buffer: UnsafeBufferPointer<Unit>) -> Range<Int> in
            let byte = buffer[i]
            let dif = self.rankLarge[i &+ 1] &- parentNodeIndex   //0の数の超過分
            var count = Unit(Self.unit &- byte.nonzeroBitCount) //0の数
            var k = Self.unit

            for c in 0..<Self.unit{
                if count == dif{
                    k = c
                    break
                }
                //byteの上からc桁めが0なら == (byte << 0)が100………00より小さければ == 最初の1桁を一番下に持ってきた値そのもの
                count &-= (byte << c) < Unit.prefixOne ? 1:0
            }

            let start = (i << Self.uExp) &+ k &- parentNodeIndex &+ 1
            if dif == .zero{
                var j = i &+ 1
                while buffer[j] == Unit.max{
                    j &+= 1
                }
                let byte2 = buffer[j]
                //最初の0を探す作業
                let a = (0..<Self.unit).first(where: {(byte2 << $0) < Unit.prefixOne})
                return start ..< (j << Self.uExp) &+ (a ?? 0) &- parentNodeIndex &+ 1
            }else{
                //次の0を探す作業
                let a = (k..<Self.unit).first(where: {(byte << $0) < Unit.prefixOne})
                return start ..< (i << Self.uExp) &+ (a ?? 0) &- parentNodeIndex &+ 1
            }
        }
    }

    internal func searchNodeIndex(chars: [UInt8]) -> Int? {
        var findFlag = true
        let index = chars.reduce(1){prev, char in
            if findFlag{
                //ここはfirstで書かない方が速度が上がった
                let childrenNodeIndices = self.childNodeIndices(from: prev)
                for nodeIndex in childrenNodeIndices where self.nodeIndex2ID[nodeIndex] == char{
                    return nodeIndex
                }
                findFlag = false
            }
            return prev
        }
        return findFlag ? index:nil
    }

    private func prefixNodeIndices(nodeIndex: Int, depth: Int = 0, maxDepth: Int) -> [Int] {
        let childNodeIndices = self.childNodeIndices(from: nodeIndex)
        if depth == maxDepth{
            return Array(childNodeIndices)
        }
        return childNodeIndices + childNodeIndices.flatMap{self.prefixNodeIndices(nodeIndex: $0, depth: depth+1, maxDepth: maxDepth)}
    }

    internal func prefixNodeIndices(chars: [UInt8], maxDepth: Int) -> [Int] {
        guard let nodeIndex = self.searchNodeIndex(chars: chars) else{
            return []
        }
        return self.prefixNodeIndices(nodeIndex: nodeIndex, maxDepth: maxDepth)
    }

    internal func byfixNodeIndices(chars: [UInt8]) -> [Int] {
        var findFlag = true
        return chars.reduce(into: [1]){prev, char in
            if findFlag{
                //ここはfirstで書かない方が速度が上がった
                let childrenNodeIndices = self.childNodeIndices(from: prev.last!)
                for nodeIndex in childrenNodeIndices where self.nodeIndex2ID[nodeIndex] == char{
                    return prev.append(nodeIndex)
                }
                findFlag = false
            }
        }
    }
}

