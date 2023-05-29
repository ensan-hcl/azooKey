//
//  afterLastCharacterDeleted.swift
//  Keyboard
//
//  Created by ensan on 2020/09/14.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUtils

extension Kana2Kanji {

    /// カナを漢字に変換する関数, 最後の複数文字を削除した場合。
    /// - Parameters:
    ///   - deletedCount: 消した文字数。
    ///   - N_best: N_best値。
    ///   - previousResult: ひとつ前のデータ。つまり消した文字があった時の変換のデータ。
    /// - Returns:
    ///   発見された候補のリスト。
    ///
    /// ### 実装方法
    /// (1)まず、計算済みノードを捜査して、新しい文末につながるものをresultにregisterしていく。
    ///   N_bestの計算は既にやってあるので不要。
    ///
    /// (2)次に、返却用ノードを計算する。文字数が超過するものはfilterで除去する。

    func kana2lattice_deletedLast(deletedCount: Int, N_best: Int, previousResult: (inputData: ComposingText, nodes: Nodes)) -> (result: LatticeNode, nodes: Nodes) {
        debug("削除の連続性を利用した変換、元の文字は：", previousResult.inputData.convertTarget)
        let count = previousResult.inputData.input.count - deletedCount
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
        let updatedNodes = previousResult.nodes.prefix(count).map {(nodeArray: [LatticeNode]) in
            nodeArray.filter {$0.inputRange.endIndex <= count}
        }
        return (result: result, nodes: updatedNodes)
    }

}
