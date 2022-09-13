//
//  KeyboardPreview.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

private struct CandidateMock: ResultViewItemData {
    let inputable: Bool = true
    var text: String
    func getDebugInformation() -> String {
        return "CandidateMock: \(text)"
    }
}

struct KeyboardPreview: View {
    private let resultModel = ResultModel<CandidateMock>()
    private let theme: ThemeData

    private let scale: CGFloat
    private let defaultTab: Tab.ExistentialTab?

    init(theme: ThemeData, scale: CGFloat = 1, defaultTab: Tab.ExistentialTab? = nil) {
        SemiStaticStates.shared.setScreenSize(
            size: UIScreen.main.bounds.size,
            orientation: UIDevice.current.orientation == UIDeviceOrientation.unknown ? .vertical : (UIDevice.current.orientation == UIDeviceOrientation.portrait ? .vertical : .horizontal)
        )
        resultModel.setResults([
            CandidateMock(text: "azooKey"),
            CandidateMock(text: "あずーきー"),
            CandidateMock(text: "アズーキー")
        ])
        self.theme = theme
        self.scale = scale
        self.defaultTab = defaultTab
    }

    var body: some View {
        KeyboardView<CandidateMock>(resultModel: resultModel, defaultTab: defaultTab)
            .environment(\.themeEnvironment, theme)
            .environment(\.showMessage, false)
            .scaleEffect(scale)
            .frame(width: SemiStaticStates.shared.screenWidth * scale, height: Design.keyboardScreenHeight * scale)
    }
}
