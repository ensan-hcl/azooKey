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
    let convertTargetLength: Int

    convenience init(data: DicdataElement, romanString: String, rubyCount: Int? = nil) {
        self.init(data: data, input: romanString, convertTargetLength: rubyCount ?? romanString.count)
    }

    static var EOSNode: LatticeNode {
        return LatticeNode(data: DicdataElement.EOSData, romanString: "")
    }

    init(data: DicdataElement, input: String, convertTargetLength: Int) {
        self.data = data
        self.values = [data.value()]
        self.input = input
        self.convertTargetLength = convertTargetLength
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> RegisteredNode {
        return RegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, convertTargetLength: convertTargetLength, input: self.input)
    }

    func getCandidateData() -> [CandidateData] {
        let result = self.prevs.map {$0.getCandidateData()}
        // TODO: ここはそのうち書き換える必要がある
        switch VariableStates.shared.inputStyle {
        case .direct:
            break
        case .roman2kana:
            result.forEach {
                $0.lastClause?.ruby = $0.lastClause?.ruby.roman2katakana ?? ""
            }
        }
        return result
    }
}
