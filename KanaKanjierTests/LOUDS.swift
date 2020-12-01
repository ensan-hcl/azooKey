//
//  LOUDS.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/09/24.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

extension String{
    func line(_ index: Int) -> String{
        var iterator = self.makeIterator()
        var count = 0
        var result = ""
        while let char = iterator.next(){
            let isDeliminator = char.isNewline
            if count == index && !isDeliminator{
                result += String(char)
            }
            if count > index{
                break
            }
            if isDeliminator{
                count += 1
            }
        }
        return result
    }
    
    func lines(_ indices: [Int]) -> [String]{
        var indicesIterator = indices.sorted().makeIterator()
        var iterator = self.makeIterator()
        var count = 0
        var results:[String] = []
        var result = ""
        guard var targetIndex = indicesIterator.next() else{
            return []
        }
        
        while let char = iterator.next(){
            let isDeliminator = char.isNewline
            if count == targetIndex && !isDeliminator{
                result += String(char)
            }
            
            if count > targetIndex{
                results.append(result)
                result = ""
                if let _targetIndex = indicesIterator.next(){
                    targetIndex = _targetIndex
                    if count == targetIndex{
                        result = String(char)
                    }
                }else{
                    break
                }
            }
            
            if isDeliminator{
                count += 1
            }
        }
        return results
    }

}


protocol LOUDSUnit: UnsignedInteger, FixedWidthInteger{
    var popCount: Int {get}
    static var prefixOne: Self {get}
    var binaryString: String {get}
}
extension LOUDSUnit{
    var binaryString: String{
        return String(self, radix: 2)
    }
}

extension UInt8: LOUDSUnit{
    static let prefixOne: UInt8 = 0b10000000
    var popCount: Int {
        return self.nonzeroBitCount
        var x = self
        // 2bitごとの組に分け、立っているビット数を2bitで表現する
        x &-= ((x >> 1) & 0x55)
        // 4bit整数に 上位2bit + 下位2bit を計算した値を入れる
        x = (x & 0x33) &+ ((x >> 2) & 0x33)
        x = (x &+ (x >> 4)) & 0x0f // 8bitごと
        return Int(x & 0x7f)
    }
}

extension UInt16: LOUDSUnit{
    static let prefixOne: UInt16 = 0b1000000000000000

    var popCount: Int {
        return self.nonzeroBitCount
        var cnt = 0
        var bits = self
        while bits != 0{
            cnt &+= Int(bits & 1)
            bits = bits >> 1
        }
        return cnt
    }
}

extension UInt64:LOUDSUnit{
    var popCount: Int {
        return self.nonzeroBitCount
        var x = self
        // 2bitごとの組に分け、立っているビット数を2bitで表現する
        x &-= ((x >> 1) & 0x5555555555555555)

        // 4bit整数に 上位2bit + 下位2bit を計算した値を入れる
        x = (x & 0x3333333333333333) &+ ((x >> 2) & 0x3333333333333333)

        x = (x &+ (x >> 4)) & 0x0f0f0f0f0f0f0f0f // 8bitごと
        x &+= (x >> 8) // 16bitごと
        x &+= (x >> 16) // 32bitごと
        x &+= (x >> 32) // 64bitごと = 全部の合計
        return Int(x & 0x0000007f)
    }
    
    static let prefixOne: UInt64 = 0b1000000000000000000000000000000000000000000000000000000000000000
    
    var uint8Array: [UInt8] {
        var bigEndian:UInt64 = self.bigEndian
        let count = MemoryLayout<UInt64>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return Array(bytePtr)
    }
    
    func uint8Array(_ index: Int) -> UInt8 {
        var bigEndian:UInt64 = self.bigEndian
        let count = MemoryLayout<UInt64>.size
        return withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)[index]
            }
        }
    }

    var uint8Array2:[UInt8]{
        var x = self.bigEndian
        let data = Data(bytes:&x, count: 8)
        return Array(data)
    }


}

