//
//  afterCharacterAdded.swift
//  Keyboard
//
//  Created by β α on 2020/09/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
extension Kana2Kanji{
    ///カナを漢字に変換する関数, 最後の一文字を追加した場合。
    /// - Parameters:
    ///   - addedCharacter: 追加された文字。
    ///   - N_best: N_best。
    ///   - previousResult: 追加される前のデータ。
    /// - Returns:
    ///   - 変換候補。
    ///### 実装状況
    ///(0)多用する変数の宣言。
    ///
    ///(1)まず、追加された一文字に繋がるノードを列挙する。
    ///
    ///(2)次に、計算済みノードから、(1)で求めたノードにつながるようにregisterして、N_bestを求めていく。
    ///
    ///(3)(1)のregisterされた結果をresultノードに追加していく。この際EOSとの連接コストを計算しておく。
    ///
    ///(4)ノードをアップデートした上で返却する。
    func kana2lattice_addedLast(_ inputData: InputData, N_best: Int, previousResult: (inputData: InputData, nodes: Nodes) ) -> (result: LatticeNode, nodes: Nodes) {
        print("一文字追加。追加されたのは「\(inputData.characters.last!)」")
        
        //(0)
        let nodes = previousResult.nodes
        let count = previousResult.inputData.count

        let start1 = Date()

        //(1)
        let addedNodes: [[LatticeNode]] = (0...count).map{(i: Int) in
            if count-i >= self.dicdataStore.maxlength{
                return []
            }
            return self.dicdataStore.getLOUDSData(inputData: inputData, from: i, to: count)
        }
        print("計算所要時間: (1) 辞書の検索", -start1.timeIntervalSinceNow)    //ココが一番時間がかかっていた。
        let start2 = Date()
        //(2)
        nodes.indices.forEach{(i: Int) in
            //forEachをSerialな並列処理で行うことによって、高速化が可能になる。
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
        
        print("計算所要時間: (2) ノードの登録", -start2.timeIntervalSinceNow)
        let start3 = Date()

        //(3)
        let result = LatticeNode.EOSNode

        addedNodes.forEach{nodes in
            nodes.forEach{(node: LatticeNode) in
                if node.prevs.isEmpty{
                    return
                }
                //生起確率を取得する。
                let wValue = node.data.value()
                //valuesを更新する
                node.values = node.prevs.map{$0.totalValue + wValue}
                //最後に至るので
                node.prevs.indices.forEach{
                    let newnode = node.getSqueezedNode($0, value: node.values[$0])
                    result.prevs.append(newnode)
                }
            }
        }
        
        print("計算所要時間: (3) ノードのresultへの登録", -start3.timeIntervalSinceNow)

        //(4)
        let updatedNodes: Nodes = nodes.indices.map{nodes[$0] + addedNodes[$0]} + [addedNodes.last ?? []]
        print("計算所要時間: 全体", -start1.timeIntervalSinceNow)
        return (result: result, nodes: updatedNodes)
    }
}
