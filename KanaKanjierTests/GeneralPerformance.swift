//
//  StringPerformance.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/10/02.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import XCTest
import azooKey

class GeneralPerformance: XCTestCase {

    func primes(upTo number: Int) -> [Int] {
        precondition(number >= 0)
        if number < 2 { return [] }
        var count = 0
        var sieve: [Bool] = .init(repeating: false, count: number + 1)
        for m in stride(from: 3, through: Int(Double(number).squareRoot() + 1.5), by: 2) where !sieve[m] {
            let maxK = number / m
            count += 1
            if maxK < 2 { continue }
            for k in 2 ... maxK {
                sieve[k * m] = true
            }
        }
        var result: [Int] = [2]
        result.reserveCapacity(count + 1)
        for m in stride(from: 3, through: number, by: 2) where !sieve[m] {
            result.append(m)
        }
        return result
    }

    func testPerformancePrimes() throws {
        print()
        self.measure {
            print(primes(upTo: Int(1e8)).count)
        }
    }

    func testPerformancePrefixErasingSetFilter() throws {
        let strings = (0..<10000).map {_ in String("ABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABC".shuffled().prefix(Int.random(in: 1..<20)))}.sorted(by: {$0.count > $1.count})
        print(strings.prefix(2))
        var stringSet: Set<String> = []
        self.measure {
            strings.forEach {string in
                if !stringSet.contains(where: {$0.hasPrefix(string)}) {
                    stringSet.update(with: string)
                }
            }
            print(stringSet.count)
        }

    }

    func testPerformancePrefixPartialy() throws {
        let strings = (0..<10000).map {_ in String("ABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABC".shuffled().prefix(Int.random(in: 1..<20)))}
        var stringSet: Set<String> = Set(strings)
        self.measure {
            strings.forEach {string in
                if string.count > 4 {
                    return
                }
                if strings.contains {$0.hasPrefix(string) && $0 != string} {
                    stringSet.remove(string)
                }
            }
            print(stringSet.count)
        }

    }

    func testPerformancePrefixErasingSet() throws {
        let strings = (0..<10000).map {_ in String("ABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABCABC".shuffled().prefix(Int.random(in: 1..<20)))}
        var stringSet: Set<String> = Set(strings)
        self.measure {
            var removed: Set<String> = []
            strings.forEach {string in
                if removed.contains(string) {
                    return
                }
                (0..<string.count-1).forEach {i in
                    if let r = stringSet.remove(String(string.prefix(i))) {
                        removed.update(with: r)
                    }
                }
            }
            print(stringSet.count)
        }

    }

    // 結局joinedが最速である。lazyは問題外。
    func testPerformanceInsertZero() throws {
        var values = (0..<10000).map {_ in Int.random(in: 0..<100000)}.sorted()
        let adds = (0..<10000).map {_ in Int.random(in: 0..<100000)}
        self.measure {
            for value in adds {
                values.insert(value, at: 0)
            }
        }
    }

    func testPerformanceTupleRemake() throws {
        var values = (0..<10000).map {_ in Int.random(in: 0..<100000)}.sorted()
        let adds = (0..<10000).map {_ in Int.random(in: 0..<100000)}
        self.measure {
            for value in adds {
                values = [value] + values
            }
        }
    }

    // 結局joinedが最速である。reduceは問題外。
    func testPerformanceTupleJoined() throws {
        let values = (0..<10000).map {_ in (string: String("ABC".randomElement()!), value: Double.random(in: 0..<1))}
        self.measure {
            let result = values.map {$0.string}.joined().hasSuffix("A")
            print(result)
        }
    }

    func testPerformanceTupleMapReduce() throws {
        let values = (0..<10000).map {_ in (string: String("ABC".randomElement()!), value: Double.random(in: 0..<1))}
        self.measure {
            let result = values.map {$0.string}.reduce("", +).hasSuffix("A")
            print(result)
        }
    }

    // こっちが遅い
    func testPerformanceTupleReduce() throws {
        let values = (0..<10000).map {_ in (string: String("ABC".randomElement()!), value: Double.random(in: 0..<1))}
        self.measure {
            let result = values.reduce("", {$0 + $1.string}).hasSuffix("A")
            print(result)
        }
    }

    // 先頭が0か判定する
    func testPerformanceCalcZero() throws {
        let values = (0..<1000000).map {_ in UInt64.random(in: 0...UInt64.max)}
        self.measure {
            let sum = values.map { ~$0 >> (UInt64.bitWidth - 1)}
            print(sum.count)
        }
    }

    // 先頭が0か判定する
    func testPerformanceIsLessZero() throws {
        let values = (0..<1000000).map {_ in UInt64.random(in: 0...UInt64.max)}
        self.measure {
            let sum = values.map {$0 < UInt64.prefixOne ? 1:0}
            print(sum.count)
        }
    }

