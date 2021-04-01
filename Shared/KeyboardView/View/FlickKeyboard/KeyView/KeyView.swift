//
//  KeyView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/08.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum KeyPressState {
    case inactive
    case started(Date)
    case oneDirectionSuggested(FlickDirection, Date)
    case longPressed
    case longFlicked(FlickDirection)

    func isActive() -> Bool {
        if case .inactive = self {
            return false
        }
        return true
    }
}
// V：ビュー
struct FlickKeyView: View {
    private let model: FlickKeyModelProtocol
    @ObservedObject private var modelVariableSection: KeyModelVariableSection

    init(model: FlickKeyModelProtocol) {
        self.model = model
        self.modelVariableSection = model.variableSection
    }

    // これはどちらかというとViewに属すると判断した
    var gesture:some Gesture {
        DragGesture(minimumDistance: .zero)
            .onChanged({(value: DragGesture.Value) in
                switch self.modelVariableSection.pressState {
                // 押していない状態の場合
                case .inactive:

                    // 押し始めの時間を記録する。
                    self.modelVariableSection.pressState = .started(Date())
                    withAnimation(self.model.suggestAnimation) {    // withAnimationが悪いわけではない。
                        // サジェストが必要な設定なら
                        if self.model.needSuggestView {
                            // 全てのサジェストを表示する
                            self.modelVariableSection.suggestState = .all
                            // 変化を通告する。
                            self.model.suggestStateChanged(.all)    /// !!!!!!!!!!!!!!!!!!!!!!!!!!!こいつが悪い
                        }
                        // 長押しの予約をする。
                        self.model.longPressReserve()   // こいつは悪くない
                    }

                // 押し始めた後の変化である場合。
                case let .started(date):
                    // 押したところから25px以上離れてて、サジェストが必要な設定だったら
                    if value.startLocation.distance(to: value.location) > 25 &&  self.model.needSuggestView {
                        // 方向を取得する。
                        let d = value.startLocation.direction(to: value.location)
                        // フリックできるか判定する。
                        if self.model.isFlickAble(to: d) {
                            // サジェストの状態を一度非表示にする。
                            self.modelVariableSection.suggestState = .nothing
                            // 通告する。
                            self.model.suggestStateChanged(.nothing)
                            // 一つの方向でサジェストされた状態を登録する。
                            self.modelVariableSection.pressState = .oneDirectionSuggested(d, Date())
                            // 長押しされなかったと判断して終了する。
                            self.model.longPressEnd()
                            // 長フリックを予約する
                            self.model.flickKeys[d]!.longFlickReserve()
                        }
                    }
                    // もし0.4秒以上押していたら
                    if Date().timeIntervalSince(date) >= 0.4 {
                        // 長押し状態に設定する。
                        self.modelVariableSection.pressState = .longPressed
                    }

                // 一方向にサジェストが表示(予定)されている状態だったら
                case let .oneDirectionSuggested(direction, startTime):
                    // もし同じ方向で0.4秒以上フリックされていたら長フリックと判定する。
                    if Date().timeIntervalSince(startTime) >= 0.4 {
                        // 長いフリックを登録する。
                        self.modelVariableSection.pressState = .longFlicked(direction)
                    }
                    // もし距離が25px以上離れていて、サジェストが必要な設定だったら
                    if value.startLocation.distance(to: value.location) > 25 &&  self.model.needSuggestView {
                        // 方向を取得する
                        let d = value.startLocation.direction(to: value.location)
                        // 状態がoneDirectionでなかったら
                        if case .oneDirection = self.modelVariableSection.suggestState {} else {
                            // アニメーションをつけながら
                            withAnimation(.easeIn(duration:0)) {
                                // サジェストの方向を登録する。
                                self.modelVariableSection.suggestState = .oneDirection(d)
                                // サジェストを通告する。
                                self.model.suggestStateChanged(.oneDirection(d))
                            }
                        }

                        // 指す方向が変わっていた場合
                        if  d != direction && self.model.isFlickAble(to: d) {
                            // 長フリックは停止する。
                            self.model.flickKeys[direction]!.longFlickEnd()
                            // 新しい方向の長フリックを予約する。
                            self.model.flickKeys[d]!.longFlickReserve()
                            // 新しい方向へのサジェストを登録する。
                            self.modelVariableSection.suggestState = .oneDirection(d)
                            // 通告する
                            self.model.suggestStateChanged(.oneDirection(d))
                            // 方向を変更する。
                            self.modelVariableSection.pressState = .oneDirectionSuggested(d, Date())
                        }
                    }

                case .longPressed:
                    // もし距離が25px以上離れていて、サジェストが必要な設定だったら
                    if value.startLocation.distance(to: value.location) > 25 &&  self.model.needSuggestView {
                        // 方向を取得する
                        let d = value.startLocation.direction(to: value.location)
                        // 状態がoneDirectionでなかったら
                        if case .oneDirection = self.modelVariableSection.suggestState {} else {
                            // アニメーションをつけながら
                            withAnimation(.easeIn(duration:0)) {
                                self.modelVariableSection.pressState = .oneDirectionSuggested(d, Date())
                                // サジェストの方向を登録する。
                                self.modelVariableSection.suggestState = .oneDirection(d)
                                // サジェストを通告する。
                                self.model.suggestStateChanged(.oneDirection(d))
                            }
                        }
                    }

                case let .longFlicked(direction):
                    // 現在さしている方向を取得する。
                    let d = value.startLocation.direction(to: value.location)
                    // 指す方向が変わっていた場合
                    if  d != direction && self.model.isFlickAble(to: d) {
                        // 長フリックは停止する。
                        self.model.flickKeys[direction]!.longFlickEnd()
                        // 新しい方向の長フリックを予約する。
                        self.model.flickKeys[d]!.longFlickReserve()
                        // 新しい方向へのサジェストを登録する。
                        self.modelVariableSection.suggestState = .oneDirection(d)
                        // 通告する
                        self.model.suggestStateChanged(.oneDirection(d))
                        // 方向を変更する。
                        self.modelVariableSection.pressState = .oneDirectionSuggested(d, Date())
                    }
                }
            })
            // タップの終了時
            .onEnded({_ in
                withAnimation(.easeOut(duration: 0.2)) {
                    // サジェストを解除する
                    self.modelVariableSection.suggestState = .nothing
                    // 通告する。
                    self.model.suggestStateChanged(.nothing)
                }

                // 押しはじめて、そのあと動きがなかった場合ここに来る。
                if case let .started(date) = self.modelVariableSection.pressState {
                    // もし0.4秒以上経っていたら
                    if Date().timeIntervalSince(date) >= 0.4 {
                        // 長押しと判定しておく。
                        self.modelVariableSection.pressState = .longPressed
                    }
                }

                // 一方向をサジェストして
                if case let .oneDirectionSuggested(direction, date) = self.modelVariableSection.pressState {
                    // 0.4秒以上経っていたら
                    if Date().timeIntervalSince(date) >= 0.4 {
                        // 長フリックと判定しておく
                        self.modelVariableSection.pressState = .longFlicked(direction)
                    }
                }
                self.model.longPressEnd()

                // 状態に基づいて、必要な変更を加える
                switch self.modelVariableSection.pressState {
                case .inactive:
                    break
                case .started:
                    self.model.press()  // 悪者はこいつでは無い
                case let .oneDirectionSuggested(direction, _):
                    if let flickKey = self.model.flickKeys[direction] {
                        self.model.flick(to: direction)
                        flickKey.longFlickEnd()
                    }
                case .longPressed:
                    break
                case let .longFlicked(direction):
                    if let flickKey = self.model.flickKeys[direction] {
                        flickKey.longFlickEnd()
                        if flickKey.longPressActions.isEmpty {
                            self.model.flick(to: direction)
                        }
                    }
                }
                self.modelVariableSection.pressState = .inactive

            })

    }

    var body:some View {
        ZStack {
            Rectangle()
                .frame(width: model.keySize.width, height: model.keySize.height)
                .foregroundColor(self.modelVariableSection.pressState.isActive() ? model.backGroundColorWhenPressed:model.backGroundColorWhenUnpressed) // ここは悪く無い
                .cornerRadius(5.0)
            model.getLabel()
        }.gesture(gesture)
        .frame(width: model.keySize.width, height: model.keySize.height)
    }
}
