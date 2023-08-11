//
//  QwertyKeyView.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUIUtils

enum QwertyKeyPressState {
    case unpressed
    case started(Date)
    case longPressed
    case variations(selection: Int?)

    var isActive: Bool {
        switch self {
        case .unpressed:
            return false
        default:
            return true
        }
    }

    var needVariationsView: Bool {
        switch self {
        case .variations:
            return true
        default:
            return false
        }
    }

}

struct QwertyKeyDoublePressState {
    enum State {
        case inactive
        case firstPressStarted
        case firstPressCompleted
        case secondPressStarted
        case secondPressCompleted
    }
    
    private var state: State = .inactive
    private(set) var updateDate: Date = Date()
    
    var secondPressCompleted: Bool {
        self.state == .secondPressCompleted
    }
    mutating func update(touchDownDate: Date) {
        switch self.state {
        case .inactive, .firstPressStarted, .secondPressStarted:
            self.state = .firstPressStarted
        case .firstPressCompleted:
            // secondPressの開始までは最大0.1秒
            if touchDownDate.timeIntervalSince(updateDate) > 0.1 {
                self.state = .firstPressStarted
            } else {
                self.state = .secondPressStarted
            }
        case .secondPressCompleted:
            self.state = .firstPressStarted
        }
        self.updateDate = touchDownDate
    }
    mutating func update(touchUpDate: Date) {
        switch self.state {
        case  .inactive, .firstPressCompleted, .secondPressCompleted:
            self.state = .inactive
        case .firstPressStarted:
            // firstPressの終了までは最大0.2秒
            if touchUpDate.timeIntervalSince(updateDate) > 0.2 {
                self.state = .inactive
            } else {
                self.state = .firstPressCompleted
            }
        case .secondPressStarted:
            // secondPressは最大0.2秒
            if touchUpDate.timeIntervalSince(updateDate) > 0.2 {
                self.state = .inactive
            } else {
                self.state = .secondPressCompleted
            }
        }
        self.updateDate = touchUpDate
    }
    
    mutating func reset() {
        self.state = .inactive
        self.updateDate = Date()
    }
}

