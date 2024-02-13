//
//  MainAppFeedback.swift
//  azooKey
//
//  Created by ensan on 2023/03/14.
//  Copyright © 2023 ensan. All rights reserved.
//

import class UIKit.UINotificationFeedbackGenerator

@MainActor enum MainAppFeedback {
    #if os(iOS)
    private static let feedbackGenerator = UINotificationFeedbackGenerator()
    #endif
    static func success() {
        #if os(iOS)
        feedbackGenerator.notificationOccurred(.success)
        #endif
    }
}
