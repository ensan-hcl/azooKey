//
//  CursorMoveView.swift
//  Keyboard
//
//  Created by ensan on 2020/09/21.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUIUtils
import SwiftUtils

struct BetaMoveCursorBarState {
    private(set) var displayLeftIndex = 0
    private(set) var displayRightIndex = 0
    fileprivate var line: [String] = []

    private var itemCount: Int = 0
    mutating func updateItemCount(viewWidth: CGFloat, itemWidth: CGFloat) {
        self.itemCount = (Int(viewWidth / itemWidth) >> 1) << 1
    }

    fileprivate var centerIndex: Int {
        displayLeftIndex + itemCount / 2
    }

    mutating func updateLine(leftText: String, rightText: String) {
        debug("updateLine", leftText, rightText, itemCount, line)
        var left = leftText.map {String($0)}
        if left.first == "\n" {
            left.removeFirst()
        }
        self.line = left + rightText.map {String($0)} + ["⏎"]
        self.displayLeftIndex = left.count - itemCount / 2
        self.displayRightIndex = self.displayLeftIndex + itemCount
    }

    fileprivate func getItem(at index: Int) -> String {
        if index < 0 || line.count <= index {
            return ""
        }
        return line[index]
    }

    @MainActor mutating fileprivate func move(_ count: Int, actionManager: some UserActionManager, variableStates: VariableStates) {
        displayLeftIndex += count
        displayRightIndex += count
        actionManager.registerAction(.moveCursor(count), variableStates: variableStates)
    }

    @MainActor mutating fileprivate func tap(at index: Int, actionManager: some UserActionManager, variableStates: VariableStates) {
        let diff: Int
        if index < 0 {
            diff = -1
        } else if line.count <= index {
            diff = 1
        } else {
            diff = index - centerIndex
        }
        move(diff, actionManager: actionManager, variableStates: variableStates)
    }

    mutating func clear() {
        self.displayLeftIndex = 0
        self.displayRightIndex = 0
        self.line = []
    }
}