extension Array where Element == Bool{
    var BoolToUInt8: [UInt8]{
        let unit = 8
        let value = self.count.quotientAndRemainder(dividingBy: unit)
        var _bools = self
        if value.remainder != 0{
            _bools += [Bool].init(repeating: true, count: 8-value.remainder)
        }
        
        var result = [UInt8].init()
        for i in 0...value.quotient{
            let b0 = _bools[i*unit+0], b1 = _bools[i*unit+1], b2 = _bools[i*unit+2], b3 = _bools[i*unit+3], b4 = _bools[i*unit+4], b5 = _bools[i*unit+5], b6 = _bools[i*unit+6], b7 = _bools[i*unit+7]
            let int:UInt8 = (b0 ? 128:0) + (b1 ? 64:0) + (b2 ? 32:0) + (b3 ? 16:0) + (b4 ? 8:0) + (b5 ? 4:0) + (b6 ? 2:0) + (b7 ? 1:0)
            result.append(int)
        }
        return result
    }
}

extension Array where Element == UInt8{
    var UInt8toUInt64: [UInt64]{
        let value = self.count.quotientAndRemainder(dividingBy: 8)
        var _uint8 = self
        if value.remainder != 0{
            _uint8 += [UInt8].init(repeating: UInt8.max, count: 8-value.remainder)
        }
        var result = [UInt64].init()
        for i in 0...value.quotient{
            let string = _uint8[i*8..<(i+1)*8].map{String(format: "%02X", $0)}.joined()
            let uint64 = UInt64(string, radix: 16)!
            result.append(uint64)
        }
        return result
    }
}

struct LOUDSTrie{
    let bits: [Bool]
    let indices: [Int]
    let nodeIndex2Character: [Character]
    init(bits: [Bool], nodeIndex2Character: [Character]){
        self.bits = bits
        self.nodeIndex2Character = nodeIndex2Character
        self.indices = Array(self.bits.indices)
    }
    
    func index(from nodeIndex:Int)->Int{
        var total = 0
        for i in self.indices{
            if self.bits[i]{
                total += 1
            }
            if total == nodeIndex{
                return i
            }
        }
        return -1
    }
    func nodeIndex(from index:Int)->Int{
        var total = 0
        for i in 0...index{
            if self.bits[i]{
                total += 1
            }
        }
        return total
    }
    func parentNodeIndex(from childIndex:Int)->Int{
        var total = 0
        for i in 0...childIndex{
            if !self.bits[i]{
                total += 1
            }
        }
        return total
    }
    
    func childIndices(from parentNodeIndex: Int) -> [Int] {
        var total = 0
        for i in self.indices{
            if !self.bits[i]{
                total += 1
            }
            
            if total == parentNodeIndex{
                var j = i+1
                while self.bits[j]{
                    j += 1
                }
                return Array(i+1..<j)
            }
        }
        return []
    }
    
    func searchNodeIndex(chars: [Character]) -> Int? {
        var currentNodeIndex = 1
        var findFlag = true
        chars.forEach{char in
            if findFlag{
                let childrenIndices = self.childIndices(from: currentNodeIndex)    //1番ノードの子ノードのindex
                for index in childrenIndices{
                    let nodeIndex = self.nodeIndex(from: index)
                    if self.nodeIndex2Character[nodeIndex] == char{
                        currentNodeIndex = nodeIndex
                        return
                    }
                }
                findFlag = false
            }
        }
        if findFlag{
            return currentNodeIndex
        }else{
            return nil
        }
    }
    
    func prefixNodeIndices(nodeIndex: Int) -> [Int]{
        let children = self.childIndices(from: nodeIndex)
        let childNodeIndices = children.map{self.nodeIndex(from: $0)}
        return childNodeIndices + childNodeIndices.flatMap{self.prefixNodeIndices(nodeIndex: $0)}
    }
    
    func prefixNodeIndices(chars: [Character]) -> [Int]{
        guard let nodeIndex = self.searchNodeIndex(chars: chars) else{
            return []
        }
        return self.prefixNodeIndices(nodeIndex: nodeIndex)
    }

}


struct FastLOUDSUIntTrie{
    typealias Unit = UInt64
    static let unit = 64
    static let uExp = 6

    let bits: [Unit]
    let indices: Range<Int>
    let nodeIndex2Character: [Character]
    let pbits: UnsafePointer<Unit>
    let rankLarge: [Int]
    let rankLarge0: [Int]

    let rankSmall: [[UInt8]]

