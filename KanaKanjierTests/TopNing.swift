//
//  TopNing.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/10/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import XCTest

class TopNTest: XCTestCase {
    let max = 10000000
    let n = 1000000
    let N_best = 10000

    // N_best: 10000 [0.305831, 0.035596, 0.021496, 0.015396, 0.012163, 0.010116, 0.008780, 0.007777, 0.007034, 0.006316]
    // N_best: 10000 [0.312887, 0.036073, 0.021822, 0.015665, 0.012473, 0.010448, 0.009075, 0.008031, 0.007270, 0.006572]

    func testperformanceLastIndex() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        var topN: [Int] = []
        measure {
            values.forEach {(value: Int) in
                // 追加すべきindexを取得する
                let index = (topN.lastIndex(where: {$0 >= value}) ?? -1) &+ 1
                if index == N_best {
                    return
                }
                topN.insert(value, at: index)
                // カウントがオーバーしている場合は除去する
                if topN.count > N_best {
                    topN.removeLast()
                }
            }
        }
        print(topN.count)
    }

    @inlinable
    func binaryLastIndex(sorted sortedCollection: [Int], largerThan value: Int) -> Int {
        var low = sortedCollection.startIndex - 1
        var high = sortedCollection.endIndex
        while high - low > 1 {
            let mid = low + (high - low) / 2
            if sortedCollection[mid] <= value {
                high = mid
            } else {
                low = mid
            }
        }
        return low
    }

    // N_best: 10000 [0.274115, 0.034778, 0.021358, 0.015558, 0.012380, 0.010477, 0.009041, 0.008106, 0.007313, 0.006691]
    // N_best: 10000 [0.276995, 0.034764, 0.021167, 0.015449, 0.012437, 0.010481, 0.009092, 0.008127, 0.007341, 0.006641]

    func testperformanceLastIndex2() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        var topN: [Int] = []
        measure {
            topN = values.prefix(N_best).sorted(by: >)

            values.indices.dropFirst(N_best).forEach {(index: Int) in
                let value = values[index]
                // 追加すべきindexを取得する
                // let index = binaryLastIndex(sorted: topN, largerThan: value) &+ 1
                let index = (topN.lastIndex(where: {$0 >= value}) ?? -1) &+ 1
                if index == N_best {
                    return
                }
                topN.insert(value, at: index)
                topN.removeLast()
            }
        }
        print(topN.count, topN.prefix(10))
    }

    // N_best: 10000 [0.055492, 0.027200, 0.019898, 0.018306, 0.018257, 0.018005, 0.018124, 0.018117, 0.018109, 0.018046]
    func testperformanceLastIndexImoroved() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        var topN: [Int] = []
        measure {
            topN = values.suffix(N_best)
            values.indices.dropLast(N_best).forEach {(index: Int) in
                let value = values[index]
                // 追加すべきindexを取得する
                if let lastindex = topN.lastIndex(where: {$0 >= value}) {
                    topN.insert(value, at: lastindex &+ 1)
                    // nilなのは、条件を満たすindexがなかったとき
                } else {
                    topN.insert(value, at: 0)
                }
                // カウントがオーバーしている場合は除去する
                topN.removeLast()
            }
        }
        print(topN.count, topN.prefix(10))
    }

    func testperformanceMin() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        var topN: [Int] = []
        measure {
            topN = values.suffix(N_best)
            var curMinElement: EnumeratedSequence<[Int]>.Element?
            values.indices.dropLast(N_best).forEach {(index: Int) in
                let value = values[index]

                if let minElement = curMinElement {
                    if minElement.element < value {
                        topN[minElement.offset] = value
                        curMinElement = nil
                    }
                    return
                }

                if let minElement = topN.enumerated().min(by: {$0.element < $1.element}) {
                    if minElement.element < value {
                        topN[minElement.offset] = value
                        return
                    }
                    curMinElement = minElement
                }
            }
        }
        print(topN.count, topN.prefix(10))
    }

    func testperformanceMin2() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        var topN: [Int] = []
        measure {
            topN = values.suffix(N_best)
            var curMinElement: EnumeratedSequence<[Int]>.Element?
            values.indices.dropLast(N_best).forEach {(index: Int) in
                let value = values[index]

                if let minElement = curMinElement {
                    if minElement.element < value {
                        topN[minElement.offset] = value
                        curMinElement = nil
                    }
                    return
                }

                if let minElement = topN.enumerated().min(by: {$0.element < $1.element}) {
                    if minElement.element < value {
                        topN[minElement.offset] = value
                        return
                    }
                    curMinElement = minElement
                }
            }
        }
        print(topN.count, topN.prefix(10))
    }

    // 最強。結局insertをなるべく使わないのが吉っぽい。
    func testperformanceAppendSort() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        var topN: [Int] = []
        measure {
            topN = values.suffix(N_best).sorted(by: >=)
            values.indices.dropLast(N_best).forEach {(index: Int) in
                let value = values[index]
                if topN.last! < value {
                    topN[N_best - 1] = value
                    topN.sort(by: >=)
                }
            }
        }
        print(topN.count, topN.prefix(10))
    }

    // 最強。結局insertをなるべく使わないのが吉っぽい。
    func testperformanceReduce() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        var topN: [Int] = []
        measure {
            topN = values.indices.dropLast(N_best).indices.reduce(into: values.suffix(N_best).sorted(by: >=)) {array, index in
                let value = values[index]
                if array.last! < value {
                    array[N_best - 1] = value
                    array.sort(by: >=)
                }
            }
        }
        print(topN.count, topN.prefix(10))
    }

    // 最強。結局insertをなるべく使わないのが吉っぽい。
    func testperformanceMyMax() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        var topN: [Int] = []
        measure {
            topN = values.max(count: N_best, by: >=)
        }
        print(topN.count, topN.prefix(10))
    }

    // 最強。結局insertをなるべく使わないのが吉っぽい。
    // N_best: 10000: 論外
    func testperformanceMyMax2() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        measure {
            _ = values.max(count: N_best, by: >=)
        }
    }

    // N_best: 10000 [0.415426, 0.363690, 0.363506, 0.363349, 0.363937, 0.363365, 0.363673, 0.363648, 0.363427, 0.363865]
    func testperformancePartialSort() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        measure {
            let _: [Int] = Array(values.sortedPrefix(N_best, by: >=).prefix(N_best))
        }
    }

    // N_best: 10000 [0.141512, 0.093826, 0.093702, 0.093621, 0.093756, 0.093648, 0.093522, 0.093620, 0.093580, 0.093633]
    func testperformanceSorted() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        measure {
            let _: [Int] = Array(values.sorted(by: >=).prefix(N_best))
        }
    }

    // N_best: 10000 [0.142866, 0.096411, 0.094632, 0.094782, 0.095905, 0.094917, 0.094918, 0.095556, 0.095005, 0.095445]
    func testperformanceSortPrefix() throws {
        let values = (0..<n).map {_ in Int.random(in: 0..<max)}
        var topN: [Int] = []
        measure {
            topN = values.sorted().suffix(N_best)
        }
        print(topN.count, topN.prefix(10))
    }

}

extension Collection {
    @inlinable
    func max(count: Int, by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        if self.isEmpty {
            return []
        }
        return try self.indices.dropLast(count).reduce(into: self.suffix(count).sorted(by: areInIncreasingOrder)) {array, index in
            let value: Element = self[index]
            if try !areInIncreasingOrder(array.last!, value) {
                array[count - 1] = value
                try array.sort(by: areInIncreasingOrder)
            }
        }
    }
}
/*
 extension Collection where Element: Comparable{
 @inlinable
 func max(count: Int) -> [Element] {
 if self.isEmpty{
 return []
 }
 return self.indices.dropLast(count).reduce(into: self.suffix(count).sorted(by: >=)){array, index in
 let value: Element = self[index]
 if array.last! < value{
 array[count - 1] = value
 array.sort(by: >=)
 }
 }
 }
 }
 */
