//
//  BloomFilter.swift
//  KanaKanjierTests
//
//  Created by β α on 2022/09/18.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import XCTest

struct BloomFilter {
    var byteCount: Int  // bitCount must be multiple of 8
    var bytes: [UInt8]

    init(byteCount: Int) {
        self.byteCount = byteCount
        self.bytes = .init(repeating: .zero, count: byteCount)
    }

    mutating func insert(fnv1aHashes: some Sequence<Int>) {
        for index in fnv1aHashes {
            bytes[index / 8] |= 0b00_00_00_01 << (index % 8)
        }
    }

    mutating func insert(fnv1aHashes: some Sequence<UInt8>) {
        for index in fnv1aHashes {
            bytes[Int(index) / 8] |= 0b00_00_00_01 << (Int(index) % 8)
        }
    }

    mutating func insert(fnv1aHashes: some Sequence<UInt64>) {
        for index in fnv1aHashes {
            bytes[Int(index) / 8] |= 0b00_00_00_01 << (Int(index) % 8)
        }
    }

    func probablyContains(fnv1aHashes: some Sequence<Int>) -> Bool {
        for index in fnv1aHashes {
            if bytes[index / 8] & (0b00_00_00_01 << (index % 8)) == 0 {
                return false
            }
        }
        return true
    }

    func probablyContains(fnv1aHashes: some Sequence<UInt8>) -> Bool {
        for index in fnv1aHashes {
            if bytes[Int(index) / 8] & (0b00_00_00_01 << (Int(index) % 8)) == 0 {
                return false
            }
        }
        return true
    }

    func probablyContains(fnv1aHashes: some Sequence<UInt64>) -> Bool {
        for index in fnv1aHashes {
            if bytes[Int(index) / 8] & (0b00_00_00_01 << (Int(index) % 8)) == 0 {
                return false
            }
        }
        return true
    }
}

@inlinable func fnv1a_init(hash: inout UInt64) {
    hash = 14695981039346656037
}
@inlinable func fnv1a_update(hash: inout UInt64, value: UInt64) {
    hash ^= value
    hash &*= 1099511628211
}
@inlinable func fnv1a_update(hash: inout UInt64, value: UInt8) {
    hash ^= UInt64(value)
    hash &*= 1099511628211
}
@inlinable func fnv1a_update(hash: inout UInt64, value: Int) {
    hash ^= UInt64(value)
    hash &*= 1099511628211
}
@inlinable func fnv1a_update(hash: inout UInt64, value: String) {
    for u8 in value.utf8 {
        hash ^= UInt64(u8)
        hash &*= 1099511628211
    }
}

class BloomFilterTest: XCTestCase {
    @inlinable func hashForString(_ string: String) -> some Sequence<UInt8> {
        var hash: UInt64 = 0
        fnv1a_init(hash: &hash)
        fnv1a_update(hash: &hash, value: string)
        // Hashを1byteずつに分割する
        var bigEndian: UInt64 = hash.bigEndian
        let count = MemoryLayout<UInt64>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return Array(bytePtr)
    }
    func testBloomFilter() throws {
        var filter = BloomFilter(byteCount: 256)
        do {
            let string = "漢字😇"
            let array = hashForString(string)
            filter.insert(fnv1aHashes: array)
            XCTAssertTrue(filter.probablyContains(fnv1aHashes: array))
        }
        do {
            let string = "かなカナ"
            let array = hashForString(string)
            filter.insert(fnv1aHashes: array)
            XCTAssertTrue(filter.probablyContains(fnv1aHashes: array))
        }
        do {
            let string = "漢字😇"
            let array = hashForString(string)
            XCTAssertTrue(filter.probablyContains(fnv1aHashes: array))
        }
        do {
            let string = "ハッシュ"
            let array = hashForString(string)
            XCTAssertFalse(filter.probablyContains(fnv1aHashes: array))
        }
    }

    struct DicdataMock {
        var word: String
        var ruby: String
        var lcid: Int
        var rcid: Int
        var mid: Int
        var value: Float16

        static func random() -> Self {
            return Self.init(
                word: String((1...Int.random(in: 1...10)).map {_ in "アイウエオ漢字😇✋🇰🇷花鳥風月春夏秋冬1234567890ABC".randomElement()!}),
                ruby: String((1...Int.random(in: 1...10)).map {_ in "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホ".randomElement()!}) ,
                lcid: Int.random(in: 0...2000),
                rcid: Int.random(in: 0...2000),
                mid: Int.random(in: 0...500),
                value: Float16.random(in: -30...0)
            )
        }
    }

