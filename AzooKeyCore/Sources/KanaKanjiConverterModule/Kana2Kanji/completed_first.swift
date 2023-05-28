//
//  afterPartlyCompleted.swift
//  Keyboard
//
//  Created by ensan on 2020/09/14.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUtils

extension Kana2Kanji {
    /// カナを漢字に変換する関数, 部分的に確定した後の場合。
    /// ### 実装方法
    /// (1)まず、計算済みnodeの確定分以降を取り出し、registeredにcompletedDataの値を反映したBOSにする。
    ///
    /// (2)次に、再度計算して良い候補を得る。
    func kana2lattice_afterComplete(_ inputData: ComposingText, completedData: Candidate, N_best: Int, previousResult: (inputData: ComposingText, nodes: Nodes)) -> (result: LatticeNode, nodes: Nodes) {
        debug("確定直後の変換、前は：", previousResult.inputData, "後は：", inputData)
        let count = inputData.input.count
        // (1)
        let start = RegisteredNode.fromLastCandidate(completedData)
        let nodes: Nodes = previousResult.nodes.suffix(count)
        for (i, nodeArray) in nodes.enumerated() {
            if i == .zero {
                for node in nodeArray {
                    node.prevs = [start]
                    // inputRangeを確定した部分のカウント分ずらす
                    node.inputRange = node.inputRange.startIndex - completedData.correspondingCount ..< node.inputRange.endIndex - completedData.correspondingCount
                }
            } else {
                for node in nodeArray {
                    node.prevs = []
                    // inputRangeを確定した部分のカウント分ずらす
                    node.inputRange = node.inputRange.startIndex - completedData.correspondingCount ..< node.inputRange.endIndex - completedData.correspondingCount
                }
            }
        }
        // (2)
        let result = LatticeNode.EOSNode

        for (i, nodeArray) in nodes.enumerated() {
            for node in nodeArray {
                if node.prevs.isEmpty {
                    continue
                }
                if self.dicdataStore.shouldBeRemoved(data: node.data) {
                    continue
                }
                // 生起確率を取得する。
                let wValue = node.data.value()
                if i == 0 {
                    // valuesを更新する
                    node.values = node.prevs.map {$0.totalValue + wValue + self.dicdataStore.getCCValue($0.data.rcid, node.data.lcid)}
                } else {
                    // valuesを更新する
                    node.values = node.prevs.map {$0.totalValue + wValue}
                }
                // 変換した文字数
                let nextIndex = node.inputRange.endIndex
                // 文字数がcountと等しくない場合は先に進む
                if nextIndex != count {
                    for nextnode in nodes[nextIndex] {
                        if self.dicdataStore.shouldBeRemoved(data: nextnode.data) {
                            continue
                        }
                        // クラスの連続確率を計算する。
                        let ccValue = self.dicdataStore.getCCValue(node.data.rcid, nextnode.data.lcid)
                        // nodeの持っている全てのprevnodeに対して
                        for (index, value) in node.values.enumerated() {
                            let newValue = ccValue + value
                            // 追加すべきindexを取得する
                            let lastindex = (nextnode.prevs.lastIndex(where: {$0.totalValue >= newValue}) ?? -1) + 1
                            if lastindex == N_best {
                                continue
                            }
                            let newnode = node.getRegisteredNode(index, value: newValue)
                            // カウントがオーバーしている場合は除去する
                            if nextnode.prevs.count >= N_best {
                                nextnode.prevs.removeLast()
                            }
                            // removeしてからinsertした方が速い (insertはO(N)なので)
                            nextnode.prevs.insert(newnode, at: lastindex)
                        }
                    }
                    // countと等しければ変換が完成したので終了する
                } else {
                    for index in node.prevs.indices {
                        let newnode = node.getRegisteredNode(index, value: node.values[index])
                        result.prevs.append(newnode)
                    }
                }
            }

        }
        return (result: result, nodes: nodes)
    }
}
