//
//  LatticeNode.swift
//  Keyboard
//
//  Created by β α on 2020/09/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
/// ラティスのノード。これを用いて計算する。
protocol LatticeNodeProtocol: AnyObject {
    var data: DicdataElement {get}
    var prevs: [ComposingTextRegisteredNode] {get set}
    var values: [PValue] {get set}
    var rubyCount: Int {get}

    func getSqueezedNode(_ index: Int, value: PValue) -> ComposingTextRegisteredNode

    func getCandidateData() -> [CandidateData]

    init(data: DicdataElement, romanString: String, rubyCount: Int?)

    static var EOSNode: Self {get}
}

extension LatticeNodeProtocol {
    func getCandidateData() -> [CandidateData] {
        let result = self.prevs.map {$0.getCandidateData()}
        switch VariableStates.shared.inputStyle {
        case .direct:
            break
        case .roman2kana:
            result.forEach {
                $0.lastClause?.ruby = $0.lastClause?.ruby.roman2katakana ?? ""
            }
        }
        return result
    }

    func translated<Node: LatticeNodeProtocol>() -> Node {
        if let node = self as? Node {
            return node
        }
        if self is DirectLatticeNode {
            if Node.self == RomanLatticeNode.self {
                let node = RomanLatticeNode(data: self.data, romanString: self.data.ruby, rubyCount: self.rubyCount)
                node.prevs = self.prevs
                node.values = self.values
                return node as! Node
            }
        }
        if self is RomanLatticeNode {
            if Node.self == DirectLatticeNode.self {
                let node = DirectLatticeNode(data: self.data, romanString: self.data.ruby, rubyCount: self.rubyCount)
                node.prevs = self.prevs
                node.values = self.values
                return node as! Node
            }
        }
        fatalError("Exception: Unknown condition")
    }
}
/// ラティスのノード。これを用いて計算する。
final class DirectLatticeNode: LatticeNodeProtocol {
    typealias RegisteredNode = ComposingTextRegisteredNode
    convenience init(data: DicdataElement, romanString: String, rubyCount: Int? = nil) {
        self.init(data: data, rubyCount: rubyCount)
    }

    let data: DicdataElement
    var prevs: [RegisteredNode] = []
    let rubyCount: Int
    var values: [PValue] = []

    static var EOSNode: DirectLatticeNode {
        return DirectLatticeNode(data: DicdataElement.EOSData)
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> RegisteredNode {
        return RegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, convertTargetLength: rubyCount, input: data.ruby)
    }

    init(data: DicdataElement, rubyCount: Int? = nil) {
        self.data = data
        self.values = [data.value()]
        if let rubyCount {
            self.rubyCount = rubyCount
        } else {
            self.rubyCount = data.ruby.count
        }
    }
}

/// ラティスのノード。これを用いて計算する。
final class RomanLatticeNode: LatticeNodeProtocol {
    typealias RegisteredNode = ComposingTextRegisteredNode

    let data: DicdataElement
    var prevs: [RegisteredNode] = []
    var values: [PValue] = []
    let romanString: String
    let rubyCount: Int

    static var EOSNode: RomanLatticeNode {
        return RomanLatticeNode(data: DicdataElement.EOSData, romanString: "")
    }

    init(data: DicdataElement, romanString: String, rubyCount: Int? = nil) {
        self.data = data
        self.values = [data.value()]
        self.romanString = romanString
        if let rubyCount {
            self.rubyCount = rubyCount
        } else {
            self.rubyCount = romanString.count
        }
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> RegisteredNode {
        return RegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, convertTargetLength: rubyCount, input: self.romanString)
    }

}
