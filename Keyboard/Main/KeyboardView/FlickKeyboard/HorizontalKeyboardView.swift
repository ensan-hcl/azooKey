//
//  KeyboardView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/08.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate enum KeyboardAlignment{
    case right, left, center
}
//V=VM
struct HorizontalKeyboardView: View {
    private let model: HorizontalFlickKeyboardModel
    @ObservedObject private var modelVariableSection: HorizontalKeyboardModelVariableSection
    @State private var alignmnet: KeyboardAlignment = .center
    init(_ model: HorizontalFlickKeyboardModel){
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

    private var leftAlignButtonImage: some View {
        Image(systemName: "chevron.left").font(.system(size: 40, weight: .thin, design: .default)).padding()
    }
    private var rightAlignButtonImage: some View {
        Image(systemName: "chevron.right").font(.system(size: 40, weight: .thin, design: .default)).padding()
    }

    var body: some View {
        HStack{
            switch self.alignmnet{
            case .right:
                Spacer()
                leftAlignButtonImage.onTapGesture {
                    self.alignmnet = .center
                }
                Spacer()
            case .center:
                Spacer()
                leftAlignButtonImage.onTapGesture {
                    self.alignmnet = .left
                }
                Spacer()
            case .left:
                EmptyView()
            }
            VStack(spacing: 0){
                ResultView(model: model.resultModel)
                    .frame(width: Design.shared.keyboardWidth)
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
            switch self.alignmnet{
            case .left:
                Spacer()
                rightAlignButtonImage.onTapGesture {
                    self.alignmnet = .center
                }
                Spacer()
            case .center:
                Spacer()
                rightAlignButtonImage.onTapGesture {
                    self.alignmnet = .right
                }
                Spacer()
            case .right:
                EmptyView()
            }
        }
        .padding(.bottom, 2.0)
        .padding(.top, Design.shared.keyViewVerticalSpacing)
    }
}
