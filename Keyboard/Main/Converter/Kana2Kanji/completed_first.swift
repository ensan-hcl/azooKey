//
//  afterPartlyCompleted.swift
//  Keyboard
//
//  Created by β α on 2020/09/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
extension Kana2Kanji{
    ///カナを漢字に変換する関数, 部分的に確定した後の場合。
    /// ### 実装方法
    ///(1)まず、計算済みnodeの確定分以降を取り出し、registeredにcompletedDataの値を反映したBOSにする。
    ///
    ///(2)次に、再度計算して良い候補を得る。
    func kana2lattice_afterComplete(_ inputData: InputData, completedData: Candidate, N_best: Int, previousResult: (inputData: InputData, nodes: Nodes)) -> (result: LatticeNode, nodes: Nodes) {
        print("確定直後の変換、元の文字は：",previousResult.inputData.characters, "新しい文字は：", inputData.characters)
        let count = inputData.count
        //(1)
        let start = LatticeNode.RegisteredNode.BOSNode()
        let nodes: Nodes = previousResult.nodes.suffix(count)
        nodes.indices.forEach{(i: Int) in
            if i == .zero{
                nodes[i].forEach{
                    $0.prevs = [start]
                }
            }else{
                nodes[i].forEach{
                    $0.prevs = []
                }
            }
        }
        //(2)
        let result = LatticeNode.EOSNode

        nodes.indices.forEach{(i: Int) in
            nodes[i].forEach{(node: LatticeNode) in
                if node.prevs.isEmpty{
                    return
                }
                if self.dicdataStore.shouldBeRemoved(data: node.data){
                    return
                }
                //生起確率を取得する。
                let wValue = node.data.value()
                //valuesを更新する
                node.values = node.prevs.map{$0.totalValue + wValue}
                //変換した文字数
                let nextIndex = node.rubyCount + i
                //文字数がcountと等しくない場合は先に進む
                if nextIndex != count{
                    nodes[nextIndex].forEach{(nextnode: LatticeNode) in
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
                    //countと等しければ変換が完成したので終了する
                }else{
                    node.prevs.indices.forEach{
                        let newnode = node.getSqueezedNode($0, value: node.values[$0])
                        result.prevs.append(newnode)
                    }
                }
            }

        }
        return (result: result, nodes: nodes)
    }
}
