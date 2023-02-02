//
//  LOUDSTests.swift
//  azooKeyTests
//
//  Created by ensan on 2023/02/02.
//  Copyright © 2023 ensan. All rights reserved.
//

import XCTest

final class LOUDSTests: XCTestCase {
    func loadCharIDs() -> [Character: UInt8] {
        let bundleURL = Bundle(for: type(of: self)).bundleURL
        do {
            let string = try String(contentsOf: bundleURL.appendingPathComponent("Dictionary/louds/charID.chid", isDirectory: false), encoding: String.Encoding.utf8)
            return [Character: UInt8](uniqueKeysWithValues: string.enumerated().map {($0.element, UInt8($0.offset))})
        } catch {
            print("ファイルが見つかりませんでした")
            return [:]
        }
    }

    func testSearchNodeIndex() throws {
        // データリソースの場所を指定する
        DicdataStore.bundleURL = Bundle(for: type(of: self)).bundleURL
        let louds = LOUDS.build("シ")
        XCTAssertNotNil(louds)
        guard let louds else { return }
        let charIDs = loadCharIDs()
        let key = "シカイ"
        let chars = key.map {charIDs[$0, default: .max]}
        let index = louds.searchNodeIndex(chars: chars)
        XCTAssertNotNil(index)
        guard let index else { return }

        let dicdata: [DicdataElement] = LOUDS.getDataForLoudstxt3("シ" + "\(index >> 11)", indices: [index & 2047])
        XCTAssertTrue(dicdata.contains {$0.word == "司会"})
        XCTAssertTrue(dicdata.contains {$0.word == "視界"})
        XCTAssertTrue(dicdata.contains {$0.word == "死界"})
    }
}