    @inlinable func hashForDicdataMock(_ value: DicdataMock) -> some Sequence<UInt64> {
        var hash: UInt64 = 0
        var hashes: [UInt64] = []
        fnv1a_init(hash: &hash)
        fnv1a_update(hash: &hash, value: value.word)
        fnv1a_update(hash: &hash, value: value.ruby)
        fnv1a_update(hash: &hash, value: value.lcid)
        fnv1a_update(hash: &hash, value: value.rcid)

        // hashを7個返しているので、衝突率は1/128

        hashes.append((hash << 43) >> 43)  // 64-21 = 43      (末尾21bit)を取得するため、上43bitを押し出してから43bit分戻す
        hashes.append((hash << 22) >> 43)  // 64-42 = 22, 22+21=43      (42...21bitを取得するため、上22bitを押し出した上で下21bitと合わせて戻す)
        hashes.append(hash >> 43)  // 64-21 = 43      頭21bitを取得するため、下41bitを押し出す

        // 別のhashを作るため、もう一度wordを突っ込む
        // もしwordが一致していたらもうしょうがないのでこれでいい
        fnv1a_update(hash: &hash, value: value.word)
        hashes.append((hash << 43) >> 43)  // 64-21 = 43      (末尾21bit)を取得するため、上43bitを押し出してから43bit分戻す
        hashes.append((hash << 22) >> 43)  // 64-42 = 22, 22+21=43      (42...21bitを取得するため、上22bitを押し出した上で下21bitと合わせて戻す)
        hashes.append(hash >> 43)  // 64-21 = 43      頭21bitを取得するため、下41bitを押し出す

        // 別のhashを作るため、さらにlcidを突っ込む
        fnv1a_update(hash: &hash, value: value.lcid)

        // hashes.append((hash << 43) >> 43)  // 64-21 = 43      (末尾21bit)を取得するため、上43bitを押し出してから43bit分戻す
        // hashes.append((hash << 22) >> 43)  // 64-42 = 22, 22+21=43      (42...21bitを取得するため、上22bitを押し出した上で下21bitと合わせて戻す)
        hashes.append(hash >> 43)  // 64-21 = 43      頭21bitを取得するため、下41bitを押し出す

        // Hashを21bitずつに分割する
        return hashes
    }

    // insert40000件くらいなら難なく対処できる
    func testInsertPerformance() throws {
        var filter = BloomFilter(byteCount: 262144) // 2^18byte (256KB)のBloom Filter, hashは21bitとなる
        let randomElement0 = DicdataMock.random()
        let randomElement1 = DicdataMock.random()
        let randomElement2 = DicdataMock.random()
        let randomElement3 = DicdataMock.random()

        measure {
            for _ in 0 ... 10000 {
                filter.insert(fnv1aHashes: hashForDicdataMock(randomElement0))
                filter.insert(fnv1aHashes: hashForDicdataMock(randomElement1))
                filter.insert(fnv1aHashes: hashForDicdataMock(randomElement2))
                filter.insert(fnv1aHashes: hashForDicdataMock(randomElement3))
            }
        }
    }

    // contains80000件に対して0.02秒
    func testContains10000Performance() throws {
        var filter = BloomFilter(byteCount: 262144) // 2^18byte (256KB)のBloom Filter, hashは21bitとなる
        for _ in 0 ... 10000 {
            let randomElement = DicdataMock.random()
            filter.insert(fnv1aHashes: hashForDicdataMock(randomElement))
        }

        let randomElement0 = DicdataMock.random()
        let randomElement1 = DicdataMock.random()
        let randomElement2 = DicdataMock.random()
        let randomElement3 = DicdataMock.random()
        let randomElement4 = DicdataMock.random()
        let randomElement5 = DicdataMock.random()
        let randomElement6 = DicdataMock.random()
        let randomElement7 = DicdataMock.random()

        measure {
            for _ in 0 ... 10000 {
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement0))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement1))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement2))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement3))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement4))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement5))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement6))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement7))
            }
        }
    }

    // contains80000件に対して0.02秒
    func testContains30000Performance() throws {
        var filter = BloomFilter(byteCount: 262144) // 2^18byte (256KB)のBloom Filter, hashは21bitとなる
        for _ in 0 ... 30000 {
            let randomElement = DicdataMock.random()
            filter.insert(fnv1aHashes: hashForDicdataMock(randomElement))
        }

        let randomElement0 = DicdataMock.random()
        let randomElement1 = DicdataMock.random()
        let randomElement2 = DicdataMock.random()
        let randomElement3 = DicdataMock.random()
        let randomElement4 = DicdataMock.random()
        let randomElement5 = DicdataMock.random()
        let randomElement6 = DicdataMock.random()
        let randomElement7 = DicdataMock.random()

        measure {
            for _ in 0 ... 10000 {
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement0))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement1))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement2))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement3))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement4))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement5))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement6))
                _ = filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement7))
            }
        }
    }

    // contains80000件に対して0.02秒
    func testFalsePositive() throws {
        var filter = BloomFilter(byteCount: 262144) // 2^18byte (256KB)のBloom Filter, hashは21bitとなる
        var trueItems: [DicdataMock] = []
        for _ in 0 ... 30000 {
            let randomElement = DicdataMock.random()
            trueItems.append(randomElement)
            filter.insert(fnv1aHashes: hashForDicdataMock(randomElement))
        }

        var truePositive = 0
        var falsePositive = 0
        for _ in 0 ... 1000000 {
            let randomElement = DicdataMock.random()
            if filter.probablyContains(fnv1aHashes: hashForDicdataMock(randomElement)) {
                if let foundItem = trueItems.first(where: {$0.word == randomElement.word && $0.ruby == randomElement.ruby && $0.lcid == randomElement.lcid && $0.rcid == randomElement.rcid }) {
                    print(randomElement, foundItem)
                    truePositive += 1
                } else {
                    falsePositive += 1
                }
            }
        }

        print("truePositive: \(truePositive) falsePositive: \(falsePositive)")
    }

}