    init(bytes: [Unit], nodeIndex2Character: [Character]){
        self.bits = bytes
        self.nodeIndex2Character = nodeIndex2Character
        self.indices = self.bits.indices
        self.pbits = UnsafePointer<Unit>(self.bits)
        self.rankLarge = bytes.reduce([0], {
            $0 + [($0.last ?? 0) &+ $1.nonzeroBitCount]
        })
        self.rankLarge0 = bytes.reduce([0], {
            $0 + [($0.last ?? 0) &+ (Self.unit &- $1.nonzeroBitCount)]
        })

        self.rankSmall = bytes.map{uint64 in
            [0] + (1..<8).reversed().map{i in
                UInt8((uint64 >> (i << 3)).nonzeroBitCount)
            }
        }
    }
    
    @inlinable
    func getPopCount(index: Int) -> Int {
        let i = UInt64(index)
        let r64 = i & 63    //64で割ったあまりに等しい
        let q64 = Int(i >> 6)
        let r08 = r64 & 7   //8で割ったあまりに等しい
        let q08 = Int(r64 >> 3)
        let p64 = self.rankLarge[q64]
        let p8 = self.rankSmall[q64][q08]
        //8-1=7
        let p1 = (self.bits[q64].uint8Array(q08) >> (7 &- r08)).nonzeroBitCount

        return p64 &+ Int(p8) &+ p1
    }
    
    //テスト通った、が、そもそも呼ばれる機会がないのでこれはあんまり気にしなくてもいい。
    func index(from nodeIndex: Int) -> Int {
        var total = 0
        for i in self.indices{
            let count = (pbits+i).pointee.nonzeroBitCount
            total += count
        
            if total >= nodeIndex{
                let dif = total - nodeIndex
                var byte = (pbits+i).pointee
                var k = 0
                for _ in 0..<Self.unit{
                    byte = byte << 1
                    if byte.nonzeroBitCount == dif{
                        return i >> Self.uExp + k
                    }
                    k += 1
                }
                return -1
            }

        }
        return -1
    }
    
    func nodeIndex(from index: Int) -> Int {
        return self.getPopCount(index: index)
    }
    
    //テスト通ったが、呼ばれない。
    func parentNodeIndex(from childIndex: Int) -> Int {
        let value = childIndex.quotientAndRemainder(dividingBy: Self.unit)
        var total = 0
        for i in 0..<value.quotient{
            total += Self.unit-(pbits+i).pointee.nonzeroBitCount
        }
        total += (~self.bits[value.quotient] >> (Self.unit-value.remainder-1)).nonzeroBitCount
        return total
    }
    
