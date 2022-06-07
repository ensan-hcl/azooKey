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

// HorizontalEdge
enum _Available_HorizontalEdge {
    case leading, trailing
    @available(iOS 15, *)
    var horizontalEdge: HorizontalEdge {
        switch self {
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
}

// VerticalEdge
enum _Available_VerticalEdge {
    case bottom, top
    @available(iOS 15, *)
    var verticalEdge: VerticalEdge {
        switch self {
        case .bottom: return .bottom
        case .top: return .top
        }
    }
    enum Set {
        case all, bottom, top
        @available(iOS 15, *)
        var set: VerticalEdge.Set {
            switch self {
            case .all: return .all
            case .bottom: return .bottom
            case .top: return .top
            }
        }
    }
}


// Visibility
enum _Available_Visibility {
    case automatic, hidden, visible
    @available(iOS 15, *)
    var visibility: Visibility {
        switch self {
        case .automatic: return .automatic
        case .hidden: return .hidden
        case .visible: return .visible
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

extension View {
    @ViewBuilder
    func swipeActions(edge: _Available_HorizontalEdge = .trailing, allowsFullSwipe: Bool = true, content: () -> some View) -> some View {
        if #available(iOS 15, *) {
            self.swipeActions(edge: edge.horizontalEdge, allowsFullSwipe: allowsFullSwipe, content: content)
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder
    func listRowSeparator(_ visibility: _Available_Visibility, edges: _Available_VerticalEdge.Set = .all) -> some View {
        if #available(iOS 15, *) {
            self.listRowSeparator(visibility.visibility, edges: edges.set)
        } else {
            self
        }
    }
}
