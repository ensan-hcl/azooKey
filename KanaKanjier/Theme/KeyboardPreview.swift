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

    init(theme: ThemeData, scale: CGFloat = 1){
        SemiStaticStates.shared.setScreenSize(size: UIScreen.main.bounds.size)
        resultModel.setResults([
            CandidateMock(text: "azooKey"),
            CandidateMock(text: "あずーきー"),
            CandidateMock(text: "アズーキー")
        ])
        self.theme = theme
        self.scale = scale
    }

    var body: some View {
        KeyboardView<CandidateMock>(theme: theme, resultModel: resultModel)
            .scaleEffect(scale)
            .frame(width: Design.shared.screenWidth * scale, height: Design.shared.keyboardScreenHeight * scale)
    }
}
