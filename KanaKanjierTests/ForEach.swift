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

}
