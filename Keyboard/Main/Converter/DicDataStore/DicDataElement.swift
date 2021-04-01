//
//  DicDataElementProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/09/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
/*
 メモリを効率的に利用するため、データクラスを細かく分ける。
 LRE lcid == rcid?
 SRE string == ruby?
 V3E value == -30.0?
 の三点、8種類のデータを作成する。
 */

protocol DicDataElementProtocol: CustomDebugStringConvertible {
    var word: String {get}
    var ruby: String {get}
    var lcid: Int {get}
    var rcid: Int {get}
    var mid: Int {get}
    var baseValue: PValue {get}
    var adjust: PValue {get}

    func value() -> PValue
    func adjustedData(_ adjustValue: PValue) -> Self
    func adjustZero() -> Self
}

extension DicDataElementProtocol {
    func value() -> PValue {
        return min(.zero, self.baseValue + self.adjust)
    }
}

extension DicDataElementProtocol {
    var debugDescription: String {
        return "(ruby: \(self.ruby), word: \(self.word), adjust: \(self.adjust), value: \(self.value()))"
    }
}

func ==(lhs: DicDataElementProtocol, rhs: DicDataElementProtocol) -> Bool {
    return lhs.ruby == rhs.ruby && lhs.word == rhs.word && lhs.lcid == rhs.lcid && lhs.rcid == rhs.rcid && lhs.mid == rhs.mid
}
/// LREかつSREかつV3E
struct LRE_SRE_V3E_DicDataElement: DicDataElementProtocol {

    init(ruby: String, cid: Int, mid: Int, adjust: PValue = .zero) {
        self.ruby = ruby
        self.cid = cid
        self.mid = mid
        self.adjust = adjust
    }

    func adjustedData(_ adjustValue: PValue) -> Self {
        return LRE_SRE_V3E_DicDataElement(ruby: ruby, cid: cid, mid: mid, adjust: adjustValue + self.adjust)
    }

    func adjustZero() -> Self {
        return LRE_SRE_V3E_DicDataElement(ruby: ruby, cid: cid, mid: mid, adjust: .zero)
    }

    let ruby: String
    let cid: Int
    let mid: Int
    let adjust: PValue
    let baseValue: PValue = -30
    var word: String {
        return ruby
    }

    var lcid: Int {
        return cid
    }

    var rcid: Int {
        return cid
    }

}

/// LREかつSRE
struct LRE_SRE_DicDataElement: DicDataElementProtocol {
    func adjustZero() -> Self {
        return LRE_SRE_DicDataElement(ruby: ruby, cid: cid, mid: mid, value: baseValue, adjust: .zero)
    }

    init(ruby: String, cid: Int, mid: Int, value: PValue, adjust: PValue = .zero) {
        self.ruby = ruby
        self.cid = cid
        self.mid = mid
        self.baseValue = value
        self.adjust = adjust
    }

    func adjustedData(_ adjustValue: PValue) -> Self {
        return LRE_SRE_DicDataElement(ruby: ruby, cid: cid, mid: mid, value: baseValue, adjust: adjustValue + self.adjust)
    }

    let ruby: String
    let cid: Int
    let mid: Int
    let baseValue: PValue
    let adjust: PValue

    var word: String {
        return ruby
    }

    var lcid: Int {
        return cid
    }

    var rcid: Int {
        return cid
    }
}

/// LREかつV3E
struct LRE_V3E_DicDataElement: DicDataElementProtocol {
    func adjustZero() -> Self {
        return LRE_V3E_DicDataElement(string: word, ruby: ruby, cid: cid, mid: mid, adjust: .zero)
    }

    init(string: String, ruby: String, cid: Int, mid: Int, adjust: PValue = .zero) {
        self.ruby = ruby
        self.cid = cid
        self.mid = mid
        self.word = string
        self.adjust = adjust
    }

    func adjustedData(_ adjustValue: PValue) -> Self {
        return LRE_V3E_DicDataElement(string: word, ruby: ruby, cid: cid, mid: mid, adjust: adjustValue + self.adjust)
    }

    let word: String
    let ruby: String
    let cid: Int
    let mid: Int
    let adjust: PValue
    let baseValue: PValue = -30

    var lcid: Int {
        return cid
    }

    var rcid: Int {
        return cid
    }
}

/// LRE
struct LRE_DicDataElement: DicDataElementProtocol {
    func adjustZero() -> Self {
        return LRE_DicDataElement(word: word, ruby: ruby, cid: cid, mid: mid, value: baseValue, adjust: .zero)
    }

    init(word: String, ruby: String, cid: Int, mid: Int, value: PValue, adjust: PValue = .zero) {
        self.word = word
        self.ruby = ruby
        self.cid = cid
        self.mid = mid
        self.baseValue = value
        self.adjust = adjust
    }

    func adjustedData(_ adjustValue: PValue) -> Self {
        return LRE_DicDataElement(word: word, ruby: ruby, cid: cid, mid: mid, value: baseValue, adjust: adjustValue + self.adjust)
    }
    let word: String
    let ruby: String
    let cid: Int
    let mid: Int
    let baseValue: PValue
    let adjust: PValue

    var lcid: Int {
        return cid
    }

