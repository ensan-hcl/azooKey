//
//  QwertyKeyView.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

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

struct QwertyKeyView: View {
    private let model: QwertyKeyModelProtocol
    @ObservedObject private var variableStates = VariableStates.shared

    @State private var pressState: QwertyKeyPressState = .unpressed
    @State private var suggest = false

    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action
    private let tabDesign: TabDependentDesign
    private let size: CGSize

    init(model: QwertyKeyModelProtocol, tabDesign: TabDependentDesign, size: CGSize) {
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
                    self.model.feedback()
                    self.pressState = .started(Date())
                    self.action.reserveLongPressAction(self.model.longPressActions)
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
                // 状態に基づいて、必要な変更を加える
                switch self.pressState {
                case .unpressed:
                    break
                case let .started(date):
                    // もし0.4秒未満押していたら
                    if Date().timeIntervalSince(date) < 0.4 {
                        self.action.registerActions(self.model.pressActions)
                    }
                case .longPressed:
                    break
                case let .variations(selection):
                    self.model.variationsModel.performSelected(selection: selection, actionManager: action)
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
        theme != .default ? .white : Design.colors.suggestKeyColor
    }

    private var suggestTextColor: Color? {
        theme != .default ? .black : nil
    }

    private var selection: Int? {
        if case let .variations(selection) = pressState {
            return selection
        }
        return nil
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
                    .overlay(self.model.label(width: size.width, states: variableStates, color: nil))
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
                            QwertyVariationsView(model: self.model.variationsModel, selection: selection, tabDesign: tabDesign)
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
                            self.model.label(width: size.width, states: variableStates, color: suggestTextColor)
                                .padding(.bottom, height)
                        )
                        .allowsHitTesting(false)
                    }
                }
            }, alignment: .bottom)
        }
    }
}
