//
//  LearningTypeSetting.swift
//  LearningTypeSetting
//
//  Created by ensan on 2021/08/11.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import KanaKanjiConverterModule
import SwiftUI

public extension LearningType {
    var string: LocalizedStringKey {
        switch self {
        case .inputAndOutput: return "学習する(デフォルト)"
        case .onlyOutput: return "新たな学習を停止"
        case .nothing: return "これまでの学習を反映しない"
        }
    }

    var id: Int {
        self.rawValue
    }

    var needUpdateMemory: Bool {
        self == .inputAndOutput
    }

    var needUsingMemory: Bool {
        self != .nothing
    }
}

extension LearningType: Savable {
    typealias SaveValue = Int
    var saveValue: Int {
        self.id
    }

    public static func get(_ value: Any) -> LearningType? {
        if let id = value as? Int {
            return Self(rawValue: id)
        }
        return nil
    }
}

public struct LearningTypeSetting: KeyboardSettingKey {
    public static let defaultValue = LearningType.inputAndOutput
    public static let title: LocalizedStringKey = "学習の使用"
    public static let explanation: LocalizedStringKey = "「新たに学習し、反映する(デフォルト)」「新たな学習を停止する」「新たに学習せず、これまでの学習も反映しない」選択できます。この設定の変更で学習結果が消えることはありません。"
    public static let key = "memory_learining_styple_setting"
    @MainActor public static var value: LearningType {
        get {
            if let object = SharedStore.userDefaults.object(forKey: key),
               let value = LearningType.get(object) {
                return value
            }
            return defaultValue
        }
        set {
            SharedStore.userDefaults.set(newValue.saveValue, forKey: key)
        }
    }
}

public extension KeyboardSettingKey where Self == LearningTypeSetting {
    static var learningType: Self { .init() }
}
