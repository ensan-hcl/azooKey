//
//  extension Data.swift
//  Keyboard
//
//  Created by β α on 2020/09/30.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
/*
extension Array{
    init(path: String, options: Data.ReadingOptions = []) throws {
        do {
            let binaryData = try Data(contentsOf: URL(fileURLWithPath: path), options: options) //2度読み込むことはないのでキャッシュ不要
            let array = binaryData.withUnsafeBytes{pointer -> Array<Element> in
                Array(
                    UnsafeBufferPointer(
                        start: pointer.baseAddress!.assumingMemoryBound(to: Element.self),
                        count: pointer.count / MemoryLayout<Element>.size
                    )
                )
            }
            self = array
        } catch let error {
            print("Failed to read the file.")
            throw error
        }

    }
}
*/
extension LOUDS{
    private static func loadLOUDSBinary(from url: URL) -> [UInt64] {
        do {
            let binaryData = try Data(contentsOf: url, options: [.uncached]) //2度読み込むことはないのでキャッシュ不要
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

    private static func getLOUDSURL(_ identifier: String) -> (chars: URL, louds: URL){
        
        if identifier == "user"{
            let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
            return (
                directory.appendingPathComponent("user.loudschars2"),
                directory.appendingPathComponent("user.louds")
            )
        }
        return (
            URL(fileURLWithPath: Bundle.main.bundlePath + "/\(identifier).loudschars2"),
            URL(fileURLWithPath: Bundle.main.bundlePath + "/\(identifier).louds")
        )
    }

    private static func getLoudstxtPath(_ identifier: String) -> String {
        if identifier.hasPrefix("user"){
            let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
            return directory.appendingPathComponent("\(identifier).loudstxt").path
        }
        return Bundle.main.bundlePath + "/\(identifier).loudstxt"
    }

    internal static func build(_ identifier: String) -> LOUDS? {
        let (charsURL, loudsURL) = Self.getLOUDSURL(identifier)
        let nodeIndex2ID: [UInt8]
        do{
            nodeIndex2ID = try Array(Data(contentsOf: charsURL, options: [.uncached]))   //2度読み込むことはないのでキャッシュ不要
        } catch let error {
            print("ファイルが存在しません: \(error)")
            nodeIndex2ID = []
        }

        let bytes = LOUDS.loadLOUDSBinary(from: loudsURL).map{$0.littleEndian}
        let louds = LOUDS(bytes: bytes, nodeIndex2ID: nodeIndex2ID)
        return louds
    }
    
    internal static func getData(_ identifier: String, indices: [Int]) -> [String] {
        let data: Data
        do{
            let path = Self.getLoudstxtPath(identifier)
            data = try Data(contentsOf: URL(fileURLWithPath: path))
        } catch let error {
            print("ファイルが存在しません: \(error)")
            data = Data()
        }

        var indicesIterator = indices.sorted().makeIterator()
        guard var targetIndex = indicesIterator.next() else{
            return []
        }
        let newLineNumber = UInt8(ascii: "\n")

        let strings: [String] = data.withUnsafeBytes {
            var results: [String] = []
            results.reserveCapacity(indices.count)
            var result: [UInt8] = []
            var count = 0
            for byte in $0{
                let isNewLine = byte == newLineNumber
                if count == targetIndex && !isNewLine{
                    result.append(byte)
                    continue
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
            if !result.isEmpty, let string = String(bytes: result, encoding: .utf8){
                results.append(string)
            }
            return results
        }

        return strings

    }
}
