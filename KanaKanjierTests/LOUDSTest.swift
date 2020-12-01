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

extension FastLOUDSUIntTrie{
    static func readBinaryFile_UInt64(path: String) -> [UInt64] {
        do {
            let binaryData = try Data(contentsOf: URL(fileURLWithPath: path))
            let ui64array = binaryData.withUnsafeBytes{pointer -> [UInt64] in
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
        do{
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

        let bytes = FastLOUDSUIntTrie.readBinaryFile_UInt64(path: path).map{$0.littleEndian}
        return FastLOUDSUIntTrie(bytes: bytes, nodeIndex2Character: nodeIndex2Characters)
    }
    
    func getData(_ identifier: String, indices: [Int]) -> [String] {
        let data: Data
        do{
            guard let path = Bundle(for: type(of: self)).path(forResource: identifier, ofType: "loudstxt") else {
                return []
            }
            data = try Data(contentsOf: URL(fileURLWithPath: path))
        } catch let error {
            print("ファイルが存在しません: \(error)")
            data = Data()
        }
        
        var indicesIterator = indices.sorted().makeIterator()
        guard var targetIndex = indicesIterator.next() else{
            return []
        }
        let bytes: [[UInt8]] = data.withUnsafeBytes {
            var results: [[UInt8]] = []
            var result: [UInt8] = []
            let newLineNumber = UInt8(ascii: "\n")
            var count = 0
            
            for byte in $0{
                let isNewLine = byte == newLineNumber
                if count == targetIndex && !isNewLine{
                    result.append(byte)
                }
                
                if count > targetIndex{
                    if result.count != 1 || result[0] != newLineNumber{
                        results.append(result)
                    }
                    if let _targetIndex = indicesIterator.next(){
                        result = []
                        targetIndex = _targetIndex
                        if count == targetIndex{
                            result = [byte]
                        }
                    }else{
                        break
                    }
                }
                
                count &+= isNewLine ? 1:0
            }
            return results
        }
        return bytes.compactMap{String(bytes: $0, encoding: .utf8)}

    }


    func testPerformanceBuild() throws{
        print()
        self.measure {
            let louds = self.build("キ")
        }
    }
    
    func testPerformanceSearch() throws{
        print()
        self.measure {
            guard let louds = self.build("キ") else{
                print("LOUDSの構築に失敗")
                return
            }
            if let index = louds.searchNodeIndex(chars: ["キ","ョ","ウ","シ"]){
                let value = index.quotientAndRemainder(dividingBy: 2000)
                let data = getData("キ\(value.quotient*2000)", indices: [value.remainder]).flatMap{$0.components(separatedBy: ",")}
                print(data.count)
            }
        }
        
    }
    
    func testPerformanceChildIndices() throws{
        print()
        self.measure {
            guard let louds = self.build("キ") else{
                print("LOUDSの構築に失敗")
                return
            }
            
            for i in 0..<20000{
                let c1 = louds.childNodeIndices(from: i)
                let c2 = louds.childNodeIndices2(from: i)
                if c1 != c2{
                    print(i, c1, c2)
                }
            }
            print("finish")
        }
        
    }


    func testPerformancePurePrefix() throws{
        guard let louds = self.build("キ") else{
            print("LOUDSの構築に失敗")
            return
        }
        self.measure {
            let indices = louds.prefixNodeIndices(chars: ["キ","ョ"])
            print(indices.count)
        }
        
    }

    func testPerformancePrefix() throws{
        print()
        self.measure {
            guard let louds = self.build("キ") else{
                print("LOUDSの構築に失敗")
                return
            }
            let indices = louds.prefixNodeIndices(chars: ["キ","ョ"])
            let dict = [Int: [Int]].init(grouping: indices, by: {$0/2000})
            let data = dict.flatMap{
                getData("キ\($0.key &* 2000)", indices: $0.value.map{$0%2000})
            }
            print(data.count)
        }
        
    }
    
    
    func testPerformanceByfix() throws{
        print()
        self.measure {
            guard let louds = self.build("キ") else{
                print("LOUDSの構築に失敗")
                return
            }
            let indices = louds.byfixNodeIndices(chars: ["キ","ョ","ウ","カ","シ"])
            let dict = [Int: [Int]].init(grouping: indices, by: {$0/2000})
            let data = dict.flatMap{
                getData("キ\($0.key &* 2000)", indices: $0.value.map{$0%2000})
            }
            print(data.count)
            //print(data)
            //print(data.map{$0.components(separatedBy: ",").count})
        }
        
    }
}
