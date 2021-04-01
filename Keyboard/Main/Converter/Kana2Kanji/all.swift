//
//  all.swift
//  Keyboard
//
//  Created by β α on 2020/09/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
extension Kana2Kanji {
    /// Latticeを構成する基本単位
    typealias Nodes = [[LatticeNode]]

    /// カナを漢字に変換する関数, 前提はなくかな列が与えられた場合。
    /// - Parameters:
    ///   - inputData: 入力データ。
    ///   - N_best: N_best。
    /// - Returns:
    ///   変換候補。
    /// ### 実装状況
    /// (0)多用する変数の宣言。
    ///
    /// (1)まず、追加された一文字に繋がるノードを列挙する。
    ///
    /// (2)次に、計算済みノードから、(1)で求めたノードにつながるようにregisterして、N_bestを求めていく。
    ///
    /// (3)(1)のregisterされた結果をresultノードに追加していく。この際EOSとの連接計算を行っておく。
    ///
    /// (4)ノードをアップデートした上で返却する。
    func kana2lattice_all(_ inputData: InputData, N_best: Int) -> (result: LatticeNode, nodes: Nodes) {
        debug("新規に計算を行います。inputされた文字列は\(inputData.count)文字分の\(inputData.characters)")
        conversionBenchmark.start(process: .変換_全体)
        let count: Int = inputData.count
        let result: LatticeNode = LatticeNode.EOSNode
        conversionBenchmark.start(process: .変換_辞書読み込み)
        let nodes: [[LatticeNode]] = (.zero ..< count).map {dicdataStore.getLOUDSData(inputData: inputData, from: $0)}
        conversionBenchmark.end(process: .変換_辞書読み込み)
        conversionBenchmark.start(process: .変換_処理)
        // 「i文字目から始まるnodes」に対して
        nodes.indices.forEach {(i: Int) in
            // それぞれのnodeに対して
            nodes[i].forEach {(node: LatticeNode) in
                if node.prevs.isEmpty {
                    return
                }
                if self.dicdataStore.shouldBeRemoved(data: node.data) {
                    return
                }
                // 生起確率を取得する。
                let wValue: PValue = node.data.value()
                // valuesを更新する
                node.values = node.prevs.map {$0.totalValue + wValue}
                // 変換した文字数
                let nextIndex: Int = i &+ node.rubyCount
                // 文字数がcountと等しい場合登録する
                if nextIndex == count {
                    node.prevs.indices.forEach {
                        let newnode: RegisteredNode = node.getSqueezedNode($0, value: node.values[$0])
                        result.prevs.append(newnode)
                    }
                } else {
                    // nodeの繋がる次にあり得る全てのnextnodeに対して
                    nodes[nextIndex].forEach {(nextnode: LatticeNode) in
                        // この関数はこの時点で呼び出して、後のnode.registered.isEmptyで最終的に弾くのが良い。
                        if self.dicdataStore.shouldBeRemoved(data: nextnode.data) {
                            return
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
                        // nodeの持っている全てのprevnodeに対して
                        conversionBenchmark.start(process: .変換_処理_N_Best計算)
                        node.values.indices.forEach {(index: Int) in
                            let newValue: PValue = ccSum + node.values[index]
                            // 追加すべきindexを取得する
                            let lastindex: Int = (nextnode.prevs.lastIndex(where: {$0.totalValue >= newValue}) ?? -1) + 1
                            if lastindex == N_best {
                                return
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
        conversionBenchmark.end(process: .変換_全体)
        return (result: result, nodes: nodes)
    }

}
