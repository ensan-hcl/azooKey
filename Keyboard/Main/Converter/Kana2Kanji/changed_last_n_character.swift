//
//  changed_last_n_character.swift
//  Keyboard
//
//  Created by β α on 2020/10/14.
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

    func kana2lattice_changed(_ inputData: InputData, N_best: Int, counts: (deleted: Int, added: Int), previousResult: (inputData: InputData, nodes: Nodes)) -> (result: LatticeNode, nodes: Nodes) {
        conversionBenchmark.start(process: .変換_全体)
        // (0)
        let count = inputData.count
        let commonCount = previousResult.inputData.count - counts.deleted

        // (1)
        conversionBenchmark.start(process: .変換_辞書読み込み)
        var nodes = previousResult.nodes.enumerated().map {(i: Int, nodes: [LatticeNode]) in
            return nodes.filter {i + $0.rubyCount <= commonCount}
        }
        while nodes.last?.isEmpty ?? false {
            nodes.removeLast()
        }

        // (1)
        let addedNodes: [[LatticeNode]] = (0..<count).map {(i: Int) in
            (commonCount ..< count).flatMap {j -> [LatticeNode] in
                if j-i >= self.dicdataStore.maxlength || j<i {
                    return []
                }
                let result: [LatticeNode] = self.dicdataStore.getLOUDSData(inputData: inputData, from: i, to: j)
                return result
            }
        }
        conversionBenchmark.end(process: .変換_辞書読み込み)

        // (2)
        conversionBenchmark.start(process: .変換_処理)
        for (i, nodeArray) in nodes.enumerated() {
            for node in nodeArray {
                if node.prevs.isEmpty {
                    continue
                }
                if self.dicdataStore.shouldBeRemoved(data: node.data) {
                    continue
                }
                // 変換した文字数
                let nextIndex = node.rubyCount + i
                for nextnode in addedNodes[nextIndex] {
                    if self.dicdataStore.shouldBeRemoved(data: nextnode.data) {
                        continue
                    }
                    // クラスの連続確率を計算する。
                    conversionBenchmark.start(process: .変換_処理_連接コスト計算_全体)
                    conversionBenchmark.start(process: .変換_処理_連接コスト計算_CCValue)
                    let ccValue: PValue = self.dicdataStore.getCCValue(node.data.rcid, nextnode.data.lcid)
                    conversionBenchmark.end(process: .変換_処理_連接コスト計算_CCValue)
                    conversionBenchmark.start(process: .変換_処理_連接コスト計算_Memory)
                    let ccBonus: PValue = PValue(self.dicdataStore.getMatch(node.data, next: nextnode.data) * self.ccBonusUnit)
                    conversionBenchmark.end(process: .変換_処理_連接コスト計算_Memory)
                    let ccSum: PValue = ccValue + ccBonus
                    conversionBenchmark.end(process: .変換_処理_連接コスト計算_全体)
                    conversionBenchmark.start(process: .変換_処理_N_Best計算)
                    // nodeの持っている全てのprevnodeに対して
                    for (index, value) in node.values.enumerated() {
                        let newValue: PValue = ccSum + value
                        // 追加すべきindexを取得する
                        let lastindex: Int = (nextnode.prevs.lastIndex(where: {$0.totalValue >= newValue}) ?? -1) + 1
                        if lastindex == N_best {
                            continue
                        }
                        let newnode: RegisteredNode = node.getSqueezedNode(index, value: newValue)
                        nextnode.prevs.insert(newnode, at: lastindex)
                        // カウントがオーバーしている場合は除去する
                        if nextnode.prevs.count > N_best {
                            nextnode.prevs.removeLast()
                        }
                    }
                    conversionBenchmark.end(process: .変換_処理_N_Best計算)
                }
            }

        }

        // (3)
        let result = LatticeNode.EOSNode
        for (i, nodes) in addedNodes.enumerated() {
            for node in nodes {
                if node.prevs.isEmpty {
                    continue
                }
                // この関数はこの時点で呼び出して、後のnode.registered.isEmptyで最終的に弾くのが良い。
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
                let nextIndex = node.rubyCount + i
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
                        conversionBenchmark.start(process: .変換_処理_連接コスト計算_全体)
                        conversionBenchmark.start(process: .変換_処理_連接コスト計算_CCValue)
                        let ccValue = self.dicdataStore.getCCValue(node.data.rcid, nextnode.data.lcid)
                        conversionBenchmark.end(process: .変換_処理_連接コスト計算_CCValue)
                        conversionBenchmark.start(process: .変換_処理_連接コスト計算_Memory)
                        let ccBonus = PValue(self.dicdataStore.getMatch(node.data, next: nextnode.data) * self.ccBonusUnit)
                        conversionBenchmark.end(process: .変換_処理_連接コスト計算_Memory)
                        let ccSum: PValue = ccValue + ccBonus
                        conversionBenchmark.end(process: .変換_処理_連接コスト計算_全体)

                        conversionBenchmark.start(process: .変換_処理_N_Best計算)
                        // nodeの持っている全てのprevnodeに対して
                        for (index, value) in node.values.enumerated() {
                            let newValue = ccSum + value
                            // 追加すべきindexを取得する
                            let lastindex: Int = (nextnode.prevs.lastIndex(where: {$0.totalValue >= newValue}) ?? -1) + 1
                            if lastindex == N_best {
                                continue
                            }
                            let newnode: RegisteredNode = node.getSqueezedNode(index, value: newValue)
                            nextnode.prevs.insert(newnode, at: lastindex)
                            // カウントがオーバーしている場合は除去する
                            if nextnode.prevs.count > N_best {
                                nextnode.prevs.removeLast()
                            }
                        }
                        conversionBenchmark.end(process: .変換_処理_N_Best計算)
                    }
                }
            }
        }
        conversionBenchmark.end(process: .変換_処理)

        for (index, nodeArray) in addedNodes.enumerated() {
            if index < nodes.endIndex {
                nodes[index].append(contentsOf: nodeArray)
            }
        }
        for nodeArray in addedNodes.suffix(counts.added) {
            nodes.append(nodeArray)
        }
        conversionBenchmark.end(process: .変換_全体)

        return (result: result, nodes: nodes)
    }

}
