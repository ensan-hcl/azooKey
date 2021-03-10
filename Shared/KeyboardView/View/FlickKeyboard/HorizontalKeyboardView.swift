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
struct HorizontalFlickKeyboardView: View {
    @State private var alignmnet: KeyboardAlignment = .center

    @ObservedObject private var variableStates = VariableStates.shared
    @Environment(\.themeEnvironment) private var theme
    private let tabDesign = TabDependentDesign(width: 5, height: 4, layout: .flick, orientation: .horizontal)

    private let keyModels: [[FlickKeyModelProtocol]]
    init(keyModels: [[FlickKeyModelProtocol]]){
        self.keyModels = keyModels
    }

    private var horizontalIndices: Range<Int> {
        keyModels.indices
    }

    private func verticalIndices(h: Int) -> Range<Int> {
        keyModels[h].indices
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
            ZStack{
                HStack(spacing: tabDesign.horizontalSpacing){
                    ForEach(self.horizontalIndices, id: \.self){h in
                        VStack(spacing: tabDesign.verticalSpacing){
                            //IDを明示する必要がある。
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
    }
}
