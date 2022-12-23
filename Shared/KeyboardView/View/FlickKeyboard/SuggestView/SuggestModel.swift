//
//  SuggestModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/05.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

enum SuggestModelKeyType {
    case normal
    case enter(Int)
    case custom(CustomizableFlickKey)
    case aA
}

struct SuggestModel {
    private(set) var variableSection = SuggestModelVariableSection()

    private let keyType: SuggestModelKeyType
    private let _flickModels: [FlickDirection: FlickedKeyModel]
    var flickModels: [FlickDirection: FlickedKeyModel] {
        switch self.keyType {
        case .normal, .enter:
            return _flickModels
        case let .custom(setting):
            return setting.get().flick
        case .aA:
            return FlickAaKeyModel.shared.flickKeys
        }
    }

    init(_ flickModels: [FlickDirection: FlickedKeyModel] = [:], keyType: SuggestModelKeyType = .normal) {
        self._flickModels = flickModels
        self.keyType = keyType
    }

    func setSuggestState(_ state: SuggestState) {
        self.variableSection.suggestState = state
    }
}

final class SuggestModelVariableSection: ObservableObject {
    @Published var suggestState: SuggestState = .nothing
}
