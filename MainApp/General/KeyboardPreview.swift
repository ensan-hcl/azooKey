//
//  KeyboardPreview.swift
//  MainApp
//
//  Created by ensan on 2021/02/06.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

private struct CandidateMock: ResultViewItemData {
    let inputable: Bool = true
    var text: String
    #if DEBUG
    func getDebugInformation() -> String {
        "CandidateMock: \(text)"
    }
    #endif
}

struct KeyboardPreview: View {
    private let resultModel = ResultModelVariableSection<CandidateMock>()
    private let theme: ThemeData

    private let scale: CGFloat
    private let defaultTab: Tab.ExistentialTab?

    init(theme: ThemeData, scale: CGFloat = 1, defaultTab: Tab.ExistentialTab? = nil) {
        let orientation: KeyboardOrientation
        if UIDevice.current.userInterfaceIdiom == .phone {
            orientation = .vertical
        } else {
            orientation = UIDevice.current.orientation == UIDeviceOrientation.unknown ? .vertical : (UIDevice.current.orientation == UIDeviceOrientation.portrait ? .vertical : .horizontal)
        }
        SemiStaticStates.shared.setScreenWidth(UIScreen.main.bounds.width, orientation: orientation)
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
        KeyboardView<CandidateMock>(resultModelVariableSection: resultModel, defaultTab: defaultTab)
            .environment(\.themeEnvironment, theme)
            .environment(\.showMessage, false)
            .scaleEffect(scale)
            .frame(width: SemiStaticStates.shared.screenWidth * scale, height: Design.keyboardScreenHeight * scale)
    }
}
