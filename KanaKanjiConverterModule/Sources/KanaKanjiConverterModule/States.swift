//
//  States.swift
//  
//
//  Created by ensan on 2023/04/30.
//


public enum InputStyle: String {
    /// 入力された文字を直接入力するスタイル
    case direct = "direct"
    /// ローマ字日本語入力とするスタイル
    case roman2kana = "roman"
}


public enum KeyboardLanguage: String, Codable, Equatable {
    case en_US
    case ja_JP
    case el_GR
    case none

    var symbol: String {
        switch self {
        case .en_US:
            return "A"
        case .el_GR:
            return "Ω"
        case .ja_JP:
            return "あ"
        case .none:
            return ""
        }
    }
}

public enum LearningType {
    case inputAndOutput
    case onlyOutput
    case nothing 

    var needUpdateMemory: Bool {
        self == .inputAndOutput
    }

    var needUsingMemory: Bool {
        self != .nothing
    }
}


public enum ConverterBehaviorSemantics {
    /// 標準的な日本語入力のように、変換する候補を選ぶパターン
    case conversion
    /// iOSの英語入力のように、確定は不要だが、左右の文字列の置き換え候補が出てくるパターン
    case replacement([ReplacementTarget])

    public enum ReplacementTarget: UInt8 {
        case emoji
    }
}
