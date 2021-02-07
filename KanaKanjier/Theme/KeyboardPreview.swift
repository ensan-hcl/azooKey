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
    let resultModel = ResultModel<CandidateMock>()

    init(){
        SemiStaticStates.shared.setScreenSize(size: UIScreen.main.bounds.size)
        resultModel.setResults([
            CandidateMock(text: "azooKey"),
            CandidateMock(text: "あずーきー"),
            CandidateMock(text: "アズーキー")
        ])
    }

    var body: some View {
        KeyboardView<CandidateMock>(resultModel: resultModel)
    }
}
