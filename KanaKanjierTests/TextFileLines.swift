//
//  TextFileLines.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/10/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import XCTest

class TextFileLines: XCTestCase {
    func components(indices: [Int]){
        let string:String
        do{
            guard let path = Bundle(for: type(of: self)).path(forResource: "aozora", ofType: "csv") else {
                print("ファイルが存在しません")
                return
            }
            print("ファイルが存在しました")

            string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        } catch let error {
            print("ファイルが存在しません: \(error)")
            string = ""
        }

        let splited = string.components(separatedBy: "\n")
        let strings = indices.map{splited[$0]}
        print(strings.count)
    }


    func scans(indices: [Int]){
        let data:Data
        do{
            guard let path = Bundle(for: type(of: self)).path(forResource: "aozora", ofType: "csv") else {
                print("ファイルが存在しません")
                return
            }
            print("ファイルが存在しました")
            let url = URL(fileURLWithPath: path)
            data = try Data(contentsOf: url)
        } catch let error {
            print("ファイルが存在しません: \(error)")
            data = Data()
        }
        var indicesIterator = indices.sorted().makeIterator()
        guard var targetIndex = indicesIterator.next() else{
            return
        }
        let strings: [String] = data.withUnsafeBytes {
            var results:[String] = []
            results.reserveCapacity(indices.count)
            var result:[UInt8] = []
            var count = 0
            let newLineNumber = UInt8(ascii: "\n")
            for byte in $0{
                let isNewLine = byte == newLineNumber
                if count == targetIndex && !isNewLine{
                    result.append(byte)
                }

                if count > targetIndex{
                    if let string = String(bytes: result, encoding: .utf8){
                        results.append(string)
                    }
                    result = []
                    if let _targetIndex = indicesIterator.next(){
                        targetIndex = _targetIndex
                        if count == targetIndex{
                            result.append(byte)
                        }
                    }else{
                        break
                    }
                }

                if isNewLine{
                    count = count &+ 1
                }
            }
            return results
        }

        print(strings.count)
    }

    func testPerformanceComponents() throws {
        let shuffled = (0..<17000).shuffled()
        let c1 = Array(shuffled.prefix(1))
        let c10 = Array(shuffled.prefix(10))
        let c100 = Array(shuffled.prefix(100))
        let c1000 = Array(shuffled.prefix(1000))
        let c10000 = Array(shuffled.prefix(16000))
        self.measure {
            components(indices: c10000)
        }
    }

    func testPerformanceScan() throws {
        let shuffled = (0..<17000).shuffled()
        let c1 = Array(shuffled.prefix(1))
        let c10 = Array(shuffled.prefix(10))
        let c100 = Array(shuffled.prefix(100))
        let c1000 = Array(shuffled.prefix(1000))
        let c10000 = Array(shuffled.prefix(16000))
        self.measure {
            scans(indices: c10000)
        }
    }

}
