//
//  TxtFileSpliting.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/09/30.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import azooKey
import XCTest

class TextFileSpliting: XCTestCase {

    func testPerformanceChars() throws {
        print()
        self.measure {

            let string: String
            do {
                guard let path = Bundle(for: type(of: self)).path(forResource: "キョ", ofType: "loudschars") else {
                    print("ファイルが存在しません")
                    return
                }
                print("ファイルが存在しました")

                string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                _ = string.components(separatedBy: "\n").map {Character($0)}
            } catch let error {
                print("ファイルが存在しません: \(error)")
                string = ""
            }
        }

    }

    func testPerformanceChars2() throws {
        print()
        self.measure {

            let string: String
            do {
                guard let path = Bundle(for: type(of: self)).path(forResource: "キョ", ofType: "loudschars2") else {
                    print("ファイルが存在しません")
                    return
                }
                print("ファイルが存在しました")

                string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                let _: [Character] = Array(string)
            } catch let error {
                print("ファイルが存在しません: \(error)")
                string = ""
            }
        }

    }
    /*
     func testPerformanceGetNthLine() throws{
     print()
     self.measure {
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

     var indicesIterator = [1000, 2000, 5000, 8000, 10000, 12000, 15000, 17000].sorted().makeIterator()
     var iterator = string.makeIterator()
     var count = 0
     var results:[String] = []
     var result = ""
     guard var targetIndex = indicesIterator.next() else{
     return
     }

     while let char = iterator.next(){
     let isNewline = char.isNewline
     if count == targetIndex && !isNewline{
     result += String(char)
     }

     if count > targetIndex{
     results.append(result)
     result = ""
     if let _targetIndex = indicesIterator.next(){
     targetIndex = _targetIndex
     if count == targetIndex{
     result = String(char)
     }
     }else{
     break
     }
     }

     if isNewline{
     count += 1
     }
     }
     print(results)
     }

     }

     func testPerformanceGetNthLine2() throws{
     print()
     self.measure {

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
     let strings = [1000, 2000, 5000, 8000, 10000, 12000, 15000, 17000].map{splited[$0]}
     print(strings)
     }

     }


     func testPerformanceGetNthLine4() throws{
     print()
     self.measure {

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
     let splited = string.split(separator: "\n", omittingEmptySubsequences: false)
     print(string.count, splited.count)
     let strings = [1000, 2000, 5000, 8000, 10000, 12000, 15000, 17000].map{String(splited[$0])}
     print(strings)
     }

     }

     func testPerformanceGetNthLine3() throws{
     print()
     self.measure {

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

     var indices = [1000, 2000, 5000, 8000, 10000, 12000, 15000, 17000].sorted().makeIterator()
     guard var target = indices.next() else{
     return
     }
     var count = 0
     var result:[String] = []
     string.enumerateLines(invoking: {line, stop in
     if target == count{
     result.append(line)
     if let _target = indices.next(){
     target = _target
     }else{
     stop = true
     }
     }
     count += 1

     })
     print(result)
     }

     }
     */
    func testPerformanceGetNthLine5() throws {
        print()
        self.measure {

            let data: Data
            do {
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

            let bytes = data.withUnsafeBytes {
                $0.split(separator: UInt8(ascii: "\n"), omittingEmptySubsequences: false)
            }
            let result = [1000, 2000, 5000, 8000, 10000, 12000, 15000, 17000].compactMap {String(bytes: bytes[$0], encoding: .utf8)}
            print(result)
        }

    }

    func testPerformanceLoadText() throws {
        print()
        self.measure {
            do {
                guard let path = Bundle(for: type(of: self)).path(forResource: "シ0", ofType: "loudstxt") else {
                    print("ファイルが存在しません")
                    return
                }
                print("ファイルが存在しました")

                let strings = try String(contentsOfFile: path, encoding: .utf8).split(separator: "\n", omittingEmptySubsequences: false)
                _ = (0..<1700).map {strings[$0]}

            } catch let error {
                print("ファイルが存在しません: \(error)")
            }

        }

    }

    func testPerformanceGetNthLine6() throws {
        print()
        self.measure {

            let data: Data
            do {
                guard let path = Bundle(for: type(of: self)).path(forResource: "シ0", ofType: "loudstxt") else {
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

            var indicesIterator = [1000, 2000, 5000, 8000, 10000, 12000, 15000, 17000].sorted().makeIterator()
            guard var targetIndex = indicesIterator.next() else {
                return
            }
            let bytes: [[UInt8]] = data.withUnsafeBytes {
                var results: [[UInt8]] = []
                var result: [UInt8] = []
                var count = 0

                for byte in $0 {
                    let isNewLine = byte == UInt8(ascii: "\n")
                    if count == targetIndex && !isNewLine {
                        result.append(byte)
                    }

                    if count > targetIndex {
                        results.append(result)
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
                        count = count + 1
                    }
                }
                return results
            }

            print(bytes.compactMap {String(bytes: $0, encoding: .utf8)})

            /*
             let index = 400000

             let bytes:[UInt8] = data.withUnsafeBytes {
             //$0.split(separator: UInt8(ascii: "\n"), omittingEmptySubsequences: false)
             var count = 0
             var result = [UInt8].init()
             for byte in $0{
             let isNewLine = byte == UInt8(ascii: "\n")
             if count == index && !isNewLine{
             result.append(byte)
             }
             if count > index{
             break
             }
             if isNewLine{
             count += 1
             }
             }
             return result
             }
             let result = String(bytes: bytes, encoding: .utf8)
             print(result)
             */
        }

    }
    func testPerformanceGetNthLine7() throws {
        print()
        self.measure {

            let data: Data
            do {
                guard let path = Bundle(for: type(of: self)).path(forResource: "シ0", ofType: "loudstxt") else {
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
            let indices = (0..<1700)
            var indicesIterator = indices.makeIterator()
            guard var targetIndex = indicesIterator.next() else {
                return
            }
            let newLineNumber = UInt8(ascii: "\n")
            let _: [String] = data.withUnsafeBytes {
                var results: [String] = []
                results.reserveCapacity(indices.count)
                var result: [UInt8] = []
                var count = 0
                for byte in $0 {
                    let isNewLine = byte == newLineNumber
                    if count == targetIndex && !isNewLine {
                        result.append(byte)
                        continue
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
                        count &+= 1
                    }
                }
                return results
            }

        }
    }

    func testPerformanceGetNthLine8() throws {
        print()

        self.measure {

            let data: Data
            do {
                guard let path = Bundle(for: type(of: self)).path(forResource: "シ0", ofType: "loudstxt") else {
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
            let indices = (0..<1700)
            var indicesIterator = indices.makeIterator()
            guard var targetIndex = indicesIterator.next() else {
                return
            }
            let newLineNumber = UInt8(ascii: "\n")

            let _: [String] = data.withUnsafeBytes {
                var results: [String] = []
                results.reserveCapacity(indices.count)
                var result: [UInt8] = []
                var count = 0
                for byte in $0 {
                    let isNewLine = byte == newLineNumber
                    if count == targetIndex && !isNewLine {
                        result.append(byte)
                        continue
                    }

                    if count > targetIndex {
                        results.append(String(decoding: result, as: UTF8.self))
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
                        count &+= 1
                    }
                }
                return results
            }
        }
    }

    func testPerformanceGetNthLine9() throws {
        print()

        self.measure {

            var data: String
            do {
                guard let path = Bundle(for: type(of: self)).path(forResource: "シ0", ofType: "loudstxt") else {
                    print("ファイルが存在しません")
                    return
                }
                print("ファイルが存在しました")
                let url = URL(fileURLWithPath: path)
                data = try String(contentsOf: url, encoding: .utf8)
            } catch let error {
                print("ファイルが存在しません: \(error)")
                data = String()
            }
            let indices = (0..<1700)
            var indicesIterator = indices.makeIterator()
            guard var targetIndex = indicesIterator.next() else {
                return
            }
            let newLineNumber = UInt8(ascii: "\n")

            let _: [String] = data.withUTF8 {
                var results: [String] = []
                results.reserveCapacity(indices.count)
                var result: [UInt8] = []
                var count = 0
                for byte in $0 {
                    let isNewLine = byte == newLineNumber
                    if count == targetIndex && !isNewLine {
                        result.append(byte)
                        continue
                    }

                    if count > targetIndex {
                        results.append(String(decoding: result, as: UTF8.self))
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
                        count &+= 1
                    }
                }
                return results
            }
        }
    }

}
