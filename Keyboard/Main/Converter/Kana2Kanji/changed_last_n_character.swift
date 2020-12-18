//
//  changed_last_n_character.swift
//  Keyboard
//
//  Created by β α on 2020/10/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
extension Kana2Kanji{
    ///カナを漢字に変換する関数, 最後の一文字が変わった場合。
    ///### 実装状況
    ///(0)多用する変数の宣言。
    ///
    ///(1)まず、変更前の一文字につながるノードを全て削除する。
    ///
    ///(2)次に、変更後の一文字につながるノードを全て列挙する。
    ///
    ///(3)(1)を解析して(2)にregisterしていく。
    ///
    ///(4)registerされた結果をresultノードに追加していく。
    ///
    ///(5)ノードをアップデートした上で返却する。

    func kana2lattice_changed(_ inputData: InputData, N_best: Int, counts: (deleted: Int, added: Int), previousResult: (inputData: InputData, nodes: Nodes)) -> (result: LatticeNode, nodes: Nodes) {
        let start1 = Date()
        //(0)
        let count = inputData.count
        let commonCount = previousResult.inputData.count - counts.deleted
        //(1)
        var nodes = previousResult.nodes.indices.map{(i: Int) in
            return previousResult.nodes[i].filter{i + $0.rubyCount <= commonCount}
        }
        while nodes.last?.isEmpty ?? false{
            nodes.removeLast()
        }

        //(1)
        let addedNodes: [[LatticeNode]] = (0..<count).map{(i: Int) in
            (commonCount ..< count).flatMap{j -> [LatticeNode] in
                if j-i >= self.dicdataStore.maxlength || j<i{
                    return []
                }
                let result: [LatticeNode] = self.dicdataStore.getLOUDSData(inputData: inputData, from: i, to: j)
                return result
            }
        }

        debug("辞書の読み込み:", -start1.timeIntervalSinceNow)
        let start2 = Date()
        //(3)
        nodes.indices.forEach{(i: Int) in
            nodes[i].forEach{(node: LatticeNode) in
                if node.prevs.isEmpty{
                    return
                }
                if self.dicdataStore.shouldBeRemoved(data: node.data){
                    return
                }
                //変換した文字数
                let nextIndex = node.rubyCount + i
                addedNodes[nextIndex].forEach{(nextnode: LatticeNode) in
                    if self.dicdataStore.shouldBeRemoved(data: nextnode.data){
                        return
                    }
                    //クラスの連続確率を計算する。
                    let ccValue = self.dicdataStore.getCCValue(node.data.rcid, nextnode.data.lcid)
                    let ccBonus = PValue(self.dicdataStore.getMatch(node.data, next: nextnode.data) * self.ccBonusUnit)
                    let ccSum = ccValue + ccBonus
                    //nodeの持っている全てのprevnodeに対して
                    node.values.indices.forEach{(index: Int) in
                        let newValue = ccSum + node.values[index]
                        //追加すべきindexを取得する
                        let lastindex = (nextnode.prevs.lastIndex(where: {$0.totalValue>=newValue}) ?? -1) + 1
                        if lastindex == N_best{
                            return
                        }
                        let newnode = node.getSqueezedNode(index, value: newValue)
                        nextnode.prevs.insert(newnode, at: lastindex)
                        //カウントがオーバーしている場合は除去する
                        if nextnode.prevs.count > N_best{
                            nextnode.prevs.removeLast()
                        }
                    }
                }
            }

        }

        debug("ノードの登録前半:", -start2.timeIntervalSinceNow)
        let start3 = Date()
        let result = LatticeNode.EOSNode
        addedNodes.indices.forEach{(i: Int) in
            addedNodes[i].forEach{(node: LatticeNode) in
                if node.prevs.isEmpty{
                    return
                }
                //この関数はこの時点で呼び出して、後のnode.registered.isEmptyで最終的に弾くのが良い。
                if self.dicdataStore.shouldBeRemoved(data: node.data){
                    return
                }
                //生起確率を取得する。
                let wValue = node.data.value()
                //valuesを更新する
                node.values = node.prevs.map{$0.totalValue + wValue}
                let nextIndex = node.rubyCount + i
                if count == nextIndex{
                    //最後に至るので
                    node.prevs.indices.forEach{
                        let newnode = node.getSqueezedNode($0, value: node.values[$0])
                        result.prevs.append(newnode)
                    }
                }else{
                    addedNodes[nextIndex].forEach{(nextnode: LatticeNode) in
                        //この関数はこの時点で呼び出して、後のnode.registered.isEmptyで最終的に弾くのが良い。
                        if self.dicdataStore.shouldBeRemoved(data: nextnode.data){
                            return
                        }
                        //クラスの連続確率を計算する。
                        let ccValue = self.dicdataStore.getCCValue(node.data.rcid, nextnode.data.lcid)
                        let ccBonus = PValue(self.dicdataStore.getMatch(node.data, next: nextnode.data) * self.ccBonusUnit)
                        node.prevs.indices.forEach{(index: Int) in
                            let newValue = ccValue + ccBonus + node.values[index]
                            //追加すべきindexを取得する
                            let lastindex = (nextnode.prevs.lastIndex(where: {$0.totalValue>=newValue}) ?? -1) + 1
                            if lastindex == N_best{
                                return
                            }
                            let newnode = node.getSqueezedNode(index, value: newValue)
                            nextnode.prevs.insert(newnode, at: lastindex)
                            //カウントがオーバーしている場合は除去する
                            if nextnode.prevs.count > N_best{
                                nextnode.prevs.removeLast()
                            }
                        }
                    }
                }
            }
        }

        debug("ノードの登録後半:", -start3.timeIntervalSinceNow)
        let start4 = Date()

        let updatedNodes = nodes.indices.map{
            return nodes[$0] + addedNodes[$0]
        } + addedNodes.suffix(counts.added)
        debug("結果の集計:", -start4.timeIntervalSinceNow)

        return (result: result, nodes: updatedNodes)
    }


}
