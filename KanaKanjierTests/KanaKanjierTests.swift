//
//  KanaKanjierTests.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/09/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import XCTest
import azooKey

class KanaKanjierTests: XCTestCase {
    func ReadBinaryFile_UInt64(path: String) -> [UInt64] {
        let dataURL = URL(fileURLWithPath: path)
        var binaryData = Data()
        do {
            binaryData = try Data(contentsOf: dataURL, options: [])

        } catch {
            print("Failed to read the file.")
            return []
        }
        let _ui64array = binaryData.withUnsafeBytes{ pointer -> [UInt64] in
            print(pointer)
            return Array(
                UnsafeBufferPointer(
                    start : pointer.baseAddress!.assumingMemoryBound( to: UInt64.self ),
                    count : pointer.count / MemoryLayout<UInt64>.size
                )
            )
        }
        return _ui64array
    }

    func buildFastLOUDS() -> (louds: FastLOUDSUIntTrie, data: [String])? {
        let nodeIndex2Characters: [Character]
        do{
            guard let path = Bundle(for: type(of: self)).path(forResource: "キョ", ofType: "loudschars") else {
                print("ファイルが存在しません")
                return nil
            }
            print("ファイルが存在しました")

            let string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            nodeIndex2Characters = string.components(separatedBy: "\n").map{Character($0)}
        } catch let error {
            print("ファイルが存在しません: \(error)")
            nodeIndex2Characters = []
        }
        
        let data: [String]
        do{
            guard let path = Bundle(for: type(of: self)).path(forResource: "キョ", ofType: "loudstxt") else {
                print("ファイルが存在しません")
                return nil
            }
            print("ファイルが存在しました")

            let string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            data = string.components(separatedBy: "\n")
        } catch let error {
            print("ファイルが存在しません: \(error)")
            data = []
        }

        guard let path = Bundle(for: type(of: self)).path(forResource: "キョ", ofType: "louds") else {
            print("ファイルが存在しません")
            return nil
        }
        print("ファイルが存在しました")

        let bytes = ReadBinaryFile_UInt64(path: path).map{$0.littleEndian}
        let louds = FastLOUDSUIntTrie(bytes: bytes, nodeIndex2Character: nodeIndex2Characters)
        return (louds, data)
    }
    


    func testPerformanceBuildingFastLOUDS() throws{
        print("ビルドのテスト")
        self.measure {
            let nodeIndex2Characters: [Character]
            do{
                guard let path = Bundle(for: type(of: self)).path(forResource: "キョ", ofType: "loudschars") else {
                    print("ファイルが存在しません")
                    return
                }

                let string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                nodeIndex2Characters = string.components(separatedBy: "\n").map{Character($0)}
            } catch {
                print("ファイルが存在しません: \(error)")
                nodeIndex2Characters = []
            }
            
            let data: [String]
            do{
                guard let path = Bundle(for: type(of: self)).path(forResource: "キョ", ofType: "loudstxt") else {
                    print("ファイルが存在しません")
                    return
                }
                print("ファイルが存在しました")

                let string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                data = string.components(separatedBy: "\n")
            } catch {
                print("ファイルが存在しません: \(error)")
                data = []
            }

            guard let path = Bundle(for: type(of: self)).path(forResource: "キョ", ofType: "louds") else {
                print("ファイルが存在しません")
                return
            }

            let bytes = ReadBinaryFile_UInt64(path: path).map{$0.littleEndian}
            let louds = FastLOUDSUIntTrie(bytes: bytes, nodeIndex2Character: nodeIndex2Characters)
        }
    }

    func testPerformanceSearchingFastLOUDS() throws{
        let data = buildFastLOUDS()!
        self.measure {
            let index = data.louds.searchNodeIndex(chars: ["キ","ョ","ウ"]) ?? 0
            let data = data.data[index].components(separatedBy: ",").map{$0.components(separatedBy: "\t")[1]}
            print(data)
        }
    }
    
    func testPerformanceSearchingFastLOUDS2() throws{
        let data = buildFastLOUDS()!
        self.measure {
            let index = data.louds.searchNodeIndex(chars: ["キ","ョ","ウ","イ","ク","チ","ョ","ウ"]) ?? 0
            let data = data.data[index].components(separatedBy: ",").map{$0.components(separatedBy: "\t")[1]}
            print(data)
        }
    }

    func testPerformancePrefixingFastLOUDS() throws{
        let data = buildFastLOUDS()!
        self.measure {
            let indices = data.louds.prefixNodeIndices(chars: ["キ","ョ","ウ"])
            let data: [String] = indices.flatMap{data.data[$0].components(separatedBy: ",")}.filter{!$0.isEmpty}.map{$0.components(separatedBy: "\t")[1]}
            print(data)
        }
    }
}
