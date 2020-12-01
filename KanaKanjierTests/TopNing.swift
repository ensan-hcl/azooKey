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
    func testperformanceLastIndex() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var topN: [Int] = []
        let N_best = 100
        measure{
            values.indices.forEach{(index: Int) in
                let value = values[index]
                //追加すべきindexを取得する
                if let lastindex = topN.lastIndex(where: {$0 >= value}){
                    topN.insert(value, at: lastindex &+ 1)
                    //nilなのは、条件を満たすindexがなかったとき
                }else{
                    topN.insert(value, at: 0)
                }
                //カウントがオーバーしている場合は除去する
                if topN.count == N_best &+ 1{
                    topN.removeLast()
                }
            }
        }
        print(topN.count)
    }

    func testperformanceLastIndexImoroved() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var topN: [Int] = []
        let N_best = 100
        measure{
            topN = values.suffix(N_best)
            values.indices.dropLast(N_best).forEach{(index: Int) in
                let value = values[index]
                //追加すべきindexを取得する
                if let lastindex = topN.lastIndex(where: {$0 >= value}){
                    topN.insert(value, at: lastindex &+ 1)
                    //nilなのは、条件を満たすindexがなかったとき
                }else{
                    topN.insert(value, at: 0)
                }
                //カウントがオーバーしている場合は除去する
                topN.removeLast()
            }
        }
        print(topN.count)
    }

    func testperformanceMin() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var topN: [Int] = []
        let N_best = 100
        measure{
            topN = values.suffix(N_best)
            var curMinElement: EnumeratedSequence<[Int]>.Element?  = nil
            values.indices.dropLast(N_best).forEach{(index: Int) in
                let value = values[index]

                if let minElement = curMinElement{
                    if minElement.element < value{
                        topN[minElement.offset] = value
                        curMinElement = nil
                    }
                    return
                }

                if let minElement = topN.enumerated().min{$0.element < $1.element}{
                    if minElement.element < value{
                        topN[minElement.offset] = value
                        return
                    }
                    curMinElement = minElement
                }
            }
        }
        print(topN.count, topN.prefix(10))
    }

    func testperformanceMin2() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var topN: [Int] = []
        let N_best = 100000
        measure{
            topN = values.suffix(N_best)
            var curMinElement: EnumeratedSequence<[Int]>.Element?  = nil
            values.indices.dropLast(N_best).forEach{(index: Int) in
                let value = values[index]

                if let minElement = curMinElement{
                    if minElement.element < value{
                        topN[minElement.offset] = value
                        curMinElement = nil
                    }
                    return
                }

                if let minElement = topN.enumerated().min{$0.element < $1.element}{
                    if minElement.element < value{
                        topN[minElement.offset] = value
                        return
                    }
                    curMinElement = minElement
                }
            }
        }
        print(topN.count, topN.prefix(10))
    }


    //最強。結局insertをなるべく使わないのが吉っぽい。
    func testperformanceAppendSort() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var topN: [Int] = []
        let N_best = 100
        measure{
            topN = values.suffix(N_best).sorted(by: >=)
            values.indices.dropLast(N_best).forEach{(index: Int) in
                let value = values[index]
                if topN.last! < value{
                    topN[N_best - 1] = value
                    topN.sort(by: >=)
                }
            }
        }
        print(topN.count, topN.prefix(10))
    }

    //最強。結局insertをなるべく使わないのが吉っぽい。
    func testperformanceReduce() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var topN: [Int] = []
        let N_best = 100
        measure{
            topN = values.indices.dropLast(N_best).indices.reduce(into: values.suffix(N_best).sorted(by: >=)){array, index in
                let value = values[index]
                if array.last! < value{
                    array[N_best - 1] = value
                    array.sort(by: >=)
                }
            }
        }
        print(topN.count, topN.prefix(10))
    }

    //最強。結局insertをなるべく使わないのが吉っぽい。
    func testperformanceMyMax() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var topN: [Int] = []
        let N_best = 100
        measure{
            topN = values.max(count: N_best, by: >=)
        }
        print(topN.count, topN.prefix(10))
    }

    //最強。結局insertをなるべく使わないのが吉っぽい。
    func testperformanceMyMax2() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        let n = 10000
        measure{
            let topN = values.max(count: n, by: >=)
        }
    }


    func testperformancePartialSort() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        let N_best = 100000
        measure{
            let topN: [Int] = Array(values.partiallySorted(N_best, by: >=).prefix(N_best))
        }
    }

    func testperformanceSorted() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        let N_best = 100000
        measure{
            let topN: [Int] = Array(values.sorted(by: >=).prefix(N_best))
        }
    }

    func testperformanceSortPrefix() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var topN: [Int] = []
        let N_best = 100
        measure{
            topN = values.sorted().suffix(N_best)
        }
        print(topN.count, topN.prefix(10))
    }

}

extension Collection{
    @inlinable
    func max(count: Int, by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        if self.isEmpty{
            return []
        }
        return try self.indices.dropLast(count).reduce(into: self.suffix(count).sorted(by: areInIncreasingOrder)){array, index in
            let value: Element = self[index]
            if try !areInIncreasingOrder(array.last!, value){
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
