//
//  File.swift
//  Keyboard
//
//  Created by β α on 2020/04/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct FlickKeyboardView: View{
    @ObservedObject private var variableStates = VariableStates.shared
    @Environment(\.themeEnvironment) private var theme

    private let tabDesign: TabDependentDesign
    private let keyModels: [[FlickKeyModelProtocol]]
    init(keyModels: [[FlickKeyModelProtocol]]){
        self.keyModels = keyModels
        self.tabDesign = TabDependentDesign(width: 5, height: 4, layout: .flick, orientation: VariableStates.shared.keyboardOrientation)
    }

    private var horizontalIndices: Range<Int> {
        keyModels.indices
    }
    
    private func verticalIndices(h: Int) -> Range<Int> {
        keyModels[h].indices
    }
    
    var body: some View {
        ZStack{
            HStack(spacing: tabDesign.horizontalSpacing){
                ForEach(self.horizontalIndices, id: \.self){h in
                    VStack(spacing: tabDesign.verticalSpacing){
                        ForEach(self.verticalIndices(h: h), id: \.self){(v: Int) -> FlickKeyView in
                            let model = self.keyModels[h][v]
                            let size: CGSize = {
                                if model is FlickEnterKeyModel{
                                    return CGSize(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight(heightCount: 2))
                                }else{
                                    return tabDesign.keyViewSize
                                }
                            }()
                            FlickKeyView(model: model, size: size)
                        }
                    }
                }
            }
            HStack(spacing: tabDesign.horizontalSpacing){
                ForEach(self.horizontalIndices, id: \.self){h in
                    VStack(spacing: tabDesign.verticalSpacing){
                        ForEach(self.verticalIndices(h: h), id: \.self){(v: Int) -> SuggestView in
                            let model = self.keyModels[h][v]
                            let size: CGSize = {
                                if model is FlickEnterKeyModel{
                                    return CGSize(width: tabDesign.keyViewWidth, height: tabDesign.keyViewHeight(heightCount: 2))
                                }else{
                                    return tabDesign.keyViewSize
                                }
                            }()
                            SuggestView(model: model.suggestModel, tabDesign: tabDesign, size: size)
                        }
                    }
                }
            }
        }
    }
}

