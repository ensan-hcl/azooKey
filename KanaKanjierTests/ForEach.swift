//
//  ForEach.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/10/01.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import azooKey
import XCTest

class ForEachTest: XCTestCase {

    func testPerformanceForWhere() throws {
        print()
        measure {
            for _ in 0..<1000000 {
                var count = 0
                for i in 0..<10000000 where i.isMultiple(of: 2) || i.isMultiple(of: 3) {
                    count += 1
                }
            }
        }
    }

    func testPerformanceForIf() throws {
        print()
        measure {
            for _ in 0..<1000000 {
                var count = 0
                for i in 0..<10000000 {
                    if i.isMultiple(of: 2) {
                        count += 1
                    }
                }
            }
        }
    }

    func testPerformanceStride() throws {
        print()
        measure {
            var count = 0
            for i in stride(from: 0, to: 10000000, by: 2) {
                count += 1
            }
        }
    }

    func testPerformanceForEachIndices() throws {
        var array: [Int] = []
        let values = (0..<1000000).map {_ in Int.random(in: 0..<1000000)}
        self.measure {
            values.indices.forEach {(i: Int) in
                array.append(values[i]+i)
            }
        }

    }

    func testPerformanceForInIndices() throws {
        var array: [Int] = []
        let values = (0..<1000000).map {_ in Int.random(in: 0..<1000000)}
        self.measure {
            for i in values.indices {
                array.append(values[i]+i)
            }
        }

    }

    // 最適化ありで平均0.285s
    func testPerformanceForIndicesAndValue() throws {
        let values = (0..<100000000).map {_ in Int.random(in: 0..<1000000)}
        var x = 0
        self.measure {
                for index in values.indices {
                    x += values[index] + values[index] + values[index] + values[index] + index + index + index + index
                    x -= values[index] + values[index] + values[index] + values[index] + index + index + index + index
                }
        }
    }

    // 最適化ありで平均0.169s
    // indexとvalueの両方を扱う場面ではenumerated()を使うと良い。
    func testPerformanceForEnumerated() throws {
        let values = (0..<100000000).map {_ in Int.random(in: 0..<1000000)}
        var x = 0
        self.measure {
                for (index, value) in values.enumerated() {
                    x += value + value + value + value + index + index + index + index
                    x -= value + value + value + value + index + index + index + index
                }
        }
    }

}