struct MoveCursorBarBeta<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    init() {}

    @EnvironmentObject private var variableStates: VariableStates
    @Environment(Extension.Theme.self) private var theme
    @Environment(\.userActionManager) private var action

    enum SwipeGestureState {
        case inactive
        case tap(l1: CGPoint, l2: CGPoint, l3: CGPoint)
        case moving(l1: CGPoint, l2: CGPoint, l3: CGPoint, count: Double)
    }
    @State private var swipeGestureState: SwipeGestureState = .inactive

    private var fontSize: CGFloat {
        Design.fonts.resultViewFontSize(userPrefrerence: Extension.SettingProvider.resultViewFontSize)
    }
    fileprivate var itemWidth: CGFloat {
        fontSize * 1.3
    }
    fileprivate var viewWidth: CGFloat {
        variableStates.interfaceSize.width * 0.85
    }

    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged {value in
                switch swipeGestureState {
                case .inactive:
                    swipeGestureState = .tap(l1: value.location, l2: value.location, l3: value.location)
                case let .tap(l1, l2, _):
                    let d = value.startLocation.distance(to: value.location)
                    if d > 20 {
                        swipeGestureState = .moving(l1: value.location, l2: l1, l3: l2, count: 0)
                    } else {
                        swipeGestureState = .tap(l1: value.location, l2: l1, l3: l2)
                    }
                case let .moving(l1, l2, l3, count):
                    var direction = 0
                    var count = count
                    // directionを多数決で決定する
                    if value.location.x - l1.x > 0 {
                        direction -= 1
                    } else {
                        direction += 1
                    }
                    if l1.x - l2.x > 0 {
                        direction -= 1
                    } else {
                        direction += 1
                    }
                    if l2.x - l3.x > 0 {
                        direction -= 1
                    } else {
                        direction += 1
                    }
                    // countの更新
                    if direction > 0 && value.location.x < l3.x {
                        count += (Double(direction) / 3) * (l3.x - value.location.x) / 3
                    } else if direction < 0 && value.location.x > l3.x {
                        count -= (Double(direction) / 3) * (l3.x - value.location.x) / 3
                    }
                    withAnimation(.linear(duration: 0.05)) {
                        if count >= 15 {
                            variableStates.moveCursorBarState.move(1, actionManager: self.action, variableStates: variableStates)
                            count -= 15
                        }
                        if count <= -15 {
                            variableStates.moveCursorBarState.move(-1, actionManager: self.action, variableStates: variableStates)
                            count += 15
                        }
                        swipeGestureState = .moving(l1: value.location, l2: l1, l3: l2, count: count)
                    }
                }
            }
            .onEnded {value in
                switch swipeGestureState {
                case .inactive:
                    break
                case .tap:
                    // offsetを計算する
                    // タップした位置を理解する
                    // 左端がx=0の座標系で考える。
                    let center_x = variableStates.interfacePosition.x + SemiStaticStates.shared.screenWidth / 2
                    let x = value.startLocation.x
                    // あpい|う え
                    // pの位置をタップした場合、このdiffは-1*itemWidthに近い値になる
                    let diff_from_center = x - center_x
                    let offset_double = diff_from_center / itemWidth
                    // center indexからのoffsetになる
                    let offset = Int(offset_double.rounded(.toNearestOrAwayFromZero))
                    let index = variableStates.moveCursorBarState.centerIndex + offset
                    withAnimation(.easeOut(duration: 0.1)) {
                        variableStates.moveCursorBarState.tap(at: index, actionManager: self.action, variableStates: variableStates)
                    }
                case .moving:
                    // 位置を揃える
                    break
                }
                swipeGestureState = .inactive
            }
    }

    private var centerColor: Color {
        theme.pushedKeyFillColor.color
    }

    private var edgeColor: Color {
        theme.backgroundColor.color
    }

    private var symbolsFontWeight: Font.Weight {
        theme.textFont.weight
    }

    private var symbolsColor: Color {
        theme.resultTextColor.color
    }

    private var background: some View {
        RadialGradient(gradient: Gradient(colors: [centerColor, edgeColor]), center: .center, startRadius: 1, endRadius: viewWidth / 2)
            // TODO: ここからframeを消して問題なかったかチェックする
            .cornerRadius(20)
            .gesture(swipeGesture)
    }

    private func symbolFont(size: CGFloat) -> Font {
        .system(size: size, weight: symbolsFontWeight, design: .default)
    }

    private var textView: some View {
        HStack(spacing: .zero) {
            // 多めに描画しておく
            ForEach(variableStates.moveCursorBarState.displayLeftIndex - 4 ..< variableStates.moveCursorBarState.displayRightIndex + 4, id: \.self) { i in
                Text(verbatim: variableStates.moveCursorBarState.getItem(at: i))
                    .font(.system(size: fontSize).bold())
                    .frame(width: itemWidth)
            }
        }
        .allowsHitTesting(false)
        .foregroundColor(theme.resultTextColor.color.opacity(0.4))
        .drawingGroup()
        .frame(width: viewWidth)
        .clipped()
    }

    private var foregroundButtons: some View {
        ZStack(alignment: .center) {
            textView
            HStack(spacing: .zero) {

                Image(systemName: "chevron.left.2")
                    .font(symbolFont(size: 18))
                    .foregroundColor(symbolsColor)
                    .padding()
                    .overlay(
                        TouchDownAndTouchUpGestureView {
                            self.action.reserveLongPressAction(.init(start: [], repeat: [.moveCursor(-1)]), variableStates: variableStates)
                        } touchMovedCallBack: { state in
                            if state.distance > 20 { // 20以上動いたらダメ
                                debug("touch failed")
                            }
                        } touchUpCallBack: { gestureState in
                            self.action.registerLongPressActionEnd(.init(start: [], repeat: [.moveCursor(-1)]))
                            if gestureState.time < 0.4 {
                                withAnimation(.linear(duration: 0.15)) {
                                    variableStates.moveCursorBarState.move(-1, actionManager: self.action, variableStates: variableStates)
                                }
                            }
                        }
                    )
                Spacer()
                Text(verbatim: "│")
                    .font(.system(size: fontSize + 4))
                    .foregroundColor(symbolsColor)
                    .allowsHitTesting(false)
                Spacer()
                Image(systemName: "chevron.right.2")
                    .font(symbolFont(size: 18))
                    .foregroundColor(symbolsColor)
                    .padding()
                    .overlay(
                        TouchDownAndTouchUpGestureView {
                            self.action.reserveLongPressAction(.init(start: [], repeat: [.moveCursor(1)]), variableStates: variableStates)
                        } touchMovedCallBack: { state in
                            if state.distance > 20 { // 20以上動いたらダメ
                                debug("touch failed")
                            }
                        } touchUpCallBack: { gestureState in
                            self.action.registerLongPressActionEnd(.init(start: [], repeat: [.moveCursor(1)]))
                            if gestureState.time < 0.4 {
                                withAnimation(.linear(duration: 0.15)) {
                                    variableStates.moveCursorBarState.move(1, actionManager: self.action, variableStates: variableStates)
                                }
                            }
                        }
                    )
            }
        }
    }

    var body: some View {
        background
            .overlay(foregroundButtons)
            .onAppear {
                variableStates.moveCursorBarState.updateItemCount(viewWidth: viewWidth, itemWidth: itemWidth)
            }
    }
}

