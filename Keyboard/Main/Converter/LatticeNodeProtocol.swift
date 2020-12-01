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
        switch Store.shared.keyboardType{
        case .flick:
            break
        case .roman:
            result.forEach{
                $0.lastClause?.ruby = $0.lastClause?.ruby.roman2katakana ?? ""
            }
        }
        return result
    }
}
///ラティスのノード。これを用いて計算する。
final class FlickLatticeNode: LatticeNodeProtocol{
    typealias RegisteredNode = FlickRegisteredNode
    init(data: DicDataElementProtocol, romanString: String) {
        self.data = data
    }

    let data: DicDataElementProtocol
    var prevs: [RegisteredNode] = []
    var values: [PValue] = []
    
    var rubyCount: Int {
        return self.data.ruby.count
    }

    static var EOSNode: FlickLatticeNode {
        return FlickLatticeNode(data: BOSEOSDicDataElement.EOSData)
    }

    func getSqueezedNode(_ index: Int, value: PValue) -> FlickRegisteredNode {
        return FlickRegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value)
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
    private var romanString: String
    
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
        return RomanRegisteredNode(data: self.data, registered: self.prevs[index], totalValue: value, romanString: self.romanString)
    }

}
 