    func childIndices2(from parentNodeIndex: Int) -> Range<Int> {
        var lowerIndex = 0
        var upperIndex = self.bits.count >> Self.uExp - 1
        var childNodeIndex = 0
        while true{
            let currentIndex = (lowerIndex + upperIndex)/2
            let value = self.nodeIndex(from: currentIndex)
            if (currentIndex+1) - value == parentNodeIndex{
                childNodeIndex = currentIndex
                break
            } else if (lowerIndex > upperIndex) {
                return 0..<0
            } else {
                if (currentIndex+1) - value > parentNodeIndex {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
        let begin: Int
        let last: Int
        let cur = self.nodeIndex(from: childNodeIndex)
        do{
            var curPopCount = cur
            var start = childNodeIndex-1
            var nextPopCount = self.nodeIndex(from: start)
            while curPopCount > nextPopCount && start >= 0{
                curPopCount = nextPopCount
                start -= 1
                nextPopCount = self.nodeIndex(from: start)
            }
            begin = start+1
        }
        do{
            var curPopCount = cur
            var end = childNodeIndex+1
            var nextPopCount = self.nodeIndex(from: end)
            while curPopCount < nextPopCount && end < (self.bits.count >> Self.uExp){
                curPopCount = nextPopCount
                end += 1
                nextPopCount = self.nodeIndex(from: end)
            }
            last = end
        }
        return begin+1..<last
    }
    

    func childIndices5(from parentNodeIndex: Int) -> Range<Int> {

        /*
         1. 64bit毎に探索する。
         {(index: Int) in unit &* (index &+ 1) - self.rankLarge[index &+ 1] >= parentNodeIndex}
         を満たすindex = iおよびこの次のjを二分探索で取得する。
         2. i*unit - 1 <.< j*unit + 0 の範囲を二分探索して、求める始点と終点を得る。
        
         */
        
        let i: Int
        let j: Int
        do{
            var leftM = parentNodeIndex >> Self.uExp - 1
            var rightM = self.bits.count
            var leftm = leftM
            var rightm = rightM
            
            while true {
                let boolM = rightM - leftM > 1
                let boolm = rightm - leftm > 1

                if boolM && boolm{
                    //2で割ることに等しい
                    let midM = (leftM + rightM) >> 1
                    //print("Mm, midM: ", leftM, rightM)
                    if (midM + 1) << Self.uExp - self.rankLarge[midM + 1] >= parentNodeIndex + 1{
                        rightM = midM
                        rightm = min(rightm, rightM)
                    }else{
                        leftM = midM
                    }
                    
                    if rightM - leftM <= 1 || rightm - leftm <= 1{
                        continue
                    }

                    let midm = (leftm + rightm) >> 1
                    
                    //print("Mm, midm: ", leftm, rightm)

                    if (midm + 1) << Self.uExp - self.rankLarge[midm + 1] >= parentNodeIndex{
                        rightm = midm
                    }else{
                        leftm = midm
                        leftM = max(leftm, leftM)
                    }
                }else if boolM{
                    let midM = (leftM + rightM) >> 1
                    //print("M, midM: ", leftM, rightM)
                    if (midM + 1) << Self.uExp - self.rankLarge[midM + 1] >= parentNodeIndex + 1{
                        rightM = midM
                    }else{
                        leftM = midM
                    }
                }else if boolm{
                    let midm = (leftm + rightm) >> 1
                    //print("m, midm: ", leftm, rightm)

                    if (midm + 1) << Self.uExp - self.rankLarge[midm + 1] >= parentNodeIndex{
                        rightm = midm
                    }else{
                        leftm = midm
                    }
                }else{
                    break
                }
                
            }
            //print(leftm, rightm, leftM, rightM)
            i = rightm
            j = rightM
        }
       // print("中間結果", i,j)
      // return 0..<0
        do{
            var leftM = i << Self.uExp - 1
            var rightM = (j + 1) << Self.uExp
            var leftm = leftM
            var rightm = rightM

            while true {
                let boolM = rightM - leftM > 1
                let boolm = rightm - leftm > 1

                if boolM && boolm{
                    let midM = (leftM + rightM) >> 1

                    if (midM + 1) - self.nodeIndex(from: midM) >= parentNodeIndex + 1{
                        rightM = midM
                        rightm = min(rightm, rightM)
                    }else{
                        leftM = midM
                    }
                    let midm = (leftm + rightm) >> 1
                    
                    if (midm + 1) - self.nodeIndex(from: midm) >= parentNodeIndex{
                        rightm = midm
                    }else{
                        leftm = midm
                        leftM = max(leftm, leftM)
                    }
                }else if boolM{
                    let midM = (leftM + rightM) >> 1
                    if (midM + 1) - self.nodeIndex(from: midM) >= parentNodeIndex + 1{
                        rightM = midM
                    }else{
                        leftM = midM
                    }
                }else if boolm{
                    let midm = (leftm + rightm) >> 1
                    if (midm + 1) - self.nodeIndex(from: midm) >= parentNodeIndex{
                        rightm = midm
                    }else{
                        leftm = midm
                    }
                }else{
                    break
                }

            }

            return rightm + 1 ..< rightM
        }
    }
    
    func childIndices_tuned(from parentNodeIndex: Int) -> Range<Int> {
        guard let i = (parentNodeIndex >> Self.uExp ..< self.bits.count).first(where: {(index: Int) in (index &+ 1) << Self.uExp - self.rankLarge[index &+ 1] >= parentNodeIndex}) else{
            return 0..<0
        }
        
        let byte = (pbits + i).pointee
        let rbyte = ~byte
        let _unit = Self.unit &- 1
        let dif = (i &+ 1) << Self.uExp  - self.rankLarge[i &+ 1] &- parentNodeIndex   //0の数の超過分
        var count = Unit(Self.unit &- byte.nonzeroBitCount) //0の数
        var k = Self.unit

        for c in 0..<Self.unit{
            if count == dif{
                k = c
                break
            }
            //byteの上からc桁めが0なら == (byte << 0)が100………00より小さければ == 最初の1桁を一番下に持ってきた値そのもの
            count -= (rbyte << c) >> _unit
        }
        

        let start = (i << Self.uExp) &+ k
        if dif == 0{
            var j = i &+ 1
            while (pbits + j).pointee == Unit.max{
                j &+= 1
            }
            let byte2 = (pbits+j).pointee
            //最初の0を探す作業
            let a = (0..<Self.unit).first(where: {(byte2 << $0) < Unit.prefixOne})
            return start ..< (j << Self.uExp) &+ (a ?? 0)
        }else{
            //反転させたビットで最初の1を探す作業(次の0を探す作業)
            let a = (k..<Self.unit).first(where: {(byte << $0) < Unit.prefixOne})
            return start ..< (i << Self.uExp) &+ (a ?? 0)
        }
    }
    
    func childIndices_tuned2(from parentNodeIndex: Int) -> Range<Int> {
        var left = (parentNodeIndex >> Self.uExp) &- 1  //全てのbitが0になる場合がとりうる最小値なので、これを下限として良い。
        var right = self.bits.count

        while true {
            if right &- left <= 1{
                break
            }
            let mid = (left &+ right) >> 1             //>>1は2で割ることに等しい
            if (mid &+ 1) << Self.uExp &- self.rankLarge[mid &+ 1] >= parentNodeIndex{
                right = mid
            }else{
                left = mid
            }
        }
        let i = right

        let byte = (pbits + i).pointee
        let dif = (i &+ 1) << Self.uExp &- self.rankLarge[i &+ 1] &- parentNodeIndex   //0の数の超過分
        var count = Unit(Self.unit &- byte.nonzeroBitCount) //0の数
        var k = Self.unit

        for c in 0..<Self.unit{
            if count == dif{
                k = c
                break
            }
            //byteの上からc桁めが0なら == (byte << 0)が100………00より小さければ == 最初の1桁を一番下に持ってきた値そのもの
            count &-= (byte << c).leadingZeroBitCount > 0 ? 1:0
        }


        let start = (i << Self.uExp) &+ k
        if dif == 0{
            var j = i &+ 1
            while (pbits + j).pointee == Unit.max{
                j &+= 1
            }
            let byte2 = (pbits+j).pointee
            //最初の0を探す作業
            let a = (0..<Self.unit).first(where: {(byte2 << $0) < Unit.prefixOne})
            return start ..< (j << Self.uExp) &+ (a ?? 0)
        }else{
            //反転させたビットで最初の1を探す作業(次の0を探す作業)
            let a = (k..<Self.unit).first(where: {(byte << $0) < Unit.prefixOne})
            return start ..< (i << Self.uExp) &+ (a ?? 0)
        }
    }

    func childIndices(from parentNodeIndex: Int) -> Range<Int> {
        var left = -1
        while true{
            let dif = parentNodeIndex &- ((left &+ 1) << Self.uExp &- self.rankLarge[left &+ 1])
            if dif >= Self.unit{
                left &+= dif >> Self.uExp
            }else{
                break
            }
        }
        guard let i = (left + 1 ..< self.bits.count).first(where: {(index: Int) in (index &+ 1) << Self.uExp &- self.rankLarge[index &+ 1] >= parentNodeIndex}) else{
            return 0..<0
        }

        let byte = (pbits + i).pointee
        let dif = (i &+ 1) << Self.uExp &- self.rankLarge[i &+ 1] &- parentNodeIndex   //0の数の超過分
        var count = Unit(Self.unit &- byte.nonzeroBitCount) //0の数
        var k = Self.unit

        for c in 0..<Self.unit{
            if count == dif{
                k = c
                break
            }
            //byteの上からc桁めが0なら == (byte << 0)が100………00より小さければ == 最初の1桁を一番下に持ってきた値そのもの
            count &-= (byte << c).leadingZeroBitCount > 0 ? 1:0
        }


        let start = (i << Self.uExp) &+ k
        if dif == 0{
            var j = i &+ 1
            while (pbits + j).pointee == Unit.max{
                j &+= 1
            }
            let byte2 = (pbits+j).pointee
            //最初の0を探す作業
            let a = (0..<Self.unit).first(where: {(byte2 << $0) < Unit.prefixOne})
            return start ..< (j << Self.uExp) &+ (a ?? 0)
        }else{
            //反転させたビットで最初の1を探す作業(次の0を探す作業)
            let a = (k..<Self.unit).first(where: {(byte << $0) < Unit.prefixOne})
            return start ..< (i << Self.uExp) &+ (a ?? 0)
        }
    }

    /*
     よく考えたら
     NodeIndices = indexまでの1の数
     childIndiceis = indexまでの0の数がparentNodeIndexに等しい範囲
     だから、
     childNodeIndices = indexまでの0の数がparentNodeIndexに等しい範囲からparentNodeIndexを引いた範囲

     */
    func childNodeIndices(from parentNodeIndex: Int) -> Range<Int> {
        var left = -1
        while true{
            let dif = parentNodeIndex &- ((left &+ 1) << Self.uExp &- self.rankLarge[left &+ 1])
            if dif >= Self.unit{
                left &+= dif >> Self.uExp
            }else{
                break
            }
        }
        guard let i = (left &+ 1 ..< self.bits.count).first(where: {(index: Int) in (index &+ 1) << Self.uExp &- self.rankLarge[index &+ 1] >= parentNodeIndex}) else{
            return 0..<0
        }

        let byte = (pbits + i).pointee
        let dif = (i &+ 1) << Self.uExp &- self.rankLarge[i &+ 1] &- parentNodeIndex   //0の数の超過分
        var count = Unit(Self.unit &- byte.nonzeroBitCount) //0の数
        var k = Self.unit

        for c in 0..<Self.unit{
            if count == dif{
                k = c
                break
            }
            //byteの上からc桁めが0なら == (byte << 0)が100………00より小さければ == 最初の1桁を一番下に持ってきた値そのもの
            count &-= (byte << c).leadingZeroBitCount > 0 ? 1:0
        }


        let start = (i << Self.uExp) &+ k &- parentNodeIndex &+ 1
        if dif == 0{
            var j = i &+ 1
            while (pbits + j).pointee == Unit.max{
                j &+= 1
            }
            let byte2 = (pbits+j).pointee
            //最初の0を探す作業
            let a = (0..<Self.unit).first(where: {(byte2 << $0) < Unit.prefixOne})
            return start ..< (j << Self.uExp) &+ (a ?? 0) &- parentNodeIndex &+ 1
        }else{
            //反転させたビットで最初の1を探す作業(次の0を探す作業)
            let a = (k..<Self.unit).first(where: {(byte << $0) < Unit.prefixOne})
            return start ..< (i << Self.uExp) &+ (a ?? 0) &- parentNodeIndex &+ 1
        }
    }

    func childNodeIndices2(from parentNodeIndex: Int) -> Range<Int> {
        var left = -1
        while true{
            let dif = parentNodeIndex &- self.rankLarge0[left &+ 1]
            if dif >= Self.unit{
                left &+= dif >> Self.uExp
            }else{
                break
            }
        }
        guard let i = (left + 1 ..< self.bits.count).first(where: {(index: Int) in self.rankLarge0[index &+ 1] >= parentNodeIndex}) else{
            return 0..<0
        }

        let byte = (pbits + i).pointee
        let dif = self.rankLarge0[i &+ 1] &- parentNodeIndex   //0の数の超過分
        var count = Unit(Self.unit &- byte.nonzeroBitCount) //0の数
        var k = Self.unit

        for c in 0..<Self.unit{
            if count == dif{
                k = c
                break
            }
            //byteの上からc桁めが0なら == (byte << 0)が100………00より小さければ == 最初の1桁を一番下に持ってきた値そのもの
            count &-= (byte << c).leadingZeroBitCount > 0 ? 1:0
        }


        let start = (i << Self.uExp) &+ k &- parentNodeIndex &+ 1
        if dif == 0{
            var j = i &+ 1
            while (pbits + j).pointee == Unit.max{
                j &+= 1
            }
            let byte2 = (pbits+j).pointee
            //最初の0を探す作業
            let a = (0..<Self.unit).first(where: {(byte2 << $0) < Unit.prefixOne})
            return start ..< (j << Self.uExp) &+ (a ?? 0) &- parentNodeIndex &+ 1
        }else{
            //反転させたビットで最初の1を探す作業(次の0を探す作業)
            let a = (k..<Self.unit).first(where: {(byte << $0) < Unit.prefixOne})
            return start ..< (i << Self.uExp) &+ (a ?? 0) &- parentNodeIndex &+ 1
        }
    }


    func childIndices4(from parentNodeIndex: Int) -> Range<Int> {
        var leftM = -1
        var rightM = self.bits.count * Self.unit
        var leftm = leftM
        var rightm = rightM

        while true {
            let boolM = rightM - leftM > 1
            let boolm = rightm - leftm > 1

            if boolM && boolm{
                let midM = (leftM + rightM) / 2

                if (midM + 1) - self.nodeIndex(from: midM) >= parentNodeIndex + 1{
                    rightM = midM
                    rightm = min(rightm, rightM)
                }else{
                    leftM = midM
                }
                
                let midm = (leftm + rightm) / 2
                
                if (midm + 1) - self.nodeIndex(from: midm) >= parentNodeIndex{
                    rightm = midm
                }else{
                    leftm = midm
                    leftM = max(leftm, leftM)
                }
            }else if boolM{
                let midM = (leftM + rightM) / 2
                if (midM + 1) - self.nodeIndex(from: midM) >= parentNodeIndex + 1{
                    rightM = midM
                }else{
                    leftM = midM
                }
            }else if boolm{
                let midm = (leftm + rightm) / 2
                if (midm + 1) - self.nodeIndex(from: midm) >= parentNodeIndex{
                    rightm = midm
                }else{
                    leftm = midm
                }
            }else{
                break
            }
        }

        return rightm+1..<rightM
    }

    
    func childIndices3(from parentNodeIndex: Int) -> Range<Int> {
        for i in self.indices{
            let total = Self.unit*(i+1) - self.rankLarge[i+1]
            if total >= parentNodeIndex{
                let pointer = pbits + i
                let pCount = Self.unit - pointer.pointee.nonzeroBitCount

                let dif = (total - parentNodeIndex)
                var byte = ~pointer.pointee
                var k = 0
                var count = pCount
                for _ in 0..<Self.unit{
                    if count == dif{
                        break
                    }
                    count -= (((byte & Unit.prefixOne) == Unit.prefixOne) ? 1:0)
                    byte = byte << 1

                    k += 1
                }
                if k == Self.unit{
                    return 0..<0
                }
                let start = i*Self.unit + k
                if (~pointer.pointee) << k == 0{
                    var j = i+1
                    while (pbits+j).pointee == Unit.max{
                        j += 1
                    }
                    var a = 0
                    var byte2 = (pbits+j).pointee
                    for _ in 0..<Self.unit{
                        if (byte2 & Unit.prefixOne) == 0{
                            break
                        }
                        byte2 = byte2 << 1
                        a += 1
                    }
                    
                    return start ..< j*Self.unit + a
                }else{
                    let byte2 = ~pointer.pointee
                    var j = 0
                    for c in k..<Self.unit{
                        if ((byte2 >> (Self.unit-c-1)) & 1) == 1{
                            j = c
                            break
                        }
                    }
                    return start ..< i*Self.unit + j
                }
            }
        }
        return 0..<0
    }

    func searchNodeIndex(chars: [Character]) -> Int? {
        var findFlag = true
        let index = chars.reduce(1){prev, char in
            if findFlag{
                let childrenNodeIndices = self.childNodeIndices(from: prev)    //1番ノードの子ノードのindex
                for nodeIndex in childrenNodeIndices{
                    if self.nodeIndex2Character[nodeIndex] == char{
                        return nodeIndex
                    }
                }
                findFlag = false
            }
            return prev
        }
        return findFlag ? index:nil
    }

    func prefixNodeIndices(nodeIndex: Int) -> [Int] {
        let childNodeIndices = self.childNodeIndices(from: nodeIndex)
        return childNodeIndices + childNodeIndices.flatMap{self.prefixNodeIndices(nodeIndex: $0)}
    }

    func prefixNodeIndices(chars: [Character], ignoringPerfectMatch: Bool = false) -> [Int] {
        guard let nodeIndex = self.searchNodeIndex(chars: chars) else{
            return []
        }
        return self.prefixNodeIndices(nodeIndex: nodeIndex)
    }


    func byfixNodeIndices(chars: [Character]) -> [Int] {
        var findFlag = true
        return chars.reduce([1]){prev, char -> [Int] in
            if findFlag{
                let childrenNodeIndices = self.childNodeIndices(from: prev.last!)    //1番ノードの子ノードのindex
                for nodeIndex in childrenNodeIndices{
                    if self.nodeIndex2Character[nodeIndex] == char{
                        return prev + [nodeIndex]
                    }
                }
                findFlag = false
            }
            return prev
        }
    }
}
