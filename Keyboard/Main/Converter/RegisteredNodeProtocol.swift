//
//  RegisteredNode.swift
//  Keyboard
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
protocol RegisteredNodeProtocol{
    var data: DicDataElementProtocol {get}
    var prev: RegisteredNodeProtocol? {get}
    var totalValue: PValue {get}
    var ruby: String {get}

    static func BOSNode() -> Self
}

struct FlickRegisteredNode: RegisteredNodeProtocol {
    let data: DicDataElementProtocol
    let prev: RegisteredNodeProtocol?
    let totalValue: PValue
    var ruby: String{
        return self.data.ruby
    }
    
    init(data: DicDataElementProtocol, registered: RegisteredNodeProtocol?, totalValue: PValue){
        self.data = data
        self.prev = registered
        self.totalValue = totalValue
    }

    static func BOSNode() -> FlickRegisteredNode {
        FlickRegisteredNode(data: BOSEOSDicDataElement.BOSData, registered: nil, totalValue: 0)
    }
}

struct RomanRegisteredNode: RegisteredNodeProtocol {
    let data: DicDataElementProtocol
    let prev: RegisteredNodeProtocol?
    let totalValue: PValue
    let ruby: String
    
    init(data: DicDataElementProtocol, registered: RegisteredNodeProtocol?, totalValue: PValue, romanString: String){
        self.data = data
        self.prev = registered
        self.totalValue = totalValue
        self.ruby = romanString
    }

    static func BOSNode() -> RomanRegisteredNode {
        RomanRegisteredNode(data: BOSEOSDicDataElement.BOSData, registered: nil, totalValue: 0, romanString: "")
    }
}

extension RegisteredNodeProtocol{
    func getCandidateData() -> CandidateData {
        guard let prev = self.prev else {
            let unit = ClauseDataUnit()
            unit.rcid = self.data.rcid
            unit.mid = self.data.mid
            unit.ruby = self.ruby
            return CandidateData(clauses: [(clause: unit, value: .zero)], data: [])
        }
        var lastcandidate = prev.getCandidateData()    //自分に至るregisterdそれぞれのデータに処理
        
        if self.data.word.isEmpty{
            return lastcandidate
        }

        guard let lastClause = lastcandidate.lastClause else{
            return lastcandidate
        }

        if lastClause.text.isEmpty || !DicDataStore.isClause(prev.data.rcid, self.data.lcid){
            //文節ではないので、最後に追加する。
            lastClause.text.append(self.data.word)
            lastClause.ruby.append(self.ruby)
            lastClause.rcid = self.data.rcid
            //最初だった場合を想定している
            if (lastClause.mid == 500 && self.data.mid != 500) || DicDataStore.includeMMValueCalculation(self.data){
                lastClause.mid = self.data.mid
            }
            lastcandidate.clauses[lastcandidate.clauses.count-1].value = self.totalValue
            lastcandidate.data.append(self.data)
            return lastcandidate
        }
        //文節の区切りだった場合
        else{
            let unit = ClauseDataUnit()
            unit.text = self.data.word
            unit.ruby = self.ruby
            unit.lcid = self.data.lcid
            unit.rcid = self.data.rcid

            if DicDataStore.includeMMValueCalculation(self.data){
                unit.mid = self.data.mid
            }
            //前の文節の処理
            lastClause.nextLcid = self.data.lcid
            switch Store.shared.keyboardType{
            case .flick:
                break
            case .roman:
                lastClause.ruby = lastClause.ruby.roman2katakana
            }
            lastcandidate.clauses.append((clause: unit, value: self.totalValue))
            lastcandidate.data.append(self.data)
            return lastcandidate
        }
    }
}

