//
//  InputData.swift
//  Keyboard
//
//  Created by β α on 2020/09/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

/// 入力を管理するInputDataのprotocol
/// - Note:structに対して付与すること。
protocol InputDataProtocol{
    var katakanaString: String  {get}
    var characters: [Character] {get}
    var count: Int              {get}
    
    subscript(_ range: ClosedRange<Int>) -> String {get}
    
    ///誤り訂正候補を取得する関数。。
    ///   - left...right :の範囲の文字列が用いられる。
    func getRangeWithTypos(_ left: Int, _ right: Int) -> [(string: String, penalty: PValue)]
    
    func isAfterDeletedCharacter(previous: Self) -> Int?
    func isAfterDeletedPrefixCharacter(previous: Self) -> Int?
    func isAfterAddedCharacter(previous: Self) -> Int?
    func isAfterReplacedCharacter(previous: Self) -> (deleted: Int, added: Int)?

}

extension InputDataProtocol{
    func translated<InputData: InputDataProtocol>() -> InputData {
        if let data = self as? InputData{
            return data
        }
        if self is DirectInputData{
            if InputData.self == RomanInputData.self{
                return RomanInputData(self.katakanaString, history: KanaRomanStateHolder(components: [KanaComponent(internalText: self.katakanaString, kana: self.katakanaString, isFreezed: true, escapeRomanKanaConverting: true)])) as! InputData
            }
        }
        if self is RomanInputData{
            if InputData.self == DirectInputData.self{
                return DirectInputData(self.katakanaString) as! InputData
            }
        }
        fatalError("Unexpected situation")
    }
}

extension InputDataProtocol{    
    internal func isAfterAddedCharacter(previous: Self) -> Int? {
        if self.characters.count == previous.count{
            return nil
        }
        let prefix: [Character] = Array(self.characters.prefix(previous.characters.count))
        if prefix == previous.characters{
            return self.characters.count - previous.count
        }
        return nil
    }
    
    internal func isAfterDeletedCharacter(previous: Self) -> Int? {
        let prefix: [Character] = Array(previous.characters.prefix(self.characters.count))
        if prefix == self.characters{
            let dif = previous.characters.count - self.characters.count
            if dif == 0{
                return nil
            }
            return dif
        }else{
            return nil
        }
    }
    
    internal func isAfterDeletedPrefixCharacter(previous: Self) -> Int? {
        if previous.katakanaString.hasSuffix(self.katakanaString){
            let dif = previous.characters.count - self.characters.count
            if dif == 0{
                return nil
            }
            return dif
        }else{
            return nil
        }
    }

    internal func isAfterReplacedCharacter(previous: Self) -> (deleted: Int, added: Int)? {
        let endIndex = min(previous.characters.endIndex, self.characters.endIndex)
        var i = 0
        while i<endIndex && previous.characters[i] == self.characters[i]{
            i += 1
        }
        if i == 0{
            return nil
        }
        let deleted = previous.characters.count - i
        let added = self.characters.count - i
        if deleted == 0 || added == 0{
            return nil
        }
        return (deleted, added)
    }

}


