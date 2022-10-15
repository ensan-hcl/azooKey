//
//  afterCharacterAdded.swift
//  Keyboard
//
//  Created by β α on 2020/09/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
extension Kana2Kanji {
    /// カナを漢字に変換する関数, 最後の複数文字を追加した場合。
    /// - Parameters:
    ///   - inputData: 今のInputData。
    ///   - N_best: N_best。
    ///   - addedCount: 文字数
    ///   - previousResult: 追加される前のデータ。
    /// - Returns:
    ///   - 変換候補。
    /// ### 実装状況
    /// (0)多用する変数の宣言。
    ///
    /// (1)まず、追加された一文字に繋がるノードを列挙する。
    ///
    /// (2)次に、計算済みノードから、(1)で求めたノードにつながるようにregisterして、N_bestを求めていく。
    ///
    /// (3)(1)のregisterされた結果をresultノードに追加していく。この際EOSとの連接コストを計算しておく。
    ///
    /// (4)ノードをアップデートした上で返却する。
    func kana2lattice_added(_ inputData: InputData, N_best: Int, addedCount: Int, previousResult: (inputData: InputData, nodes: Nodes)) -> (result: LatticeNode, nodes: Nodes) {
        debug("\(addedCount)文字追加。追加されたのは「\(inputData.input.suffix(addedCount))」")
        if addedCount == 1 {
            return kana2lattice_addedLast(inputData, N_best: N_best, previousResult: previousResult)
        }
        // (0)
        var nodes = previousResult.nodes
        let count = inputData.input.count

        // (1)
        let addedNodes: [[LatticeNode]] = (.zero ..< count).map {(i: Int) in
            self.dicdataStore.getLOUDSDataInRange(
                inputData: inputData,
                from: i,
                toIndexRange: (max(previousResult.inputData.input.count, i) ..< max(previousResult.inputData.input.count, min(count, i+self.dicdataStore.maxlength+1)))
            )
        }

        // (2)
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
                    let ccValue: PValue = self.dicdataStore.getCCValue(node.data.rcid, nextnode.data.lcid)
                    let ccBonus: PValue = PValue(self.dicdataStore.getMatch(node.data, next: nextnode.data) * self.ccBonusUnit)
                    let ccSum: PValue = ccValue + ccBonus
                    // nodeの持っている全てのprevnodeに対して
                    for (index, value) in node.values.enumerated() {
                        let newValue: PValue = ccSum + value
                        // 追加すべきindexを取得する
                        let lastindex: Int = (nextnode.prevs.lastIndex(where: {$0.totalValue >= newValue}) ?? -1) + 1
                        if lastindex == N_best {
                            continue
                        }
                        let newnode: RegisteredNode = node.getSqueezedNode(index, value: newValue)
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


        // (3)
        let result = LatticeNode.EOSNode

        for (i, nodeArray) in addedNodes.enumerated() {
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
                let nextIndex = node.convertTargetLength + i
                if count == nextIndex {
                    // 最後に至るので
                    for index in node.prevs.indices {
                        let newnode = node.getSqueezedNode(index, value: node.values[index])
                        result.prevs.append(newnode)
                    }
                } else {
                    for nextnode in addedNodes[nextIndex] {
                        // この関数はこの時点で呼び出して、後のnode.registered.isEmptyで最終的に弾くのが良い。
                        if self.dicdataStore.shouldBeRemoved(data: nextnode.data) {
                            continue
                        }
                        // クラスの連続確率を計算する。
                        let ccValue: PValue = self.dicdataStore.getCCValue(node.data.rcid, nextnode.data.lcid)
                        let ccBonus: PValue = PValue(self.dicdataStore.getMatch(node.data, next: nextnode.data) * self.ccBonusUnit)
                        let ccSum: PValue = ccValue + ccBonus

                        // nodeの持っている全てのprevnodeに対して
                        for (index, value) in node.values.enumerated() {
                            let newValue: PValue = ccSum + value
                            // 追加すべきindexを取得する
                            let lastindex: Int = (nextnode.prevs.lastIndex(where: {$0.totalValue >= newValue}) ?? -1) + 1
                            if lastindex == N_best {
                                continue
                            }
                            let newnode: RegisteredNode = node.getSqueezedNode(index, value: newValue)
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
        }

        for (index, nodeArray) in addedNodes.enumerated() {
            if index < nodes.endIndex {
                nodes[index].append(contentsOf: nodeArray)
            } else {
                nodes.append(nodeArray)
            }
        }
        return (result: result, nodes: nodes)
    }
}
