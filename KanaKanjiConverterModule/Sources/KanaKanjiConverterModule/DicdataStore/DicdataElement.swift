//
//  DicdataElement.swift
//  Keyboard
//
//  Created by ensan on 2020/09/10.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

public struct DicdataElement: Equatable, Hashable {
    static let BOSData = Self(word: "", ruby: "", cid: CIDData.BOS.cid, mid: MIDData.BOS.mid, value: 0, adjust: 0)
    static let EOSData = Self(word: "", ruby: "", cid: CIDData.EOS.cid, mid: MIDData.EOS.mid, value: 0, adjust: 0)

    public init(word: String, ruby: String, lcid: Int, rcid: Int, mid: Int, value: PValue, adjust: PValue = .zero) {
        self.word = word
        self.ruby = ruby
        self.lcid = lcid
        self.rcid = rcid
        self.mid = mid
        self.baseValue = value
        self.adjust = adjust
    }

    public init(word: String, ruby: String, cid: Int, mid: Int, value: PValue, adjust: PValue = .zero) {
        self.word = word
        self.ruby = ruby
        self.lcid = cid
        self.rcid = cid
        self.mid = mid
        self.baseValue = value
        self.adjust = adjust
    }

    public init(ruby: String, cid: Int, mid: Int, value: PValue, adjust: PValue = .zero) {
        self.word = ruby
        self.ruby = ruby
        self.lcid = cid
        self.rcid = cid
        self.mid = mid
        self.baseValue = value
        self.adjust = adjust
    }

    public func adjustedData(_ adjustValue: PValue) -> Self {
        .init(word: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: baseValue, adjust: adjustValue + self.adjust)
    }

    public var word: String
    public var ruby: String
    public var lcid: Int
    public var rcid: Int
    public var mid: Int
    var baseValue: PValue
    public var adjust: PValue

    public func value() -> PValue {
        min(.zero, self.baseValue + self.adjust)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.word == rhs.word && lhs.ruby == rhs.ruby && lhs.lcid == rhs.lcid && lhs.mid == rhs.mid && lhs.rcid == rhs.rcid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        hasher.combine(ruby)
        hasher.combine(lcid)
        hasher.combine(rcid)
    }
}

extension DicdataElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        "(ruby: \(self.ruby), word: \(self.word), adjust: \(self.adjust), value: \(self.value()))"
    }
}
