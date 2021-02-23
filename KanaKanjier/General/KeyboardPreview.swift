//
//  KeyboardPreview.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct CandidateMock: ResultViewItemData {
    let inputable: Bool = true
    var text: String
}

struct KeyboardPreview: View {
    private let resultModel = ResultModel<CandidateMock>()
    private let theme: ThemeData

    private let scale: CGFloat
    private let defaultTab: Tab?

    init(theme: ThemeData, scale: CGFloat = 1, defaultTab: Tab? = nil){
        SemiStaticStates.shared.setScreenSize(size: UIScreen.main.bounds.size)
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
            .scaleEffect(scale)
            .frame(width: Design.shared.screenWidth * scale, height: Design.shared.keyboardScreenHeight * scale)
    }
}