    var rcid: Int {
        return cid
    }
}

/// SREかつV3E
struct SRE_V3E_DicDataElement: DicDataElementProtocol {
    func adjustZero() -> Self {
        return SRE_V3E_DicDataElement(ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, adjust: .zero)
    }

    init(ruby: String, lcid: Int, rcid: Int, mid: Int, adjust: PValue = .zero) {
        self.ruby = ruby
        self.lcid = lcid
        self.rcid = rcid
        self.mid = mid
        self.adjust = adjust
    }

    func adjustedData(_ adjustValue: PValue) -> Self {
        return SRE_V3E_DicDataElement(ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, adjust: adjustValue + self.adjust)
    }
    let ruby: String
    let lcid: Int
    let rcid: Int
    let mid: Int
    let baseValue: PValue = -30
    let adjust: PValue

    var word: String {
        return ruby
    }
}

/// SRE
struct SRE_DicDataElement: DicDataElementProtocol {
    func adjustZero() -> Self {
        return SRE_DicDataElement(ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: baseValue, adjust: .zero)
    }

    init(ruby: String, lcid: Int, rcid: Int, mid: Int, value: PValue, adjust: PValue = .zero) {
        self.ruby = ruby
        self.lcid = lcid
        self.rcid = rcid
        self.mid = mid
        self.baseValue = value
        self.adjust = adjust
    }

    func adjustedData(_ adjustValue: PValue) -> Self {
        return SRE_DicDataElement(ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: baseValue, adjust: adjustValue + self.adjust)
    }

    let ruby: String
    let lcid: Int
    let rcid: Int
    let mid: Int
    let baseValue: PValue
    let adjust: PValue

    var word: String {
        return ruby
    }

}

/// V3E
struct V3E_DicDataElement: DicDataElementProtocol {
    func adjustZero() -> Self {
        return V3E_DicDataElement(string: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, adjust: .zero)
    }

    init(string: String, ruby: String, lcid: Int, rcid: Int, mid: Int, adjust: PValue = .zero) {
        self.word = string
        self.ruby = ruby
        self.lcid = lcid
        self.rcid = rcid
        self.mid = mid
        self.adjust = adjust
    }

    func adjustedData(_ adjustValue: PValue) -> Self {
        return V3E_DicDataElement(string: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, adjust: adjustValue + self.adjust)
    }
    let word: String
    let ruby: String
    let lcid: Int
    let rcid: Int
    let mid: Int
    let adjust: PValue
    let baseValue: PValue = -30
}

struct All_DicDataElement: DicDataElementProtocol {
    func adjustZero() -> Self {
        return All_DicDataElement(string: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: baseValue, adjust: .zero)
    }

    init(string: String, ruby: String, lcid: Int, rcid: Int, mid: Int, value: PValue, adjust: PValue = .zero) {
        self.word = string
        self.ruby = ruby
        self.lcid = lcid
        self.rcid = rcid
        self.mid = mid
        self.baseValue = value
        self.adjust = adjust
    }

    func adjustedData(_ adjustValue: PValue) -> Self {
        return All_DicDataElement(string: word, ruby: ruby, lcid: lcid, rcid: rcid, mid: mid, value: baseValue, adjust: adjustValue + self.adjust)
    }

    let word: String
    let ruby: String
    let lcid: Int
    let rcid: Int
    let mid: Int
    let baseValue: PValue
    let adjust: PValue

}

struct BOSEOSDicDataElement: DicDataElementProtocol {
    func adjustZero() -> BOSEOSDicDataElement {
        return self
    }

    static let BOSData = BOSEOSDicDataElement(cid: .zero)
    static let EOSData = BOSEOSDicDataElement(cid: 1316)

    private init(cid: Int) {
        self.cid = cid
    }
    let word: String = ""
    let ruby: String = ""
    let cid: Int
    let mid: Int = 500
    let baseValue: PValue = .zero
    let adjust: PValue = .zero

    var lcid: Int {
        return cid
    }
    var rcid: Int {
        return cid
    }

    func adjustedData(_ adjustValue: PValue) -> BOSEOSDicDataElement {
        return BOSEOSDicDataElement(cid: cid)
    }

}

/// 生成されたデータ。
struct GeneratedDicDataElement: DicDataElementProtocol {
    func adjustZero() -> GeneratedDicDataElement {
        return GeneratedDicDataElement(word: word, ruby: ruby, cid: cid, mid: mid, value: baseValue, adjust: .zero)
    }

    init(word: String, ruby: String, cid: Int, mid: Int, value: PValue, adjust: PValue = .zero) {
        self.word = word
        self.ruby = ruby
        self.cid = cid
        self.mid = mid
        self.baseValue = value
        self.adjust = adjust
    }

    func adjustedData(_ adjustValue: PValue) -> GeneratedDicDataElement {
        return GeneratedDicDataElement(word: word, ruby: ruby, cid: cid, mid: mid, value: baseValue, adjust: adjustValue + self.adjust)
    }

    let word: String
    let ruby: String
    let cid: Int
    let mid: Int
    let baseValue: PValue
    let adjust: PValue

    var lcid: Int {
        return cid
    }
    var rcid: Int {
        return cid
    }

}