struct QwertyKeyView<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    private let model: any QwertyKeyModelProtocol
    @EnvironmentObject private var variableStates: VariableStates

    @State private var pressState: QwertyKeyPressState = .unpressed
    @State private var doublePressState = QwertyKeyDoublePressState()
    @State private var suggest = false

    @Environment(Extension.Theme.self) private var theme
    @Environment(\.userActionManager) private var action
    private let tabDesign: TabDependentDesign
    private let size: CGSize

    init(model: any QwertyKeyModelProtocol, tabDesign: TabDependentDesign, size: CGSize) {
        self.model = model
        self.tabDesign = tabDesign
        self.size = size
    }

    private var gesture: some Gesture {
        DragGesture(minimumDistance: .zero)
            .onChanged({(value: DragGesture.Value) in
                self.suggest = true
                switch self.pressState {
                case .unpressed:
                    // 押し始め
                    self.model.feedback(variableStates: variableStates)
                    self.pressState = .started(Date())
                    self.doublePressState.update(touchDownDate: Date())
                    self.action.reserveLongPressAction(self.model.longPressActions, variableStates: variableStates)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        // すでに処理が終了済みでなければ
                        if self.pressState.isActive {
                            // 長押し状態に設定する。
                            if self.model.variationsModel.variations.isEmpty {
                                self.pressState = .longPressed
                            } else {
                                self.pressState = .variations(selection: nil)
                            }
                        }
                    }
                case .started:
                    break
                case .longPressed:
                    break
                case .variations:
                    let dx = value.location.x - value.startLocation.x
                    let selection = self.model.variationsModel.getSelection(dx: dx, tabDesign: tabDesign)
                    self.pressState = .variations(selection: selection)
                }
            })
            // タップの終了時
            .onEnded({_ in
                self.action.registerLongPressActionEnd(self.model.longPressActions)
                self.suggest = false
                // 更新する
                self.doublePressState.update(touchUpDate: Date())
                // 状態に基づいて、必要な変更を加える
                switch self.pressState {
                case .unpressed:
                    break
                case let .started(date):
                    // ダブルプレスアクションが存在し、かつダブルプレス判定が成立していたらこちらを優先的に実行
                    let doublePressActions = self.model.doublePressActions(variableStates: variableStates)
                    if !doublePressActions.isEmpty, doublePressState.secondPressCompleted {
                        self.action.registerActions(doublePressActions, variableStates: variableStates)
                        // 実行したので更新する
                        self.doublePressState.reset()
                    } else if Date().timeIntervalSince(date) < 0.4 {
                        // もし0.4秒未満押していたら
                        self.action.registerActions(self.model.pressActions(variableStates: variableStates), variableStates: variableStates)
                    }
                case .longPressed:
                    // longPressの場合はlongPress判定が成立した時点で発火済みなので何もする必要がない
                    break
                case let .variations(selection):
                    self.model.variationsModel.performSelected(selection: selection, actionManager: action, variableStates: variableStates)
                }
                self.pressState = .unpressed
            })
    }

    var keyFillColor: Color {
        if self.pressState.isActive {
            return self.model.backGroundColorWhenPressed(theme: theme)
        } else {
            return self.model.unpressedKeyColorType.color(states: variableStates, theme: theme)
        }
    }

    private var keyBorderColor: Color {
        theme.borderColor.color
    }

    private var keyBorderWidth: CGFloat {
        theme.borderWidth
    }

    private var suggestColor: Color {
        theme != Extension.ThemeExtension.default(layout: .qwerty) ? .white : Design.colors.suggestKeyColor(layout: variableStates.keyboardLayout)
    }

    private var suggestTextColor: Color? {
        theme != Extension.ThemeExtension.default(layout: .qwerty) ? .black : nil
    }

    private var selection: Int? {
        if case let .variations(selection) = pressState {
            return selection
        }
        return nil
    }

    private func label(width: CGFloat, color: Color?) -> some View {
        self.model.label(width: width, states: variableStates, color: color) as KeyLabel<Extension>
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                RoundedRectangle(cornerRadius: 6)
                    .strokeAndFill(fillContent: keyFillColor, strokeContent: keyBorderColor, lineWidth: keyBorderWidth)
                    .frame(width: size.width, height: size.height)
                    .contentShape(
                        Rectangle()
                            .size(CGSize(width: size.width + tabDesign.horizontalSpacing, height: size.height + tabDesign.verticalSpacing))
                    )
                    .gesture(gesture)
                    .overlay(label(width: size.width, color: nil))
            }
            .overlay(Group {
                if self.suggest && self.model.needSuggestView {
                    let height = tabDesign.verticalSpacing + size.height
                    if self.pressState.needVariationsView && !self.model.variationsModel.variations.isEmpty {
                        QwertySuggestView.scaleToVariationsSize(
                            keyWidth: size.width,
                            scale_y: 1,
                            variationsCount: self.model.variationsModel.variations.count,
                            color: suggestColor,
                            borderColor: keyBorderColor,
                            borderWidth: keyBorderWidth,
                            direction: model.variationsModel.direction,
                            tabDesign: tabDesign
                        )
                        .overlay(
                            QwertyVariationsView<Extension>(model: self.model.variationsModel, selection: selection, tabDesign: tabDesign)
                                .padding(.bottom, height),
                            alignment: self.model.variationsModel.direction.alignment
                        )
                        .allowsHitTesting(false)
                    } else {
                        QwertySuggestView.scaleToFrameSize(
                            keyWidth: size.width,
                            scale_y: 1,
                            color: suggestColor,
                            borderColor: keyBorderColor,
                            borderWidth: keyBorderWidth,
                            tabDesign: tabDesign
                        )
                        .overlay(
                            label(width: size.width, color: suggestTextColor)
                                .padding(.bottom, height)
                        )
                        .allowsHitTesting(false)
                    }
                }
            }, alignment: .bottom)
        }
    }
}
