//
//  LOUDSTest.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/09/30.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import azooKey
import XCTest

extension FastLOUDSUIntTrie {
    static func readBinaryFile_UInt64(path: String) -> [UInt64] {
        do {
            let binaryData = try Data(contentsOf: URL(fileURLWithPath: path))
            let ui64array = binaryData.withUnsafeBytes {pointer -> [UInt64] in
                return Array(
                    UnsafeBufferPointer(
                        start: pointer.baseAddress!.assumingMemoryBound(to: UInt64.self),
                        count: pointer.count / MemoryLayout<UInt64>.size
                    )
                )
            }
            return ui64array
        } catch {
            print("Failed to read the file.")
            return []
        }

    }
}

class LOUDSTest: XCTestCase {
    func build(_ identifier: String) -> FastLOUDSUIntTrie? {
        let nodeIndex2Characters: [Character]
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: identifier, ofType: "loudschars2") else {
                print("ファイルが存在しません")
                return nil
            }
            let string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            nodeIndex2Characters = Array(string)
        } catch let error {
            print("ファイルが存在しません: \(error)")
            return nil
        }

        guard let path = Bundle(for: type(of: self)).path(forResource: identifier, ofType: "louds") else {
            print("ファイルが存在しません")
            return nil
        }

        let bytes = FastLOUDSUIntTrie.readBinaryFile_UInt64(path: path).map {$0.littleEndian}
        return FastLOUDSUIntTrie(bytes: bytes, nodeIndex2Character: nodeIndex2Characters)
    }

    func getData(_ identifier: String, indices: [Int]) -> [String] {
        let data: Data
        do {
            guard let path = Bundle(for: type(of: self)).path(forResource: identifier, ofType: "loudstxt") else {
                return []
            }
            data = try Data(contentsOf: URL(fileURLWithPath: path))
        } catch let error {
            print("ファイルが存在しません: \(error)")
            data = Data()
        }

        var indicesIterator = indices.sorted().makeIterator()
        guard var targetIndex = indicesIterator.next() else {
            return []
        }
        let bytes: [[UInt8]] = data.withUnsafeBytes {
            var results: [[UInt8]] = []
            var result: [UInt8] = []
            let newLineNumber = UInt8(ascii: "\n")
            var count = 0

            for byte in $0 {
                let isNewLine = byte == newLineNumber
                if count == targetIndex && !isNewLine {
                    result.append(byte)
                }

                if count > targetIndex {
                    if result.count != 1 || result[0] != newLineNumber {
                        results.append(result)
                    }
                    if let _targetIndex = indicesIterator.next() {
                        result = []
                        targetIndex = _targetIndex
                        if count == targetIndex {
                            result = [byte]
                        }
                    } else {
                        break
                    }
                }

                count &+= isNewLine ? 1:0
            }
            return results
        }
        return bytes.compactMap {String(bytes: $0, encoding: .utf8)}

    }

    func testPerformanceBuild() throws {
        print()
        self.measure {
            let louds = self.build("キ")
        }
    }

    func testPerformanceSearch() throws {
        print()
        self.measure {
            guard let louds = self.build("キ") else {
                print("LOUDSの構築に失敗")
                return
            }
            if let index = louds.searchNodeIndex(chars: ["キ", "ョ", "ウ", "シ"]) {
                let value = index.quotientAndRemainder(dividingBy: 2000)
                let data = getData("キ\(value.quotient*2000)", indices: [value.remainder]).flatMap {$0.components(separatedBy: ",")}
                print(data.count)
            }
        }

    }
    /*childIndices results
     childIndices:  [0.003966, 0.003871, 0.003893, 0.005317, 0.005639, 0.005061, 0.003956, 0.003951, 0.003949, 0.003960]
     childIndices3: [0.026881, 0.015948, 0.011986, 0.010735, 0.009149, 0.008309, 0.007745, 0.007742, 0.007682, 0.007682]
     childIndices4: [0.017340, 0.020187, 0.014859, 0.012022, 0.010269, 0.009049, 0.008376, 0.008362, 0.008397, 0.008356]
     childIndices5: [0.010012, 0.012305, 0.009379, 0.009058, 0.007051, 0.006482, 0.006499, 0.005394, 0.005330, 0.004866]
     tuned:         [0.015016, 0.012686, 0.010262, 0.008744, 0.007126, 0.007118, 0.006102, 0.005849, 0.005434, 0.005099]
     tuned_2:       [0.006818, 0.005072, 0.004275, 0.004860, 0.005390, 0.005245, 0.003739, 0.003741, 0.003783, 0.003755]
     */

    /*childNodeIndices results
     1: [0.005932, 0.004631, 0.004751, 0.005673, 0.005709, 0.003962, 0.003947, 0.003956, 0.003939, 0.003982]
     2: [0.005419, 0.004603, 0.004453, 0.005292, 0.005268, 0.003948, 0.003687, 0.003727, 0.003692, 0.003661]
     3: [0.002337, 0.002246, 0.002241, 0.002268, 0.002139, 0.002076, 0.002035, 0.002073, 0.001968, 0.001888]
     */

    func testPerformanceChildIndices() throws {
        guard let louds = self.build("キ") else {
            print("LOUDSの構築に失敗")
            return
        }
        self.measure {
            for i in 0..<20000 {
                _ = louds.childNodeIndices3(from: i)
            }
        }

    }

    func testPerformancePurePrefix() throws {
        guard let louds = self.build("キ") else {
            print("LOUDSの構築に失敗")
            return
        }
        self.measure {
            let indices = louds.prefixNodeIndices(chars: ["キ", "ョ"])
            print(indices.count)
        }

    }

    func testPerformancePrefix() throws {
        print()
        self.measure {
            guard let louds = self.build("キ") else {
                print("LOUDSの構築に失敗")
                return
            }
            let indices = louds.prefixNodeIndices(chars: ["キ", "ョ"])
            let dict = [Int: [Int]].init(grouping: indices, by: {$0/2000})
            let data = dict.flatMap {
                getData("キ\($0.key &* 2000)", indices: $0.value.map {$0%2000})
            }
            print(data.count)
        }

    }

    func testPerformanceByfix() throws {
        print()
        self.measure {
            guard let louds = self.build("キ") else {
                print("LOUDSの構築に失敗")
                return
            }
            let indices = louds.byfixNodeIndices(chars: ["キ", "ョ", "ウ", "カ", "シ"])
            let dict = [Int: [Int]].init(grouping: indices, by: {$0/2000})
            let data = dict.flatMap {
                getData("キ\($0.key &* 2000)", indices: $0.value.map {$0%2000})
            }
            print(data.count)
            // print(data)
            // print(data.map{$0.components(separatedBy: ",").count})
        }

    }
}
