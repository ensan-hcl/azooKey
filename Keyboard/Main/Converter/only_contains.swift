//
//  extension StringProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/10/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation


extension StringProtocol{
    var onlyRomanAlphabet: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    var containsRomanAlphabet: Bool {
        return !isEmpty && range(of: "[a-zA-Z]", options: .regularExpression) != nil
    }

    var isEnglishSentence: Bool {
        return !isEmpty && range(of: "[^0-9a-zA-Z\n !'_<>\\[\\]{}*@`\\^|~=\"#$%&+(),-./:;?’]", options: .regularExpression) == nil
    }
}


extension StringProtocol{
    @inlinable
    public func indexFromStart(_ offset: Int) -> Index {
        return self.index(self.startIndex, offsetBy: offset)
    }

    @inlinable
    subscript(_ index: Int) -> Character {
        get{
            return self[self.indexFromStart(index)]
        }
    }

    @inlinable
    subscript(_ range: ClosedRange<Int>) -> SubSequence {
        get{
            return self[self.indexFromStart(range.lowerBound) ... self.indexFromStart(range.upperBound)]
        }
    }

    @inlinable
    subscript(_ range: Range<Int>) -> SubSequence {
        get{
            return self[self.indexFromStart(range.lowerBound) ..< self.indexFromStart(range.upperBound)]
        }
    }
}
