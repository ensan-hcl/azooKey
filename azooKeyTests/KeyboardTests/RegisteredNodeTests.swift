//
//  RegisteredNodeTests.swift
//  azooKeyTests
//
//  Created by β α on 2023/01/31.
//  Copyright © 2023 DevEn3. All rights reserved.
//

import XCTest

final class RegisteredNodeTests: XCTestCase {
    func testBOSNode() throws {
        let bos = RegisteredNode.BOSNode()
        XCTAssertEqual(bos.inputRange, 0..<0)
        XCTAssertNil(bos.prev)
        XCTAssertEqual(bos.totalValue, 0)
        XCTAssertEqual(bos.data.rcid, CIDData.BOS.cid)
    }

    func testFromLastCandidate() throws {
        let candidate = Candidate(text: "我輩は猫", value: -20, correspondingCount: 7, lastMid: 100, data: [DicdataElement(word: "我輩は猫", ruby: "ワガハイハネコ", cid: CIDData.一般名詞.cid, mid: 100, value: -20)])
        let bos = RegisteredNode.fromLastCandidate(candidate)
        XCTAssertEqual(bos.inputRange, 0..<0)
        XCTAssertNil(bos.prev)
        XCTAssertEqual(bos.totalValue, 0)
        XCTAssertEqual(bos.data.rcid, CIDData.一般名詞.cid)
        XCTAssertEqual(bos.data.mid, 100)
    }

    func testGetCandidateData() throws {
        let bos = RegisteredNode.BOSNode()
        let node1 = RegisteredNode(
            data: DicdataElement(word: "我輩", ruby: "ワガハイ", cid: CIDData.一般名詞.cid, mid: 1, value: -5),
            registered: bos,
            totalValue: -10,
            inputRange: 0..<4
        )
        let node2 = RegisteredNode(
            data: DicdataElement(word: "は", ruby: "ハ", cid: CIDData.係助詞ハ.cid, mid: 2, value: -2),
            registered: node1,
            totalValue: -13,
            inputRange: 4..<5
        )
        let node3 = RegisteredNode(
            data: DicdataElement(word: "猫", ruby: "ネコ", cid: CIDData.一般名詞.cid, mid: 3, value: -4),
            registered: node2,
            totalValue: -20,
            inputRange: 5..<7
        )
        let node4 = RegisteredNode(
            data: DicdataElement(word: "です", ruby: "デス", cid: CIDData.助動詞デス基本形.cid, mid: 4, value: -3),
            registered: node3,
            totalValue: -25,
            inputRange: 7..<9
        )
        let result = node4.getCandidateData()
        let clause1 = ClauseDataUnit()
        clause1.text = "我輩は"
        clause1.nextLcid = CIDData.一般名詞.cid
        clause1.inputRange = 0..<5
        clause1.mid = 1

        let clause2 = ClauseDataUnit()
        clause2.text = "猫です"
        clause2.nextLcid = CIDData.EOS.cid
        clause2.inputRange = 5..<9
        clause2.mid = 3

        let expectedResult: CandidateData = CandidateData(
            clauses: [(clause1, -13), (clause2, -25)],
            data: [node1.data, node2.data, node3.data, node4.data]
        )
        XCTAssertEqual(result.data, expectedResult.data)
        XCTAssertEqual(result.clauses.map{$0.value}, expectedResult.clauses.map{$0.value})
        XCTAssertEqual(result.clauses.map{$0.clause}, expectedResult.clauses.map{$0.clause})
    }
}
