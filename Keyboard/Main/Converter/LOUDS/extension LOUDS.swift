//
//  extension Data.swift
//  Keyboard
//
//  Created by β α on 2020/09/30.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

extension LOUDS {
    private static let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
    private static let bundleURL = Bundle.main.bundleURL

    private static func loadLOUDSBinary(from url: URL) -> [UInt64]? {
        do {
            let binaryData = try Data(contentsOf: url, options: [.uncached]) // 2度読み込むことはないのでキャッシュ不要
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
            debug(error)
            return nil
        }
    }

    private static func getLOUDSURL(_ identifier: String) -> (chars: URL, louds: URL) {

        if identifier == "user"{
            return (
                containerURL.appendingPathComponent("user.loudschars2", isDirectory: false),
                containerURL.appendingPathComponent("user.louds", isDirectory: false)
            )
        }
        if identifier == "memory"{
            return (
                LongTermLearningMemory.directoryURL.appendingPathComponent("memory.loudschars2", isDirectory: false),
                LongTermLearningMemory.directoryURL.appendingPathComponent("memory.louds", isDirectory: false)
            )
        }
        return (
            bundleURL.appendingPathComponent("\(identifier).loudschars2", isDirectory: false),
            bundleURL.appendingPathComponent("\(identifier).louds", isDirectory: false)
        )
    }

    private static func getLoudstxt3URL(_ identifier: String) -> URL {
        if identifier.hasPrefix("user") {
            return containerURL.appendingPathComponent("\(identifier).loudstxt3", isDirectory: false)
        }
        if identifier.hasPrefix("memory") {
            return LongTermLearningMemory.directoryURL.appendingPathComponent("\(identifier).loudstxt3", isDirectory: false)
        }
        return bundleURL.appendingPathComponent("\(identifier).loudstxt3", isDirectory: false)
    }

    internal static func build(_ identifier: String) -> LOUDS? {
        let (charsURL, loudsURL) = getLOUDSURL(identifier)
        let nodeIndex2ID: [UInt8]
        do {
            nodeIndex2ID = try Array(Data(contentsOf: charsURL, options: [.uncached]))   // 2度読み込むことはないのでキャッシュ不要
        } catch {
            debug("ファイルが存在しません: \(error)")
            return nil
        }

        if let bytes = LOUDS.loadLOUDSBinary(from: loudsURL) {
            let louds = LOUDS(bytes: bytes.map {$0.littleEndian}, nodeIndex2ID: nodeIndex2ID)
            return louds
        }
        return nil
    }

    @inlinable
    static func parseBinary(binary: Data) -> [DicdataElement] {
        // 最初の2byteがカウント
        let count = binary[binary.startIndex ..< binary.startIndex + 2].withUnsafeBytes {pointer -> [UInt16] in
            return Array(
                UnsafeBufferPointer(
                    start: pointer.baseAddress!.assumingMemoryBound(to: UInt16.self),
                    count: pointer.count / MemoryLayout<UInt16>.size
                )
            )
        }[0]
        var index = binary.startIndex + 2
        var dicdata: [DicdataElement] = []
        dicdata.reserveCapacity(Int(count))
        for _ in 0 ..< count {
            let ids = binary[index ..< index + 6].withUnsafeBytes {pointer -> [UInt16] in
                return Array(
                    UnsafeBufferPointer(
                        start: pointer.baseAddress!.assumingMemoryBound(to: UInt16.self),
                        count: pointer.count / MemoryLayout<UInt16>.size
                    )
                )
            }
            let value = binary[index + 6 ..< index + 10].withUnsafeBytes {pointer -> [Float32] in
                return Array(
                    UnsafeBufferPointer(
                        start: pointer.baseAddress!.assumingMemoryBound(to: Float32.self),
                        count: pointer.count / MemoryLayout<Float32>.size
                    )
                )
            }[0]
            dicdata.append(DicdataElement(word: "", ruby: "", lcid: Int(ids[0]), rcid: Int(ids[1]), mid: Int(ids[2]), value: PValue(value)))
            index += 10
        }

        let substrings = binary[index...].split(separator: UInt8(ascii: "\t"), omittingEmptySubsequences: false)
        guard let ruby = String(data: substrings[0], encoding: .utf8) else {
            debug("getDataForLoudstxt3: failed to parse", dicdata)
            return []
        }
        for (index, substring) in substrings[1...].enumerated() {
            guard let word = String(data: substring, encoding: .utf8) else {
                debug("getDataForLoudstxt3: failed to parse", ruby)
                continue
            }
            withMutableValue(&dicdata[index]) {
                $0.ruby = ruby
                $0.word = word.isEmpty ? ruby : word
            }
        }
        return dicdata

    }

    internal static func getDataForLoudstxt3(_ identifier: String, indices: [Int]) -> [DicdataElement] {

        let binary: Data
        do {
            let url = getLoudstxt3URL(identifier)
            binary = try Data(contentsOf: url)
        } catch {
            debug("getDataForLoudstxt3: \(error)")
            return []
        }

        let lc = binary[0..<2].withUnsafeBytes {pointer -> [UInt16] in
            return Array(
                UnsafeBufferPointer(
                    start: pointer.baseAddress!.assumingMemoryBound(to: UInt16.self),
                    count: pointer.count / MemoryLayout<UInt16>.size
                )
            )
        }[0]

        let header_endIndex: UInt32 = 2 + UInt32(lc) * UInt32(MemoryLayout<UInt32>.size)
        let i32array = binary[2..<header_endIndex].withUnsafeBytes {(pointer: UnsafeRawBufferPointer) -> [UInt32] in
            return Array(
                UnsafeBufferPointer(
                    start: pointer.baseAddress!.assumingMemoryBound(to: UInt32.self),
                    count: pointer.count / MemoryLayout<UInt32>.size
                )
            )
        }

        let result: [DicdataElement] = indices.flatMap {(index: Int) -> [DicdataElement] in
            let startIndex = Int(i32array[index])
            let endIndex = index == (lc-1) ? binary.endIndex : Int(i32array[index + 1])
            return parseBinary(binary: binary[startIndex ..< endIndex])
        }
        return result
    }
}
