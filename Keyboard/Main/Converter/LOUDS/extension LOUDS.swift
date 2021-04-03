//
//  extension Data.swift
//  Keyboard
//
//  Created by β α on 2020/09/30.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

extension LOUDS {
    static let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
    static let bundleURL = Bundle.main.bundleURL

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
                containerURL.appendingPathComponent("user.loudschars2"),
                containerURL.appendingPathComponent("user.louds")
            )
        }
        return (
            bundleURL.appendingPathComponent("\(identifier).loudschars2"),
            bundleURL.appendingPathComponent("\(identifier).louds")
        )
    }

    private static func getLoudstxt2URL(_ identifier: String) -> URL {
        if identifier.hasPrefix("user") {
            return containerURL.appendingPathComponent("\(identifier).loudstxt2")
        }
        return bundleURL.appendingPathComponent("\(identifier).loudstxt2")
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

    internal static func getData(_ identifier: String, indices: [Int]) -> [String] {
        let binary: Data
        do {
            let url = getLoudstxt2URL(identifier)
            binary = try Data(contentsOf: url)
        } catch {
            debug("ファイルが存在しません: \(error)")
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
        let i32array = binary[2..<header_endIndex].withUnsafeBytes {pointer -> [UInt32] in
            return Array(
                UnsafeBufferPointer(
                    start: pointer.baseAddress!.assumingMemoryBound(to: UInt32.self),
                    count: pointer.count / MemoryLayout<UInt32>.size
                )
            )
        }

        return indices.compactMap {(index: Int) in
            let startIndex = Int(i32array[index])
            let endIndex = index == (lc-1) ? binary.endIndex : Int(i32array[index + 1])
            return String(bytes: binary[startIndex ..< endIndex], encoding: .utf8)
        }

    }
}
