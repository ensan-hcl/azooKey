//
//  VariationsModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct VariationsModel {
    let variations: [(label: KeyLabelType, actions: [ActionType])]
    var direction: VariationsViewDirection

    init(_ variations: [(label: KeyLabelType, actions: [ActionType])], direction: VariationsViewDirection = .center) {
        self.variations = variations
        self.direction = direction
    }

    func performSelected(selection: Int?) {
        if self.variations.isEmpty {
            return
        }
        guard let selection else {
            return
        }
        VariableStates.shared.action.registerActions(self.variations[selection].actions)
    }

    func getSelection(dx: CGFloat, tabDesign: TabDependentDesign) -> Int {
        let count = CGFloat(self.variations.count)
        let width = tabDesign.keyViewWidth
        let spacing = tabDesign.horizontalSpacing
        let start: CGFloat
        switch self.direction {
        case .center:
            start = -(width * count + spacing * (count - 1)) / 2
        case .right:
            start = 0
        case .left:
            start = -(width * count + spacing * (count - 1))
        }
        let selection = (dx - start) / width
        return min(max(Int(selection), 0), Int(count) - 1)
    }
}
