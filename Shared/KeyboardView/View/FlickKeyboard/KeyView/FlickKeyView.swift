//
//  KeyView.swift
//  azooKey
//
//  Created by ensan on 2020/04/08.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

enum KeyPressState {
    case inactive
    case started(Date)
    case oneDirectionSuggested(FlickDirection, Date)
    case longPressed
    case longFlicked(FlickDirection)

    fileprivate func isActive() -> Bool {
        if case .inactive = self {
            return false
        }
        return true
    }
}

struct FlickKeyView: View {
    private let model: FlickKeyModelProtocol

    @State private var suggestState: SuggestState = .nothing
    @State private var pressState: KeyPressState = .inactive
    // TODO: 消せるはず
    @State private var startLocation: CGPoint?

    @ObservedObject private var variableStates = VariableStates.shared

    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action
    private let size: CGSize

    init(model: FlickKeyModelProtocol, size: CGSize) {
        self.model = model
        self.size = size
    }

    private var suggestAnimation: Animation {
        Animation.easeIn(duration: 0.1).delay(0.5)
    }

    // これはどちらかというとViewに属すると判断した
    private var gesture: some Gesture {
        DragGesture(minimumDistance: .zero, coordinateSpace: .global)
            .onChanged {(value: DragGesture.Value) in
                let startLocation = self.startLocation ?? value.startLocation
                let d = startLocation.direction(to: value.location)
                switch pressState {
                // 押していない状態の場合
                case .inactive:
                    // 押し始めの時間を記録する。
                    pressState = .started(Date())
                    self.startLocation = value.startLocation
                    self.model.feedback()
                    withAnimation(suggestAnimation) {
                        // サジェストが必要な設定なら
                        if self.model.needSuggestView && self.model.longPressActions == .none {
                            // 全てのサジェストを表示する
                            suggestState = .all
                            // 変化を通告する。
                            self.model.suggestStateChanged(.all)
                        }
                        // 長押しの予約をする。
                        self.action.reserveLongPressAction(self.model.longPressActions)
                    }
                // 押し始めた後の変化である場合。
                case let .started(date):
                    // 押したところから25px以上離れてて、サジェストが必要な設定だったら
                    if self.model.isFlickAble(to: d) && startLocation.distance(to: value.location) > self.model.flickSensitivity(to: d) {
                        // サジェストの状態を一度非表示にする。
                        suggestState = .nothing
                        // 通告する。
                        self.model.suggestStateChanged(.nothing)
                        // 一つの方向でサジェストされた状態を登録する。
                        pressState = .oneDirectionSuggested(d, Date())
                        // 長押しされなかったと判断して終了する。
                        self.action.registerLongPressActionEnd(self.model.longPressActions)
                        // 長フリックを予約する
                        self.longFlickReserve(d)
                    }
                    // もしstartedのまま0.4秒以上押していたら
                    if Date().timeIntervalSince(date) >= 0.4 {
                        // 長押し状態に設定する。
                        pressState = .longPressed
                    }
                // 一方向にサジェストが表示(予定)されている状態だったら
                case let .oneDirectionSuggested(direction, startTime):
                    // もし同じ方向で0.4秒以上フリックされていたら長フリックと判定する。
                    if Date().timeIntervalSince(startTime) >= 0.4 {
                        // 長いフリックを登録する。
                        pressState = .longFlicked(direction)
                        return
                    }
                    // もし距離が閾値以上離れていて
                    if startLocation.distance(to: value.location) > self.model.flickSensitivity(to: direction) {
                        // 状態がoneDirectionでなかったら
                        if case .oneDirection = suggestState {} else {
                            // サジェストの方向を登録する。
                            suggestState = .oneDirection(d)
                            // サジェストを通告する。
                            self.model.suggestStateChanged(.oneDirection(d))
                        }
                        // 指す方向が変わっていた場合
                        if  d != direction && self.model.isFlickAble(to: d) {
                            // 長フリックの予約は停止する。
                            self.longFlickEnd(direction)
                            // 新しい方向の長フリックを予約する。
                            self.longFlickReserve(d)
                            // 新しい方向へのサジェストを登録する。
                            suggestState = .oneDirection(d)
                            // 通告する
                            self.model.suggestStateChanged(.oneDirection(d))
                            // 方向を変更する。
                            pressState = .oneDirectionSuggested(d, Date())
                        }
                    }
                case .longPressed:
                    // もし距離が25px以上離れていて、サジェストが必要な設定だったら
                    if self.model.isFlickAble(to: d) && startLocation.distance(to: value.location) > self.model.flickSensitivity(to: d) && self.model.needSuggestView {
                        // 状態がoneDirectionでなかったら
                        if case .oneDirection = suggestState {} else {
                            // サジェストの方向を登録する。
                            suggestState = .oneDirection(d)
                            // サジェストを通告する。
                            self.model.suggestStateChanged(.oneDirection(d))
                            // 一つの方向でサジェストされた状態を登録する。
                            pressState = .oneDirectionSuggested(d, Date())
                            // 長押しは終わりと判断して終了する。
                            self.action.registerLongPressActionEnd(self.model.longPressActions)
                            // 長フリックを予約する
                            self.longFlickReserve(d)
                        }
                    }
                case let .longFlicked(direction):
                    // 指す方向が変わっていた場合
                    if  d != direction && self.model.isFlickAble(to: d) {
                        // 実行中の長フリックを停止する。
                        self.longFlickEnd(direction)
                        // 新しい方向の長フリックを予約する。
                        self.longFlickReserve(d)
                        // 新しい方向へのサジェストを登録する。
                        suggestState = .oneDirection(d)
                        // 通告する
                        self.model.suggestStateChanged(.oneDirection(d))
                        // 方向を変更する。
                        pressState = .oneDirectionSuggested(d, Date())
                    }
                }
            }
            // タップの終了時
            .onEnded {_ in
                // サジェストを解除する
                suggestState = .nothing
                // 通告する。
                self.model.suggestStateChanged(.nothing)

                // 押しはじめて、そのあと動きがなかった場合ここに来る。
                if case let .started(date) = pressState {
                    // もし0.4秒以上経っていたら
                    if Date().timeIntervalSince(date) >= 0.4 {
                        // 長押しと判定しておく。
                        pressState = .longPressed
                    }
                }

                // 一方向をサジェストして
                if case let .oneDirectionSuggested(direction, date) = pressState {
                    // 0.4秒以上経っていたら
                    if Date().timeIntervalSince(date) >= 0.4 {
                        // 長フリックと判定しておく
                        pressState = .longFlicked(direction)
                    }
                }
                // 有無を言わさず終わらせる
                self.action.registerLongPressActionEnd(self.model.longPressActions)
                self.model.flickKeys.forEach {_, flickKey in
                    self.action.registerLongPressActionEnd(flickKey.longPressActions)
                }
                // 状態に基づいて、必要な変更を加える
                switch pressState {
                case .inactive:
                    break
                case .started:
                    self.action.registerActions(self.model.pressActions)
                case let .oneDirectionSuggested(direction, _):
                    if let flickKey = self.model.flickKeys[direction] {
                        self.action.registerActions(flickKey.pressActions)
                    }
                case .longPressed:
                    break
                case let .longFlicked(direction):
                    if let flickKey = self.model.flickKeys[direction], flickKey.longPressActions == .none {
                        self.action.registerActions(flickKey.pressActions)
                    }
                }
                pressState = .inactive
            }
    }

    private var keyFillColor: Color {
        if pressState.isActive() {
            return model.backGroundColorWhenPressed(theme: theme)
        } else {
            return model.backGroundColorWhenUnpressed(states: variableStates, theme: theme)
        }
    }

    private var keyBorderColor: Color {
        theme.borderColor.color
    }

    var body: some View {
        let keySize = (width: size.width, height: size.height)
        RoundedRectangle(cornerRadius: 6)
            .strokeAndFill(fillContent: keyFillColor, strokeContent: keyBorderColor, lineWidth: theme.borderWidth)
            .frame(width: keySize.width, height: keySize.height)
            .gesture(gesture)
            .overlay(model.label(width: keySize.width, states: variableStates))
    }

    func longFlickReserve(_ direction: FlickDirection) {
        if let flickKey = self.model.flickKeys[direction] {
            self.action.reserveLongPressAction(flickKey.longPressActions)
        }
    }

    func longFlickEnd(_ direction: FlickDirection) {
        if let flickKey = self.model.flickKeys[direction] {
            self.action.registerLongPressActionEnd(flickKey.longPressActions)
        }
    }
}
