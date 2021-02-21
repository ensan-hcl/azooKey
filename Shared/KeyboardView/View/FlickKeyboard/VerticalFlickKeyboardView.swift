//
//  File.swift
//  Keyboard
//
//  Created by β α on 2020/04/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct VerticalFlickKeyboardView: View{
    private let model = VerticalFlickDataProvider()
    @ObservedObject private var variableStates = VariableStates.shared
    private let theme: ThemeData
    private let tabDesign = TabDependentDesign(width: 5, height: 4, layout: .flick, orientation: .vertical)
    private let keyModels: [[FlickKeyModelProtocol]]
    init(keyModels: [[FlickKeyModelProtocol]], theme: ThemeData){
        self.keyModels = keyModels
        self.theme = theme
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
                        //IDを明示する必要がある。
                        ForEach(self.verticalIndices(h: h), id: \.self){(v: Int) -> FlickKeyView in
                            return FlickKeyView(model: self.keyModels[h][v], theme: theme, tabDesign: tabDesign)
                        }
                    }
                }
            }
            HStack(spacing: tabDesign.horizontalSpacing){
                ForEach(self.horizontalIndices, id: \.self){h in
                    VStack(spacing: tabDesign.verticalSpacing){
                        ForEach(self.verticalIndices(h: h), id: \.self){(v: Int) -> SuggestView in
                            return SuggestView(model: self.keyModels[h][v].suggestModel, theme: theme, tabDesign: tabDesign)
                        }
                    }
                }
            }
        }
    }
}

