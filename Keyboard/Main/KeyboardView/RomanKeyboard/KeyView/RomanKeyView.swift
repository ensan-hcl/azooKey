//
//  RomanKeyView.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct RomanKeyView: View{
    private let model: RomanKeyModelProtocol
    @ObservedObject private var modelVariableSection: RomanKeyModelVariableSection

    @State var suggest = false
    
    init(_ model: RomanKeyModelProtocol){
        self.model = model
        self.modelVariableSection = model.variableSection
    }
    
    var gesture: some Gesture {
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
                self.suggest = false
                //状態に基づいて、必要な変更を加える
                switch self.modelVariableSection.pressState{
                case .unpressed:
                    break
                case let .started(date):
                    //もし0.4秒以上押していたら
                    if Date().timeIntervalSince(date) >= 0.4{
                        self.model.longPressEnd()
                    }else{
                        self.model.press()
                        self.model.longPressEnd()
                    }
                case .longPressed:
                    self.model.longPressEnd()
                case .variations:
                    self.model.longPressEnd()
                    self.model.variationsModel.performSelected()
                }
                self.modelVariableSection.pressState = .unpressed
            })
    }
    
    var body: some View{
        ZStack(alignment: .bottom){
            Group{
                Rectangle()
                    .frame(width: self.model.keySize.width, height: self.model.keySize.height)
                    .foregroundColor(self.modelVariableSection.pressState.isActive ? self.model.backGroundColorWhenPressed:self.model.backGroundColorWhenUnpressed)
                    .cornerRadius(6)
                    .gesture(self.gesture)
                    .overlay(self.model.getLabel())
            }
            .overlay(Group{
                if self.suggest && self.model.needSuggestView{
                    let height = Store.shared.design.keyViewVerticalSpacing + self.model.keySize.height
                    if self.modelVariableSection.pressState.needVariationsView && !self.model.variationsModel.variations.isEmpty{
                        RomanSuggestView.scaleToVariationsSize(
                            keyWidth: self.model.keySize.width,
                            scale_y: 1,
                            variationsCount: self.model.variationsModel.variations.count,
                            color: Store.shared.design.colors.highlightedKeyColor,
                            direction: model.variationsModel.direction
                        )
                        .overlay(
                            RomanVariationsView(model: self.model.variationsModel)
                                .padding(.bottom, height)
                                .padding(self.model.variationsModel.direction.edge, 15),
                            alignment: self.model.variationsModel.direction.alignment
                        )
                    }else{
                        RomanSuggestView.scaleToFrameSize(
                            keyWidth: self.model.keySize.width,
                            scale_y: 1,
                            color: Store.shared.design.colors.highlightedKeyColor
                        )
                        .overlay(
                            self.model.getLabel()
                                .padding(.bottom, height)
                        )
                    }
                }
            }, alignment: .bottom)
        }
    }
}
