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
    // ユーザの行った入力に対応する文字列
    // 本来[ComposingText.InputElement]的なものであるべき。
    let input: String
    // ディスプレイされたテキストで対応する文字数
    // korega -> これが -> 3
    // koれga -> これが -> 3
    var convertTargetLength: Int {
        return input.count
    }

    static var EOSNode: LatticeNode {
        return LatticeNode(data: DicdataElement.EOSData, input: "")
    }

    init(data: DicdataElement, input: String) {
        self.data = data
        self.values = [data.value()]
        self.input = input
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> RegisteredNode {
        return RegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, input: self.input)
    }

    func getCandidateData() -> [CandidateData] {
        return self.prevs.map {$0.getCandidateData()}
    }
}
