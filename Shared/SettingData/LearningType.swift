//
//  LearningType.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

enum LearningType: Int, CaseIterable{
    case inputAndOutput = 0
    case onlyOutput = 1
    case nothing = 2

    var string: LocalizedStringKey {
        switch self{
        case .inputAndOutput: return "学習する(デフォルト)"
        case .onlyOutput: return "新たな学習を停止"
        case .nothing: return "これまでの学習を反映しない"
        }
    }

    var id: Int {
        self.rawValue
    }

    var needUpdateMemory: Bool {
        return self == .inputAndOutput
    }

    var needUsingMemory: Bool {
        return self != .nothing
    }
}

extension LearningType: Savable{
    typealias SaveValue = Int
    var saveValue: Int {
        return self.id
    }

    static func get(_ value: Any) -> LearningType? {
        if let id = value as? Int{
            return Self(rawValue: id)
        }
        return nil
    }
}