    // 先頭が0か判定する
    func testPerformanceLeadingZero() throws {
        let values = (0..<1000000).map {_ in UInt64.random(in: 0...UInt64.max)}
        self.measure {
            let sum = values.map {$0.leadingZeroBitCount > 0 ? 1:0}
            print(sum.count)
        }
    }

    // popCountする
    func testPerformancePopCount() throws {
        let values = (0..<1000000).map {_ in UInt64.random(in: 0...UInt64.max)}
        self.measure {
            let sum = values.map {$0.popCount}.reduce(0, +)
            print(sum)
        }
    }

    // nonzerobitcountする
    func testPerformanceNonZeroBitCount() throws {
        let values = (0..<1000000).map {_ in UInt64.random(in: 0...UInt64.max)}
        self.measure {
            let sum = values.map {$0.nonzeroBitCount}.reduce(0, +)
            print(sum)
        }
    }

    // mapする
    func testPerformanceSimpleMap() throws {
        let array = Array(0..<1000000)
        self.measure {
            let result = array.map { i in
                return i-i%777
            }
        }
    }

    // mapする
    func testPerformanceByteMap() throws {
        let array = Array(0..<1000000)
        self.measure {
            let result = array.withUnsafeBufferPointer {
                return $0.map { i in i-i%777}
            }
        }
    }

    // 辞書をremoveする

    func testPerformanceArrayPop() throws {
        var values = Array(0..<1000000)
        self.measure {
            (0..<1000000).forEach {_ in
                values.popLast()
            }
        }
    }

    func testPerformanceArrayRemove() throws {
        var values = Array(0..<1000000)
        self.measure {
            (0..<1000000-1).forEach {_ in
                values.removeLast()
            }
        }
    }

    func testPerformanceArrayDrop() throws {
        var values = Array(0..<1000000)
        self.measure {
            (0..<1000000).forEach {_ in
                values = values.dropLast()
            }
        }
    }

    // [Int]にする
    // こっちは遅い
    func testPerformanceMapRange() throws {
        print()
        self.measure {
            (0..<10000).forEach {_ in
                let ints: [Int] = (0..<100000).map {$0}
            }
        }
    }

    // こっちが早い
    func testPerformanceArrayRange() throws {
        print()
        self.measure {
            (0..<10000).forEach {_ in
                let ints: [Int] = Array(0..<100000)
            }
        }
    }

    // [Character]にする
    // こっちが遅い
    func testPerformanceMapCharacter() throws {
        let array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        self.measure {
            array.forEach {value in
                let chars: [Character] = value.map {$0}
            }
        }
    }

    // こっちが微妙に早い
    func testPerformanceArrayCharacter() throws {
        let array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        self.measure {
            array.forEach {value in
                let chars: [Character] = Array(value)
            }
        }
    }

    // 辞書から値を取り出す
    func testPerformanceDictGetValueOptional() throws {
        let values = (0..<100000).map {_ in (0..<100000).randomElement()!}
        var dict: [Int: [Int]] = [:]
        values.forEach {value in
            let rq = value.quotientAndRemainder(dividingBy: 1000)
            dict[rq.quotient*1000, default:[]].append(rq.remainder)
        }
        self.measure {
            (0..<100000).forEach {i in
                let value: [Int] = dict[i * 100] ?? []
            }
        }
    }

    func testPerformanceDictGetValueDefault() throws {
        let values = (0..<100000).map {_ in (0..<100000).randomElement()!}
        var dict: [Int: [Int]] = [:]
        values.forEach {value in
            let rq = value.quotientAndRemainder(dividingBy: 1000)
            dict[rq.quotient*1000, default:[]].append(rq.remainder)
        }
        self.measure {
            (0..<100000).forEach {i in
                let value: [Int] = dict[i * 100, default: []]
            }
        }
    }

    // 分類して辞書にする(高速)
    // これが一番速い
    func testPerformanceDictInit() throws {
        let values = (0..<100000).map {_ in (0..<100000).randomElement()!}
        self.measure {
            let _dict = [Int: [Int]].init(grouping: values, by: {$0/1000})
            let dict = [Int: [Int]].init(uniqueKeysWithValues: _dict.map {($0.key*1000, $0.value.map {$0%1000})})
        }
    }

    func testPerformanceDictBuild() throws {
        let values = (0..<100000).map {_ in (0..<100000).randomElement()!}
        var dict: [Int: [Int]] = [:]
        self.measure {
            values.forEach {value in
                let rq = value.quotientAndRemainder(dividingBy: 1000)
                let key = rq.quotient*1000
                if let dic = dict[key] {
                    dict[key] = dic+[rq.remainder]
                } else {
                    dict[key] = [rq.remainder]
                }
            }
        }
    }

