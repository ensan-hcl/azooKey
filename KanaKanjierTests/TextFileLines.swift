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
    func components(indices: [Int]) {
        let string: String
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: "lines", ofType: "txt") else {
                print("ファイルが存在しません")
                return
            }
            print("ファイルが存在しました")

            string = try String(contentsOfFile: path, encoding: .utf8)
        } catch let error {
            print("ファイルが存在しません: \(error)")
            string = ""
        }

        let splited = string.components(separatedBy: "\n")
        let strings = indices.map {splited[$0]}
        print(strings.count)
    }

    func scans(indices: [Int]) {
        let data: Data
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: "lines", ofType: "txt") else {
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
        guard var targetIndex = indicesIterator.next() else {
            return
        }
        let strings: [String] = data.withUnsafeBytes {
            var results: [String] = []
            results.reserveCapacity(indices.count)
            var result: [UInt8] = []
            var count = 0
            let newLineNumber = UInt8(ascii: "\n")
            for byte in $0 {
                let isNewLine = byte == newLineNumber
                if count == targetIndex && !isNewLine {
                    result.append(byte)
                }

                if count > targetIndex {
                    if let string = String(bytes: result, encoding: .utf8) {
                        results.append(string)
                    }
                    result = []
                    if let _targetIndex = indicesIterator.next() {
                        targetIndex = _targetIndex
                        if count == targetIndex {
                            result.append(byte)
                        }
                    } else {
                        break
                    }
                }

                if isNewLine {
                    count = count &+ 1
                }
            }
            if !result.isEmpty, let string = String(bytes: result, encoding: .utf8) {
                results.append(string)
            }

            return results
        }

        print(strings.count)
    }

    func binary(indices: [Int]) {
        let data: Data
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: "lines", ofType: "binary") else {
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
        let header = data[0 ..< 8192]
        let i32array = header.withUnsafeBytes {pointer -> [Int32] in
            return Array(
                UnsafeBufferPointer(
                    start: pointer.baseAddress!.assumingMemoryBound(to: Int32.self),
                    count: pointer.count / MemoryLayout<Int32>.size
                )
            )
        }
        let strings: [String] = indices.compactMap {(index: Int) in
            let startIndex = Int(i32array[index])
            let endIndex = index == 2047 ? data.endIndex : Int(i32array[index + 1])
            return String(bytes: data[startIndex ..< endIndex], encoding: .utf8)
        }

        print(strings.count)
    }

    func testPerformanceComponents() throws {
        let shuffled = (0..<2048).shuffled()
        let c1 = Array(shuffled.prefix(1))
        let c10 = Array(shuffled.prefix(10))
        let c100 = Array(shuffled.prefix(100))
        let c1000 = Array(shuffled.prefix(1000))
        let c2000 = Array(shuffled.prefix(2000))
        let c2048 = Array(shuffled.prefix(2048))

        self.measure {
            components(indices: c1)
        }
    }

    func testPerformanceScan() throws {
        let shuffled = (0..<2048).shuffled()
        let c1 = Array(shuffled.prefix(1))
        let c10 = Array(shuffled.prefix(10))
        let c100 = Array(shuffled.prefix(100))
        let c1000 = Array(shuffled.prefix(1000))
        let c2000 = Array(shuffled.prefix(10))
        let c2048 = Array(shuffled.prefix(2048))

        self.measure {
            scans(indices: c1)
        }
    }

    func testPerformanceBinary() throws {
        let shuffled = (0..<2048).shuffled()
        let c1 = Array(shuffled.prefix(1))
        let c10 = Array(shuffled.prefix(10))
        let c100 = Array(shuffled.prefix(100))
        let c1000 = Array(shuffled.prefix(1000))
        let c2000 = Array(shuffled.prefix(10))
        let c2048 = Array(shuffled.prefix(2048))

        self.measure {
            binary(indices: c1)
        }
    }

}
