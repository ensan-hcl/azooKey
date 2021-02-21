//
//  LatticeNode.swift
//  Keyboard
//
//  Created by β α on 2020/09/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
///ラティスのノード。これを用いて計算する。
protocol LatticeNodeProtocol: class {
    associatedtype RegisteredNode: RegisteredNodeProtocol
    var data: DicDataElementProtocol {get}
    var prevs: [RegisteredNode] {get set}
    var values: [PValue] {get set}
    var rubyCount: Int {get}
    
    func getSqueezedNode(_ index: Int, value: PValue) -> RegisteredNode

    func getCandidateData() -> [CandidateData]

    init(data: DicDataElementProtocol, romanString: String)

    static var EOSNode: Self {get}
}

extension LatticeNodeProtocol{
    func getCandidateData() -> [CandidateData] {
        let result = self.prevs.map{$0.getCandidateData()}
        switch VariableStates.shared.inputStyle{
        case .direct:
            break
        case .roman:
            result.forEach{
                $0.lastClause?.ruby = $0.lastClause?.ruby.roman2katakana ?? ""
            }
        }
        return result
    }

    func translated<Node: LatticeNodeProtocol>() -> Node {
        if let node = self as? Node{
            return node
        }
        if self is DirectLatticeNode{
            if Node.self == RomanLatticeNode.self{
                let prevs = self.prevs.map{
                    RomanRegisteredNode(data: $0.data, registered: $0.prev, totalValue: $0.totalValue, rubyCount: $0.rubyCount, romanString: $0.ruby)
                }
                let node = RomanLatticeNode(data: self.data, romanString: self.data.ruby)
                node.prevs = prevs
                node.values = values
                return node as! Node
            }
        }
        if self is RomanLatticeNode{
            if Node.self == DirectLatticeNode.self{
                let prevs = self.prevs.map{
                    DirectRegisteredNode(data: $0.data, registered: $0.prev, totalValue: $0.totalValue, rubyCount: $0.rubyCount)
                }
                let node = DirectLatticeNode(data: self.data, romanString: self.data.ruby)
                node.prevs = prevs
                node.values = values
                return node as! Node
            }
        }
        fatalError("Exception: Unknown condition")
    }
}
///ラティスのノード。これを用いて計算する。
final class DirectLatticeNode: LatticeNodeProtocol{
    typealias RegisteredNode = DirectRegisteredNode
    init(data: DicDataElementProtocol, romanString: String) {
        self.data = data
    }

    let data: DicDataElementProtocol
    var prevs: [RegisteredNode] = []
    var values: [PValue] = []
    
    var rubyCount: Int {
        return self.data.ruby.count
    }

    static var EOSNode: DirectLatticeNode {
        return DirectLatticeNode(data: BOSEOSDicDataElement.EOSData)
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> DirectRegisteredNode {
        return DirectRegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, rubyCount: rubyCount)
    }

    init(data: DicDataElementProtocol){
        self.data = data
        self.values = [data.value()]
    }
}
 
///ラティスのノード。これを用いて計算する。
final class RomanLatticeNode: LatticeNodeProtocol{
    typealias RegisteredNode = RomanRegisteredNode

    let data: DicDataElementProtocol
    var prevs: [RegisteredNode] = []
    var values: [PValue] = []
    let romanString: String
    
    var rubyCount: Int {
        return self.romanString.count
    }
    
    static var EOSNode: RomanLatticeNode {
        return RomanLatticeNode(data: BOSEOSDicDataElement.EOSData, romanString: "")
    }

    init(data: DicDataElementProtocol, romanString: String){
        self.data = data
        self.values = [data.value()]
        self.romanString = romanString
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> RegisteredNode {
        return RomanRegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, rubyCount: rubyCount, romanString: self.romanString)
    }

}
 
