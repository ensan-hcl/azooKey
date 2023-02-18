//
//  PredictionCandidateSetting.swift
//  azooKey
//
//  Created by ensan on 2023/02/18.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation
import SwiftUI

/// 日本語の予測変換の設定
struct PredictionCandidateSettingKey: KeyboardSettingKey, StoredInUserDefault {
    enum Value: String {
        case short = "short"  // 単語だけ表示する方式
        case long                      // 常に全て表示する方式
        case disabled                    // 無効化する方式
    }
    // TODO: Localize
    static let title: LocalizedStringKey = "予測変換の設定"
    static let explanation: LocalizedStringKey = "予測変換の動作を変更できます。"
    static let defaultValue: Value = Value.long
    static let key: String = "japanese_prediction_candidate_setting"

    static func get() -> Value? {
        let object = SharedStore.userDefaults.object(forKey: key)
        if let object, let value = object as? String {
            return Value(rawValue: value)
        }
        return nil
    }
    static func set(newValue: Value) {
        SharedStore.userDefaults.set(newValue.rawValue, forKey: key)
    }

    static var value: Value {
        get {
            get() ?? defaultValue
        }
        set {
            set(newValue: newValue)
        }
    }
}

extension KeyboardSettingKey where Self == PredictionCandidateSettingKey {
    static var japanesePredictionCandidate: Self { .init() }
}
