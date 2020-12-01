//
//  Dictionary.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/10/27.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import XCTest

class DictionaryTest: XCTestCase {
    
    func testPerformanceArray() throws{
        let array = (0..<50000).map{$0*7}
        var list: [Int] = []
        self.measure {
            (0..<100).forEach{_ in
                for i in array.indices{
                    list.append(array[i])
                }
            }
        }
    }

    func testPerformanceDictionary() throws{
        let array = [UInt16: Int].init(uniqueKeysWithValues: (0..<50000).map{(UInt16($0),$0*7)})
        var list: [Int] = []
        self.measure {
            (0..<100).forEach{_ in
                for i in UInt16.zero..<50000{
                    list.append(array[i, default: 0])
                }
            }
        }
    }

}
