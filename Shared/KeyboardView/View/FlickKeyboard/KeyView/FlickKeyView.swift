//
//  KeyView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/08.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum KeyPressState{
    case inactive
    case started(Date)
    case oneDirectionSuggested(FlickDirection, Date)
    case longPressed
    case longFlicked(FlickDirection)
    
    fileprivate func isActive() -> Bool {
        if case .inactive = self{
            return false
        }
        return true
    }
}

struct FlickKeyView: View {
    private let model: FlickKeyModelProtocol
    @ObservedObject private var modelVariableSection: KeyModelVariableSection
    @ObservedObject private var variableStates = VariableStates.shared

    private let theme: ThemeData

    init(model: FlickKeyModelProtocol, theme: ThemeData){
        self.model = model
        self.modelVariableSection = model.variableSection
        self.theme = theme
    }

    private var suggestAnimation: Animation {
        Animation.easeIn(duration: 0.1).delay(0.5)
    }

    //これはどちらかというとViewに属すると判断した
    private var gesture: some Gesture {
        DragGesture(minimumDistance: .zero, coordinateSpace: .global)
            .onChanged({[unowned modelVariableSection] (value: DragGesture.Value) in
                let startLocation = modelVariableSection.startLocation ?? value.startLocation
                let d = startLocation.direction(to: value.location)
                switch modelVariableSection.pressState{
                //押していない状態の場合
                case .inactive:
                    //押し始めの時間を記録する。
                    modelVariableSection.pressState = .started(Date())
                    modelVariableSection.startLocation = value.startLocation
                    self.model.sound()
                    withAnimation(suggestAnimation) {
                        //サジェストが必要な設定なら
                        if self.model.needSuggestView && self.model.longPressActions.isEmpty{
                            //全てのサジェストを表示する
                            modelVariableSection.suggestState = .all
                            //変化を通告する。
                            self.model.suggestStateChanged(.all)
                        }
                        //長押しの予約をする。
                        self.model.longPressReserve()
                    }
                //押し始めた後の変化である場合。
                case let .started(date):
                    //押したところから25px以上離れてて、サジェストが必要な設定だったら
                    if self.model.isFlickAble(to: d) && startLocation.distance(to: value.location) > self.model.flickSensitivity(to: d){
                        //サジェストの状態を一度非表示にする。
                        modelVariableSection.suggestState = .nothing
                        //通告する。
                        self.model.suggestStateChanged(.nothing)
                        //一つの方向でサジェストされた状態を登録する。
                        modelVariableSection.pressState = .oneDirectionSuggested(d, Date())
                        //長押しされなかったと判断して終了する。
                        self.model.longPressEnd()
                        //長フリックを予約する
                        self.model.flickKeys[d]?.longFlickReserve()
                    }
                    //もしstartedのまま0.4秒以上押していたら
                    if Date().timeIntervalSince(date) >= 0.4{
                        //長押し状態に設定する。
                        modelVariableSection.pressState = .longPressed
                    }
                //一方向にサジェストが表示(予定)されている状態だったら
                case let .oneDirectionSuggested(direction, startTime):
                    //もし同じ方向で0.4秒以上フリックされていたら長フリックと判定する。
                    if Date().timeIntervalSince(startTime) >= 0.4{
                        //長いフリックを登録する。
                        modelVariableSection.pressState = .longFlicked(direction)
                        return
                    }
                    //もし距離が閾値以上離れていて
                    if startLocation.distance(to: value.location) > self.model.flickSensitivity(to: direction){
                        //状態がoneDirectionでなかったら
                        if case .oneDirection = modelVariableSection.suggestState {}
                        else{
                            //サジェストの方向を登録する。
                            modelVariableSection.suggestState = .oneDirection(d)
                            //サジェストを通告する。
                            self.model.suggestStateChanged(.oneDirection(d))
                        }
                        //指す方向が変わっていた場合
                        if  (d != direction && self.model.isFlickAble(to: d)){
                            //長フリックの予約は停止する。
                            self.model.flickKeys[direction]?.longFlickEnd()
                            //新しい方向の長フリックを予約する。
                            self.model.flickKeys[d]?.longFlickReserve()
                            //新しい方向へのサジェストを登録する。
                            modelVariableSection.suggestState = .oneDirection(d)
                            //通告する
                            self.model.suggestStateChanged(.oneDirection(d))
                            //方向を変更する。
                            modelVariableSection.pressState = .oneDirectionSuggested(d, Date())
                        }
                    }
                case .longPressed:
                    //もし距離が25px以上離れていて、サジェストが必要な設定だったら
                    if startLocation.distance(to: value.location) > self.model.flickSensitivity(to: d) &&  self.model.needSuggestView{
                        //状態がoneDirectionでなかったら
                        if case .oneDirection = modelVariableSection.suggestState {}
                        else{
                            modelVariableSection.pressState = .oneDirectionSuggested(d, Date())
                            //サジェストの方向を登録する。
                            modelVariableSection.suggestState = .oneDirection(d)
                            //サジェストを通告する。
                            self.model.suggestStateChanged(.oneDirection(d))
                        }
                    }
                case let .longFlicked(direction):
                    //指す方向が変わっていた場合
                    if  (d != direction && self.model.isFlickAble(to: d)){
                        //実行中の長フリックを停止する。
                        self.model.flickKeys[direction]?.longFlickEnd()
                        //新しい方向の長フリックを予約する。
                        self.model.flickKeys[d]?.longFlickReserve()
                        //新しい方向へのサジェストを登録する。
                        modelVariableSection.suggestState = .oneDirection(d)
                        //通告する
                        self.model.suggestStateChanged(.oneDirection(d))
                        //方向を変更する。
                        modelVariableSection.pressState = .oneDirectionSuggested(d, Date())
                    }
                }
            })
            //タップの終了時
            .onEnded({[unowned modelVariableSection] value in
                //サジェストを解除する
                modelVariableSection.suggestState = .nothing
                //通告する。
                self.model.suggestStateChanged(.nothing)

                //押しはじめて、そのあと動きがなかった場合ここに来る。
                if case let .started(date) = modelVariableSection.pressState{
                    //もし0.4秒以上経っていたら
                    if Date().timeIntervalSince(date) >= 0.4{
                        //長押しと判定しておく。
                        modelVariableSection.pressState = .longPressed
                    }
                }
                
                //一方向をサジェストして
                if case let .oneDirectionSuggested(direction, date) = modelVariableSection.pressState{
                    //0.4秒以上経っていたら
                    if Date().timeIntervalSince(date) >= 0.4{
                        //長フリックと判定しておく
                        modelVariableSection.pressState = .longFlicked(direction)
                    }
                }
                //有無を言わさず終わらせる
                self.model.longPressEnd()
                self.model.flickKeys.forEach{_, flickKey in
                    flickKey.longFlickEnd()
                }
                //状態に基づいて、必要な変更を加える
                switch modelVariableSection.pressState{
                case .inactive:
                    break
                case .started(_):
                    self.model.press() 
                case let .oneDirectionSuggested(direction, _):
                    self.model.flick(to: direction)
                case .longPressed:
                    break
                case let .longFlicked(direction):
                    if let flickKey = self.model.flickKeys[direction], flickKey.longPressActions.isEmpty{
                        self.model.flick(to: direction)
                    }
                }
                modelVariableSection.pressState = .inactive
            })
    }

    private var keyFillColor: Color {
        if self.modelVariableSection.pressState.isActive(){
            return model.backGroundColorWhenPressed(theme: theme)
        }else{
            return model.backGroundColorWhenUnpressed(states: variableStates, theme: theme)
        }
    }

    private var keyBorderColor: Color {
        theme.borderColor.color
    }

    private var keyBorderWidth: CGFloat {
        CGFloat(theme.borderWidth)
    }

    var body: some View {
        let keySize = (width: model.keySizeType.width(design: Design.shared), height: model.keySizeType.height(design: Design.shared))
        return RoundedBorderedRectangle(cornerRadius: 5.0, fillColor: keyFillColor, borderColor: keyBorderColor, borderWidth: keyBorderWidth)
            .frame(width: keySize.width, height: keySize.height)
            .gesture(gesture)
            .overlay(model.label(width: keySize.width, states: variableStates, theme: theme))
    }
}
