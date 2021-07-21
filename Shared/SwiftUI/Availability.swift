//
//  Availability.swift
//  Availability
//
//  Created by β α on 2021/07/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

// SubmitLabel
enum _Available_SubmitLabel {
    case `continue`, done, go, join, next, `return`, route, search, send

    @available(iOS 15, *)
    var label: SubmitLabel {
        switch self {
        case .continue: return .continue
        case .done: return .done
        case .go: return .go
        case .join: return .join
        case .next: return .next
        case .return: return .return
        case .route: return .route
        case .search: return .search
        case .send: return .send
        }
    }
}

// SubmitLabel
enum _Available_SubmitTriggers {
    case text, search

    @available(iOS 15, *)
    var triggers: SubmitTriggers {
        switch self {
        case .text: return .text
        case .search: return .search
        }
    }
}

// Bool
// In order to duplicate same function
enum _Available_Bool: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        switch value {
        case true: self = .true
        case false: self = .false
        }
    }

    case `false`, `true`
    var bool: Bool {
        switch self {
        case .false: return false
        case .true: return true
        }
    }

}

extension View {
    @ViewBuilder
    func submitLabel(_ label: _Available_SubmitLabel) -> some View {
        if #available(iOS 15, *) {
            self.submitLabel(label.label)
        } else {
            self
        }
    }

    @ViewBuilder
    func submitScope(_ isBlocking: _Available_Bool = .true) -> some View {
        if #available(iOS 15, *) {
            self.submitScope(isBlocking.bool)
        } else {
            self
        }
    }

    @ViewBuilder
    func onSubmit(of triggers: _Available_SubmitTriggers = .text, _ action: @escaping (() -> Void)) -> some View {
        if #available(iOS 15, *) {
            self.onSubmit(of: triggers.triggers, action)
        } else {
            self
        }
    }
}