private enum MoveCursorBarGestureState {
    case inactive
    case moving(CGPoint, Int)   // 右だったら+1、左だったら-1
}

struct MoveCursorBar<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    init() {}

    @EnvironmentObject private var variableStates: VariableStates
    @State private var gestureState: MoveCursorBarGestureState = .inactive
    @Environment(Extension.Theme.self) private var theme
    @Environment(\.userActionManager) private var action

    private var gesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged {value in
                switch self.gestureState {
                case .inactive:
                    self.gestureState = .moving(value.location, 0)
                case let .moving(previous, count):
                    let dx = (value.location.x - previous.x)
                    if dx.isZero {
                        break
                    }
                    let newCount = count + Int(dx / abs(dx))
                    if newCount > 1 {
                        self.gestureState = .moving(value.location, 0)
                        self.action.registerAction(.moveCursor(1), variableStates: variableStates)
                    } else if newCount < -1 {
                        self.gestureState = .moving(value.location, 0)
                        self.action.registerAction(.moveCursor(-1), variableStates: variableStates)
                    } else {
                        self.gestureState = .moving(value.location, newCount)
                    }
                }
            }
            .onEnded {_ in
                self.gestureState = .inactive
            }
    }

    private var centerColor: Color {
        theme.pushedKeyFillColor.color
    }

    private var edgeColor: Color {
        theme.backgroundColor.color
    }

    private var symbolsFontWeight: Font.Weight {
        theme.textFont.weight
    }

    private var symbolsColor: Color {
        theme.resultTextColor.color
    }

    private var useBeta: Bool {
        Extension.SettingProvider.useBetaMoveCursorBar
    }

    var body: some View {
        if useBeta {
            MoveCursorBarBeta<Extension>()
        } else {
            Group {
                RadialGradient(gradient: Gradient(colors: [centerColor, edgeColor]), center: .center, startRadius: 1, endRadius: 200)
                    .cornerRadius(20)
                    .gesture(gesture)
                    .overlay(HStack {
                        Spacer()
                        Button(action: {
                            self.action.registerAction(.moveCursor(-1), variableStates: variableStates)
                        }, label: {
                            Image(systemName: "chevron.left.2").font(.system(size: 18, weight: symbolsFontWeight, design: .default))
                                .padding()
                        })
                        Spacer()
                        Image(systemName: "circle.fill").font(.system(size: 22, weight: symbolsFontWeight, design: .default))
                        Spacer()
                        Button(action: {
                            self.action.registerAction(.moveCursor(1), variableStates: variableStates)
                        }, label: {
                            Image(systemName: "chevron.right.2").font(.system(size: 18, weight: symbolsFontWeight, design: .default))
                                .padding()
                        })
                        Spacer()
                    }.foregroundColor(symbolsColor))
            }
        }
    }
}
