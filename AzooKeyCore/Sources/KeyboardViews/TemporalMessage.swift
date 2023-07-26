//
//  TemporalMessage.swift
//
//
//  Created by ensan on 2023/07/22.
//

import struct SwiftUI.LocalizedStringKey

public enum TemporalMessage {
    case doneForgetCandidate
    case doneReportWrongConversion
    case failedReportWrongConversion

    var title: LocalizedStringKey {
        switch self {
        case .doneForgetCandidate:
            return "候補の学習をリセットしました"
        case .doneReportWrongConversion:
            return "誤変換を報告しました"
        case .failedReportWrongConversion:
            return "誤変換の報告に失敗しました"
        }
    }

    public enum DismissCondition {
        case auto
        case ok
    }

    var dismissCondition: DismissCondition {
        switch self {
        case .doneForgetCandidate, .doneReportWrongConversion, .failedReportWrongConversion: return .auto
        }
    }
}
