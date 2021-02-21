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

    init(data: DicDataElementProtocol, romanString: String, rubyCount: Int?)

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
                let node = RomanLatticeNode(data: self.data, romanString: self.data.ruby, rubyCount: self.rubyCount)
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
                let node = DirectLatticeNode(data: self.data, romanString: self.data.ruby, rubyCount: self.rubyCount)
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
    convenience init(data: DicDataElementProtocol, romanString: String, rubyCount: Int? = nil) {
        self.init(data: data, rubyCount: rubyCount)
    }

    let data: DicDataElementProtocol
    var prevs: [RegisteredNode] = []
    let rubyCount: Int
    var values: [PValue] = []

    static var EOSNode: DirectLatticeNode {
        return DirectLatticeNode(data: BOSEOSDicDataElement.EOSData)
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> DirectRegisteredNode {
        return DirectRegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, rubyCount: rubyCount)
    }

    init(data: DicDataElementProtocol, rubyCount: Int? = nil){
        self.data = data
        self.values = [data.value()]
        if let rubyCount = rubyCount{
            self.rubyCount = rubyCount
        }else{
            self.rubyCount = data.ruby.count
        }
    }
}
 
///ラティスのノード。これを用いて計算する。
final class RomanLatticeNode: LatticeNodeProtocol{
    typealias RegisteredNode = RomanRegisteredNode

    let data: DicDataElementProtocol
    var prevs: [RegisteredNode] = []
    var values: [PValue] = []
    let romanString: String
    let rubyCount: Int

    static var EOSNode: RomanLatticeNode {
        return RomanLatticeNode(data: BOSEOSDicDataElement.EOSData, romanString: "")
    }

    init(data: DicDataElementProtocol, romanString: String, rubyCount: Int? = nil){
        self.data = data
        self.values = [data.value()]
        self.romanString = romanString
        if let rubyCount = rubyCount{
            self.rubyCount = rubyCount
        }else{
            self.rubyCount = romanString.count
        }
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> RegisteredNode {
        return RomanRegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, rubyCount: rubyCount, romanString: self.romanString)
    }

}
 
