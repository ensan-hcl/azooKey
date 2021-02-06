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
    private let model: VerticalFlickKeyboardModel
    @ObservedObject private var variableStates = VariableStates.shared

    init(_ model: VerticalFlickKeyboardModel, size: CGSize? = nil){
        self.model = model
    }
    
    private var horizontalIndices: Range<Int> {
        switch variableStates.tabState{
        case .hira:
            return self.model.hiraKeyboard.indices
        case .abc:
            return self.model.abcKeyboard.indices
        case .number:
            return self.model.numberKeyboard.indices
        case let .other(string):
            switch string{
            default: return 0..<0
            }
        }
    }
    
    private func verticalIndices(h: Int) -> Range<Int> {
        switch variableStates.tabState{
        case .hira:
            return self.model.hiraKeyboard[h].indices
        case .abc:
            return self.model.abcKeyboard[h].indices
        case .number:
            return self.model.numberKeyboard[h].indices
        case let .other(string):
            switch string{
            default: return 0..<0
            }
        }
    }
    
    private var keyModels: [[FlickKeyModelProtocol]] {
        switch variableStates.tabState{
        case .hira:
            return self.model.hiraKeyboard
        case .abc:
            return self.model.abcKeyboard
        case .number:
            return self.model.numberKeyboard
        case let .other(string):
            switch string{
            default: return []
            }
            
        }
    }

    var body: some View {
        ZStack{
            HStack(spacing: Design.shared.horizontalSpacing){
                ForEach(self.horizontalIndices, id: \.self){h in
                    VStack(spacing: Design.shared.verticalSpacing){
                        //IDを明示する必要がある。
                        ForEach(self.verticalIndices(h: h), id: \.self){(v: Int) -> FlickKeyView in
                            return FlickKeyView(model: self.keyModels[h][v])
                        }
                    }
                }
            }
            HStack(spacing: Design.shared.horizontalSpacing){
                ForEach(self.horizontalIndices, id: \.self){h in
                    VStack(spacing: Design.shared.verticalSpacing){
                        ForEach(self.verticalIndices(h: h), id: \.self){(v: Int) -> SuggestView in
                            return SuggestView(model: self.keyModels[h][v].suggestModel)
                        }
                    }
                }
            }
        }
    }
}

