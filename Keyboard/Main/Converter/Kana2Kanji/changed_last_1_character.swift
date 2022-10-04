//
//  afterLastCharacterChanged.swift
//  Keyboard
//
//  Created by β α on 2020/09/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
extension Kana2Kanji {
    /// カナを漢字に変換する関数, 最後の一文字が変わった場合。
    /// ### 実装状況
    /// (0)多用する変数の宣言。
    ///
    /// (1)まず、変更前の一文字につながるノードを全て削除する。
    ///
    /// (2)次に、変更後の一文字につながるノードを全て列挙する。
    ///
    /// (3)(1)を解析して(2)にregisterしていく。
    ///
    /// (4)registerされた結果をresultノードに追加していく。
    ///
    /// (5)ノードをアップデートした上で返却する。

    func kana2lattice_changedLast(_ inputData: InputData, N_best: Int, previousNodes: Nodes) -> (result: LatticeNode, nodes: Nodes) {
        // (0)
        let count = inputData.input.count

        // (1)
        var nodes = previousNodes.enumerated().map {(i: Int, nodeArray: [LatticeNode]) in
            return nodeArray.filter {i + $0.convertTargetLength < count}
        }

        // (2)
        let addedNodes: [[LatticeNode]] = (0..<count).map {(i: Int) in
            return self.dicdataStore.getLOUDSData(inputData: inputData, from: i, to: count-1)
        }

        // (3)
        for (i, nodeArray) in nodes.enumerated() {
            for node in nodeArray {
                if node.prevs.isEmpty {
                    continue
                }
                if self.dicdataStore.shouldBeRemoved(data: node.data) {
                    continue
                }
                // 変換した文字数
                let nextIndex = node.convertTargetLength + i
                for nextnode in addedNodes[nextIndex] {
                    // この関数はこの時点で呼び出して、後のnode.registered.isEmptyで最終的に弾くのが良い。
                    if self.dicdataStore.shouldBeRemoved(data: nextnode.data) {
                        continue
                    }
                    // クラスの連続確率を計算する。
                    let ccValue = self.dicdataStore.getCCValue(node.data.rcid, nextnode.data.lcid)
                    let ccBonus = PValue(self.dicdataStore.getMatch(node.data, next: nextnode.data) * self.ccBonusUnit)
                    let ccSum = ccValue + ccBonus
                    // nodeの持っている全てのprevnodeに対して
                    for (index, value) in node.values.enumerated() {
                        let newValue = ccSum + value
                        // 追加すべきindexを取得する
                        let lastindex = (nextnode.prevs.lastIndex(where: {$0.totalValue>=newValue}) ?? -1) + 1
                        if lastindex == N_best {
                            continue
                        }
                        let newnode = node.getSqueezedNode(index, value: newValue)
                        // カウントがオーバーしている場合は除去する
                        if nextnode.prevs.count >= N_best {
                            nextnode.prevs.removeLast()
                        }
                        // removeしてからinsertした方が速い (insertはO(N)なので)
                        nextnode.prevs.insert(newnode, at: lastindex)
                    }
                }
            }

        }

        let result = LatticeNode.EOSNode
        for (i, nodes) in addedNodes.enumerated() {
            for node in nodes {
                if node.prevs.isEmpty {
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
                // 最後に至るので
                for index in node.prevs.indices {
                    let newnode = node.getSqueezedNode(index, value: node.values[index])
                    result.prevs.append(newnode)
                }
            }
        }

        for (index, nodeArray) in addedNodes.enumerated() {
            if index < nodes.endIndex {
                nodes[index].append(contentsOf: nodeArray)
            }
        }

        return (result: result, nodes: nodes)
    }

}
