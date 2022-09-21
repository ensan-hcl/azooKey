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
protocol InputDataProtocol {
    var katakanaString: String {get}
    var characters: [Character] {get}
    var count: Int {get}

    subscript(_ range: ClosedRange<Int>) -> String {get}

    /// 誤り訂正候補を取得する関数。。
    ///   - left...right :の範囲の文字列が用いられる。
    func getRangeWithTypos(_ left: Int, _ right: Int) -> [(string: String, penalty: PValue)]

    func isAfterDeletedCharacter(previous: Self) -> Int?
    func isAfterDeletedPrefixCharacter(previous: Self) -> Int?
    func isAfterAddedCharacter(previous: Self) -> Int?
    func isAfterReplacedCharacter(previous: Self) -> (deleted: Int, added: Int)?

}

extension InputDataProtocol {
    func translated<InputData: InputDataProtocol>() -> InputData {
        if let data = self as? InputData {
            return data
        }
        if let self = self as? DirectInputData {
            if InputData.self == RomanInputData.self {
                var composingText = ComposingText()
                _ = composingText.insertAtCursorPosition(self.katakanaString.toHiragana(), inputStyle: .direct)
                return RomanInputData(composingText) as! InputData
            }
        }
        if let self = self as? RomanInputData {
            if InputData.self == DirectInputData.self {
                // TODO: ここをもう少しマシな処理に切り替える
                // 現在はログデータを壊さないようにするための処理としてcountを与えている
                // そうではなく、ログデータ自体をtranslateするべきである
                return DirectInputData(self.katakanaString, count: self.count) as! InputData
            }
        }
        fatalError("Unexpected situation")
    }
}

extension InputDataProtocol {
    internal func isAfterAddedCharacter(previous: Self) -> Int? {
        if self.characters.count <= previous.count {
            return nil
        }
        let prefix: [Character] = Array(self.characters.prefix(previous.characters.count))
        if prefix == previous.characters {
            return self.characters.count - previous.count
        }
        return nil
    }

    internal func isAfterDeletedCharacter(previous: Self) -> Int? {
        if Array(previous.characters.prefix(self.characters.count)) == self.characters {
            let dif = previous.characters.count - self.characters.count
            if dif == 0 {
                return nil
            }
            return dif
        } else {
            return nil
        }
    }

    internal func isAfterDeletedPrefixCharacter(previous: Self) -> Int? {
        if previous.katakanaString.hasSuffix(self.katakanaString) {
            let dif = previous.characters.count - self.characters.count
            if dif == 0 {
                return nil
            }
            return dif
        } else {
            return nil
        }
    }

    internal func isAfterReplacedCharacter(previous: Self) -> (deleted: Int, added: Int)? {
        // 共通接頭辞を求める
        let common = String(self.characters).commonPrefix(with: String(previous.characters))
        if common == "" {
            return nil
        }
        let deleted = previous.characters.count - common.count
        let added = self.characters.count - common.count
        if deleted == 0 || added == 0 {
            return nil
        }
        return (deleted, added)
    }
}
