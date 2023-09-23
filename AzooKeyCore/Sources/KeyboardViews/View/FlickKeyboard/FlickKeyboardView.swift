//
//  FlickKeyboardView.swift
//  Keyboard
//
//  Created by ensan on 2020/04/16.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

struct FlickKeyboardView<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    @State private var suggestState = FlickSuggestState()

    private let tabDesign: TabDependentDesign
    private let models: [KeyPosition: (model: any FlickKeyModelProtocol, width: Int, height: Int)]
    init(keyModels: [[any FlickKeyModelProtocol]], interfaceSize: CGSize, keyboardOrientation: KeyboardOrientation) {
        self.tabDesign = TabDependentDesign(width: 5, height: 4, interfaceSize: interfaceSize, layout: .flick, orientation: keyboardOrientation)

        var models: [KeyPosition: (model: any FlickKeyModelProtocol, width: Int, height: Int)] = [:]
        for h in keyModels.indices {
            for v in keyModels[h].indices {
                let model = keyModels[h][v]
                models[KeyPosition.gridFit(x: h, y: v)] = (keyModels[h][v], 1, model is FlickEnterKeyModel<Extension> ? 2 : 1)
            }
        }
        self.models = models
    }

    var body: some View {
        let layout = CustardInterfaceLayoutGridValue(rowCount: Int(tabDesign.horizontalKeyCount), columnCount: Int(tabDesign.verticalKeyCount))
        CustardFlickKeysView(models: models, tabDesign: tabDesign, layout: layout) {(view: FlickKeyView<Extension>, _, _) in
            view
        }
    }
}
