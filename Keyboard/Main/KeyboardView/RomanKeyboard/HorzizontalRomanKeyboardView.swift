//
//  HorzizontalRomanKeyboardView.swift
//  Keyboard
//
//  Created by β α on 2020/09/21.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct HorizontalRomanKeyboardView: View{
    private let model: HorizontalRomanKeyboardModel
    @ObservedObject private var modelVariableSection: HorizontalRomanKeyboardModelVariableSection

    init(_ model: HorizontalRomanKeyboardModel){
        self.model = model
        self.modelVariableSection = self.model.variableSection
    }
    
    var verticalIndices: Range<Int> {
        switch modelVariableSection.tabState{
        case .hira:
            return self.model.hiraKeyboard.indices
        case .abc:
            return self.model.abcKeyboard.indices
        case .number:
            return self.model.numberKeyboard.indices
        case let .other(string):
            switch string{
            case RomanAdditionalTabs.symbols.identifier:
                return self.model.symbolsKeyboard.indices
            default: return 0..<0
            }
        }
    }

    func horizontalIndices(v: Int) -> Range<Int> {
        switch modelVariableSection.tabState{
        case .hira:
            return self.model.hiraKeyboard[v].indices
        case .abc:
            return self.model.abcKeyboard[v].indices
        case .number:
            return self.model.numberKeyboard[v].indices
        case let .other(string):
            switch string{
            case RomanAdditionalTabs.symbols.identifier:
                return self.model.symbolsKeyboard[v].indices
            default: return 0..<0
            }
        }
    }

    var keyModels: [[RomanKeyModelProtocol]] {
        switch modelVariableSection.tabState{
        case .hira:
            return self.model.hiraKeyboard
        case .abc:
            return self.model.abcKeyboard
        case .number:
            return self.model.numberKeyboard
        case let .other(string):
            switch string{
            case RomanAdditionalTabs.symbols.identifier:
                return self.model.symbolsKeyboard
            default: return []
            }
        }
    }


    var body: some View {
        Group{
            if self.modelVariableSection.isResultViewExpanded{
                ExpandedResultView(model: self.model.expandedResultModel)
            }
            else{
                VStack(spacing: 0){
                ResultView(model: model.resultModel)
                    .padding(.vertical, 6)
                    VStack(spacing: Store.shared.design.keyViewVerticalSpacing){
                        ForEach(self.verticalIndices){(v: Int) in
                            HStack(spacing: Store.shared.design.keyViewHorizontalSpacing){
                                ForEach(self.horizontalIndices(v: v), id: \.self){(h: Int) in
                                    RomanKeyView(self.keyModels[v][h])
                                }
                            }
                        }
                    }
                }
            }
        }.padding(.bottom, 2)

    }
}
