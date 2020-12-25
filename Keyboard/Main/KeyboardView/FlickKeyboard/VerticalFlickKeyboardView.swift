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
    @ObservedObject private var modelVariableSection: VerticalFlickKeyboardModelVariableSection

    init(_ model: VerticalFlickKeyboardModel, size: CGSize? = nil){
        debug(size)
        self.model = model
        self.modelVariableSection = model.variableSection
    }
    
    var horizontalIndices: Range<Int> {
        switch modelVariableSection.tabState{
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
        switch modelVariableSection.tabState{
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
        switch modelVariableSection.tabState{
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
        Group{
            if self.modelVariableSection.isResultViewExpanded{
                ExpandedResultView(model: self.model.expandedResultModel)
            }else{
                VStack(spacing: 0){
                    ResultView(model: model.resultModel)
                        .padding(.bottom, 6)
                    ZStack{
                        HStack(spacing: Design.shared.keyViewHorizontalSpacing){
                            ForEach(self.horizontalIndices){h in
                                VStack(spacing: Design.shared.keyViewVerticalSpacing){
                                    //IDを明示する必要がある。
                                    ForEach(self.verticalIndices(h: h), id: \.self){(v: Int) -> FlickKeyView in
                                        return FlickKeyView(model: self.keyModels[h][v])
                                    }
                                }
                            }
                        }
                        HStack(spacing: Design.shared.keyViewHorizontalSpacing){
                            ForEach(self.horizontalIndices){h in
                                VStack(spacing: Design.shared.keyViewVerticalSpacing){
                                    ForEach(self.verticalIndices(h: h), id: \.self){(v: Int) -> SuggestView in
                                        return SuggestView(model: self.keyModels[h][v].suggestModel)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom, 2.0)
        .padding(.top, Design.shared.keyViewVerticalSpacing)

    }
}

