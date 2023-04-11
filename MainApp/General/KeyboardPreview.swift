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
    private let theme: ThemeData

    private let scale: CGFloat
    private let defaultTab: Tab.ExistentialTab?
    @StateObject private var variableStates = VariableStates(interfaceWidth: UIScreen.main.bounds.width, orientation: MainAppDesign.keyboardOrientation)

    init(theme: ThemeData? = nil, scale: CGFloat = 1, defaultTab: Tab.ExistentialTab? = nil) {
        self.theme = theme ?? .default(layout: defaultTab?.layout ?? .flick)
        self.scale = scale
        self.defaultTab = defaultTab
    }

    var body: some View {
        KeyboardView(defaultTab: defaultTab)
            .environmentObject(variableStates)
            .environment(\.themeEnvironment, theme)
            .environment(\.showMessage, false)
            .scaleEffect(scale)
            .frame(width: SemiStaticStates.shared.screenWidth * scale, height: Design.keyboardScreenHeight(upsideComponent: nil, orientation: MainAppDesign.keyboardOrientation) * scale)
            .onAppear {
                variableStates.resultModelVariableSection.setResults([
                    CandidateMock(text: "azooKey"),
                    CandidateMock(text: "あずーきー"),
                    CandidateMock(text: "アズーキー")
                ])
            }
    }
}
