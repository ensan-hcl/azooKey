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

    @Environment(\.themeEnvironment) private var theme
    private let tabDesign: TabDependentDesign
    
    init(model: QwertyKeyModelProtocol, tabDesign: TabDependentDesign){
        self.model = model
        self.modelVariableSection = model.variableSection
        self.tabDesign = tabDesign
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
                    self.model.variationsModel.registerLocation(dx: dx, tabDesign: tabDesign)
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
            return self.model.unpressedKeyColorType.color(states: variableStates, theme: theme)
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

    var body: some View {
        let keySize = CGSize(width: model.keySizeType.width(design: tabDesign), height: model.keySizeType.height(design: tabDesign))
        ZStack(alignment: .bottom){
            Group{
                RoundedBorderedRectangle(cornerRadius: 6, fillColor: keyFillColor, borderColor: keyBorderColor, borderWidth: keyBorderWidth)
                    .frame(width: keySize.width, height: keySize.height)
                    .contentShape(
                        Rectangle()
                            .size(CGSize(width: keySize.width + tabDesign.horizontalSpacing, height: keySize.height + tabDesign.verticalSpacing))
                    )
                    .gesture(gesture)
                    .overlay(self.model.label(width: keySize.width, states: variableStates, color: nil))
            }
            .overlay(Group{
                if self.suggest && self.model.needSuggestView{
                    let height = tabDesign.verticalSpacing + keySize.height
                    if self.modelVariableSection.pressState.needVariationsView && !self.model.variationsModel.variations.isEmpty{
                        QwertySuggestView.scaleToVariationsSize(
                            keyWidth: keySize.width,
                            scale_y: 1,
                            variationsCount: self.model.variationsModel.variations.count,
                            color: suggestColor,
                            direction: model.variationsModel.direction,
                            tabDesign: tabDesign
                        )
                        .overlay(
                            QwertyVariationsView(model: self.model.variationsModel, theme: theme, tabDesign: tabDesign)
                                .padding(.bottom, height)
                                .padding(self.model.variationsModel.direction.edge, 15),
                            alignment: self.model.variationsModel.direction.alignment
                        )
                        .allowsHitTesting(false)
                    }else{
                        QwertySuggestView.scaleToFrameSize(
                            keyWidth: keySize.width,
                            scale_y: 1,
                            color: suggestColor,
                            tabDesign: tabDesign
                        )
                        .overlay(
                            self.model.label(width: keySize.width, states: variableStates, color: suggestTextColor)
                                .padding(.bottom, height)
                        )
                        .allowsHitTesting(false)
                    }
                }
            }, alignment: .bottom)
        }
    }
}
