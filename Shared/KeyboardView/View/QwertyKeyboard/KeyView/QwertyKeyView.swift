//
//  QwertyKeyView.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct QwertyKeyView: View{
    private let model: QwertyKeyModelProtocol
    @ObservedObject private var modelVariableSection: QwertyKeyModelVariableSection
    @ObservedObject private var variableStates = VariableStates.shared

    @State private var suggest = false

    private let theme: ThemeData
    
    init(_ model: QwertyKeyModelProtocol, theme: ThemeData){
        self.model = model
        self.modelVariableSection = model.variableSection
        self.theme = theme
    }
    
    private var gesture: some Gesture {
        DragGesture(minimumDistance: .zero)
            .onChanged({(value: DragGesture.Value) in
                self.suggest = true
                switch self.modelVariableSection.pressState{
                case .unpressed:
                    self.model.sound()
                    self.modelVariableSection.pressState = .started(Date())
                    self.model.longPressReserve()
                case let .started(date):
                    //もし0.4秒以上押していたら
                    if Date().timeIntervalSince(date) >= 0.4{
                        //長押し状態に設定する。
                        if self.model.variationsModel.variations.isEmpty{
                            self.modelVariableSection.pressState = .longPressed
                        }else{
                            self.modelVariableSection.pressState = .variations
                        }
                    }
                case .longPressed:
                    break
                case .variations:
                    let dx = value.location.x - value.startLocation.x
                    self.model.variationsModel.registerLocation(dx: dx)
                }
            })
            //タップの終了時
            .onEnded({value in
                self.model.longPressEnd()   //何もなければ何も起こらない。
                self.suggest = false
                //状態に基づいて、必要な変更を加える
                switch self.modelVariableSection.pressState{
                case .unpressed:
                    break
                case let .started(date):
                    //もし0.4秒以上押していたら
                    if Date().timeIntervalSince(date) < 0.4{
                        self.model.press()
                    }
                case .longPressed:
                    break
                case .variations:
                    self.model.variationsModel.performSelected()
                }
                self.modelVariableSection.pressState = .unpressed
            })
    }

    var keyFillColor: Color {
        if modelVariableSection.pressState.isActive{
            return self.model.backGroundColorWhenPressed(theme: theme)
        }else{
            return self.model.backGroundColorWhenUnpressed(states: variableStates, theme: theme)
        }
    }

    private var keyBorderColor: Color {
        theme.borderColor.color
    }

    private var keyBorderWidth: CGFloat {
        CGFloat(theme.borderWidth)
    }

    private var suggestColor: Color {
        theme != .default ? .white : Design.colors.suggestKeyColor
    }

    private var suggestTextColor: Color? {
        theme != .default ? .black : nil
    }

    var body: some View{
        ZStack(alignment: .bottom){
            Group{
                RoundedBorderedRectangle(cornerRadius: 6, fillColor: keyFillColor, borderColor: keyBorderColor, borderWidth: keyBorderWidth)
                    .frame(width: self.model.keySize.width, height: self.model.keySize.height)
                    .contentShape(
                        Rectangle()
                            .size(CGSize(width: self.model.keySize.width + Design.shared.horizontalSpacing, height: self.model.keySize.height + Design.shared.verticalSpacing))
                    )
                    .gesture(gesture)
                    .overlay(self.model.label(states: variableStates, color: nil, theme: theme))
            }
            .overlay(Group{
                if self.suggest && self.model.needSuggestView{
                    let height = Design.shared.verticalSpacing + self.model.keySize.height
                    if self.modelVariableSection.pressState.needVariationsView && !self.model.variationsModel.variations.isEmpty{
                        QwertySuggestView.scaleToVariationsSize(
                            keyWidth: self.model.keySize.width,
                            scale_y: 1,
                            variationsCount: self.model.variationsModel.variations.count,
                            color: suggestColor,
                            direction: model.variationsModel.direction
                        )
                        .overlay(
                            QwertyVariationsView(model: self.model.variationsModel, theme: theme)
                                .padding(.bottom, height)
                                .padding(self.model.variationsModel.direction.edge, 15),
                            alignment: self.model.variationsModel.direction.alignment
                        )
                    }else{
                        QwertySuggestView.scaleToFrameSize(
                            keyWidth: self.model.keySize.width,
                            scale_y: 1,
                            color: suggestColor
                        )
                        .overlay(
                            self.model.label(states: variableStates, color: suggestTextColor, theme: theme)
                                .padding(.bottom, height)
                        )
                    }
                }
            }, alignment: .bottom)
        }
    }
}
