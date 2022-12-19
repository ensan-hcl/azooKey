//
//  HashPerformance.swift
//  KanaKanjierTests
//
//  Created by β α on 2022/09/17.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import XCTest
import FNV
import MurmurHash_Swift

struct DicdataMock: Hashable {
    var word: String
    var ruby: String
    var lcid: Int
    var rcid: Int
    var mid: Int
    var value: Float16

    static func random() -> Self {
        return Self.init(
            word: String.init(repeating: "文", count: Int.random(in: 1...10)),
            ruby: String.init(repeating: "文", count: Int.random(in: 1...10)),
            lcid: Int.random(in: 0...2000),
            rcid: Int.random(in: 0...2000),
            mid: Int.random(in: 0...500),
            value: Float16.random(in: -30...0)
        )
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        hasher.combine(ruby)
        hasher.combine(lcid)
        hasher.combine(rcid)
    }
}

struct HashMaker<T: Hashable>: Hashable {
    var value: T
    var diff: Int
}

class HashTest: XCTestCase {

    @inlinable func cidToUIntSequence(cid: Int) -> [UInt8] {
        return [
            UInt8(cid & 0x00_00_00_FF),
            UInt8((cid & 0x00_00_FF_00) >> 8)
        ]
    }

    @inlinable func cidToUIntSequence(lcid: Int, rcid: Int) -> [UInt8] {
        return [
            UInt8(lcid & 0x00_00_00_FF),
            UInt8((lcid & 0x00_00_FF_00) >> 8),
            UInt8(rcid & 0x00_00_00_FF),
            UInt8((rcid & 0x00_00_FF_00) >> 8)
        ]
    }

    func testperformanceFNV1AHash() throws {
        let element = DicdataMock.random()
        measure {
            for _ in 0...30000 {
                let fnv = FNV.FNV1a_64()
                fnv.update(element.word)
                fnv.update(element.ruby)
                fnv.update(cidToUIntSequence(lcid: element.lcid, rcid: element.rcid))
                do {
                    let h = fnv.copy()
                    h.update(cidToUIntSequence(cid: element.lcid))
                    _ = h.digest()
                }
                do {
                    let h = fnv.copy()
                    h.update(element.word)
                    _ = h.digest()
                }
                do {
                    _ = fnv.digest()
                }
            }

        }
    }

    // 標準のハッシュ関数の100倍遅い。うーん。
    func testperformanceMurmurHash() throws {
        let element = DicdataMock.random()
        measure {
            for _ in 0...3000 {
                let mmh = MurmurHash3.x86_128()
                mmh.update(element.word)
                mmh.update(element.ruby)
                mmh.update(cidToUIntSequence(lcid: element.lcid, rcid: element.rcid))
                do {
                    _ = mmh.digest()
                }
                do {
                    mmh.update(element.word)
                    _ = mmh.digest()
                }
            }
        }
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

    // 手で実装したFNV1aハッシュ
    // 0.04秒 (標準ライブラリの8種と遜色なし)
    // なんだちゃんと実装すれば速いじゃん。
    func testperformanceManualFNV1aHash() throws {
        let element = DicdataMock.random()
        measure {
            for _ in 0...300000 {
                var hash: UInt64 = 14695981039346656037
                hash = element.word.utf8.reduce(into: hash, fnv1a_update)
                hash = element.ruby.utf8.reduce(into: hash, fnv1a_update)
                fnv1a_update(hash: &hash, value: element.lcid)
                fnv1a_update(hash: &hash, value: element.rcid)
                do {
                    _ = hash
                }
                do {
                    hash = element.word.utf8.reduce(into: hash, fnv1a_update)
                    _ = hash
                }
                do {
                    fnv1a_update(hash: &hash, value: element.lcid)
                    _ = hash
                }
            }
        }
    }

    /// 8つのハッシュの計算にかかる時間を調べる。
    /// ただし標準ライブラリのハッシュ関数はStableではない。(オワリ)
    func testperformanceStandardHash() throws {
        let element = DicdataMock.random()
        measure {
            for _ in 0...300000 {
                var hasher = Hasher()
                hasher.combine(element.word)
                hasher.combine(element.ruby)
                hasher.combine(element.lcid)
                hasher.combine(element.rcid)
                do {
                    var h = hasher
                    h.combine(element.word)
                    _ = h.finalize()
                }
                do {
                    var h = hasher
                    h.combine(element.lcid)
                    _ = h.finalize()
                }
                do {
                    _ = hasher.finalize()
                }
            }
        }
    }

}