    func testPerformanceDictBuild2() throws {
        let values = (0..<100000).map {_ in (0..<100000).randomElement()!}
        var dict: [Int: [Int]] = [:]
        self.measure {
            values.forEach {value in
                let rq = value.quotientAndRemainder(dividingBy: 1000)
                let key = rq.quotient*1000
                if dict.keys.contains(key) {
                    dict[key]?.append(rq.remainder)
                } else {
                    dict[key] = [rq.remainder]
                }
            }
        }
    }

    func testPerformanceDictBuild3() throws {
        let values = (0..<100000).map {_ in (0..<100000).randomElement()!}
        var dict: [Int: [Int]] = [:]
        self.measure {
            values.forEach {value in
                let rq = value.quotientAndRemainder(dividingBy: 1000)
                let key = rq.quotient*1000
                if let _ = dict[key] {
                    dict[key]?.append(rq.remainder)
                } else {
                    dict[key] = [rq.remainder]
                }
            }
        }
    }

    // ついで高速
    func testPerformanceDictBuild4() throws {
        let values = (0..<100000).map {_ in (0..<100000).randomElement()!}
        var dict: [Int: [Int]] = [:]
        self.measure {
            values.forEach {value in
                let rq = value.quotientAndRemainder(dividingBy: 1000)
                dict[rq.quotient*1000, default:[]].append(rq.remainder)
            }
        }
    }

    func testPerformanceDictBuild5() throws {
        let values = (0..<100000).map {_ in (0..<100000).randomElement()!}

        var dict: [Int: [Int]] = [:]
        self.measure {
            values.forEach {value in
                let rq = value.quotientAndRemainder(dividingBy: 1000)
                let key = rq.quotient * 1000
                var tmp = dict.removeValue(forKey: key) ?? []
                tmp.append(rq.remainder)
                dict[key] = tmp
            }
        }
    }

    // 配列追加
    // 案外同じくらい
    func testPerformanceArrayAppend() throws {
        print()
        var array = [[Int]].init(repeating: Array(0..<100), count: 10000)
        self.measure {
            array.indices.forEach {i in
                array[i].append(100)
            }
        }
    }

    func testPerformanceArrayOperator() throws {
        print()
        var array = [[Int]].init(repeating: Array(0..<100), count: 10000)
        self.measure {
            array.indices.forEach {i in
                array[i] += [100]
            }
        }
    }

    // 空判定
    // 案外同じくらい
    func testPerformanceisEmpty() throws {
        print()
        var array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 500000) + [String].init(repeating: "", count: 500000)
        array.shuffle()
        self.measure {
            array.forEach {value in
                let bool = value.isEmpty
            }
        }
    }
    // 案外同じくらい。最適化かかればそんなもんなのか？
    func testPerformanceEqualEmpty() throws {
        print()
        var array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 500000) + [String].init(repeating: "", count: 500000)
        array.shuffle()
        self.measure {
            array.forEach {value in
                let bool = value == ""
            }
        }
    }

    // 先頭一致判定
    // これが早い
    func testPerformanceHasPrefix() throws {
        print()
        var array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        let check_a = "qrstuvwxyz"
        let check_b = "qrstnvwxyz"
        self.measure {
            array.forEach {value in
                let bool = value.hasPrefix(check_a) && value.hasPrefix(check_b)
            }
        }
    }

    // これが遅い
    func testPerformanceStart() throws {
        print()
        var array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        let check_a = "qrstuvwxyz"
        let check_b = "qrstnvwxyz"
        self.measure {
            array.forEach {value in
                let bool = value.starts(with: check_a) && value.starts(with: check_b)
            }
        }
    }

    // これが遅い
    func testPerformancePrefixEqual() throws {
        print()
        var array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        let check_a = "qrstuvwxyz"
        let check_b = "qrstnvwxyz"
        self.measure {
            array.forEach {value in
                let bool = (value.prefix(check_a.count) == check_a) && (value.prefix(check_b.count) == check_b)
            }
        }
    }

    // 文字列のクリア
    // これが早い
    func testPerformanceClear() throws {
        print()
        var array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        self.measure {
            array.indices.forEach {(i: Int) in
                array[i] = ""
            }
        }
    }

    // 結論:案外大差ないが、上のほうが早い
    func testPerformanceRemoveAll() throws {
        print()
        var array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        self.measure {
            array.indices.forEach {(i: Int) in
                array[i].removeAll()
            }
        }
    }

    // 文字列の追加
    // これと+=は大体同等
    func testPerformanceAppend() throws {
        print()
        var array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        self.measure {
            array.indices.forEach {(i: Int) in
                array[i].append("1234567890")
            }
        }
    }

    // これとappendは大体同等
    func testPerformanceOperation() throws {
        print()
        var array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        self.measure {
            array.indices.forEach {(i: Int) in
                array[i] += "1234567890"
            }
        }
    }

    // 結論:appendingは遅い。
    func testPerformanceAppending() throws {
        print()
        let array = [String].init(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", count: 1000000)
        self.measure {
            let result = array.map {value in
                value.appending("1234567890")
            }
        }

    }

}
