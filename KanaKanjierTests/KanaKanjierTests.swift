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
        let _ui64array = binaryData.withUnsafeBytes { pointer -> [UInt64] in
            print(pointer)
            return Array(
                UnsafeBufferPointer(
                    start: pointer.baseAddress!.assumingMemoryBound( to: UInt64.self ),
                    count: pointer.count / MemoryLayout<UInt64>.size
                )
            )
        }
        return _ui64array
    }
}
