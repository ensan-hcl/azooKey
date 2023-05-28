//
//  no_change.swift
//  Keyboard
//
//  Created by ensan on 2022/11/09.
//  Copyright © 2022 ensan. All rights reserved.
//

import Foundation
import SwiftUtils

extension Kana2Kanji {

    /// カナを漢字に変換する関数, キャッシュから単に復元する。
    /// - Parameters:
    ///   - N_best: N_best値。
    ///   - previousResult: ひとつ前のデータ。
    /// - Returns:
    ///   発見された候補のリスト。
    ///
    /// ### 実装方法
    /// (1)まず、計算済みノードを捜査して、新しい文末につながるものをresultにregisterしていく。
    ///   N_bestの計算は既にやってあるので不要。
    ///
    /// (2)次に、返却用ノードを計算する。

    func kana2lattice_no_change(N_best: Int, previousResult: (inputData: ComposingText, nodes: Nodes)) -> (result: LatticeNode, nodes: Nodes) {
        debug("キャッシュから復元、元の文字は：", previousResult.inputData.convertTarget)
        let count = previousResult.inputData.input.count
        // (1)
        let result = LatticeNode.EOSNode

        for nodeArray in previousResult.nodes {
            for node in nodeArray {
                if node.prevs.isEmpty {
                    continue
                }
                if self.dicdataStore.shouldBeRemoved(data: node.data) {
                    continue
                }
                let nextIndex = node.inputRange.endIndex
                if nextIndex == count {
                    // 変換した文字数
                    for (index, value) in node.values.enumerated() {
                        let newnode = node.getRegisteredNode(index, value: value)
                        result.prevs.append(newnode)
                    }
                }
            }
        }

        // (2)
        return (result: result, nodes: previousResult.nodes)
    }

}
