//
//  LatticeNode.swift
//  Keyboard
//
//  Created by β α on 2020/09/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

/// ラティスのノード。これを用いて計算する。
final class LatticeNode {
    let data: DicdataElement
    var prevs: [RegisteredNode] = []
    var values: [PValue] = []
    // inputData.input内のrange
    var inputRange: Range<Int>
    // ディスプレイされたテキストで対応する文字数
    // korega -> これが -> 3
    // koれga -> これが -> 3
    var convertTargetLength: Int {
        inputRange.count
    }

    static var EOSNode: LatticeNode {
        LatticeNode(data: DicdataElement.EOSData, inputRange: 0..<0)
    }

    init(data: DicdataElement, inputRange: Range<Int>) {
        self.data = data
        self.values = [data.value()]
        self.inputRange = inputRange
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> RegisteredNode {
        RegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, inputRange: self.inputRange)
    }

    func getCandidateData() -> [CandidateData] {
        self.prevs.map {$0.getCandidateData()}
    }
}
