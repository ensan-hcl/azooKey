//
//  CursorMoveView.swift
//  Keyboard
//
//  Created by β α on 2020/09/21.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

class MoveCursorBarState: ObservableObject {
    @Published fileprivate var displayLeftIndex = 0
    @Published fileprivate var displayRightIndex = 12
    private var validRange = (left: 0, right: 12)
    fileprivate var centerIndex: Int {
        return displayLeftIndex + itemCount / 2
    }
    @Published fileprivate var delta: CGFloat = 0

    fileprivate var itemCount: Int {
        // 偶数にする
        return (Int(self.viewWidth / self.itemWidth) >> 1) << 1
    }
    fileprivate var itemWidth: CGFloat {
        return Design.fonts.resultViewFontSize * 1.3
    }
    @Published fileprivate var viewWidth: CGFloat = 3000
    @Published fileprivate var line: [String] = []

    func updateLine(leftText: String, rightText: String) {
        let half = itemCount / 2
        let left: [String]
        if leftText.count > half {
            validRange.left = 0
            left = leftText.map {String($0)}
        } else {
            validRange.left = half-leftText.count
            left = Array(repeating: "", count: half - leftText.count) + leftText.map {String($0)}
        }
        let right: [String]
        if rightText.count > half {
            right = rightText.map {String($0)} + ["⏎"]
        } else {
            right = rightText.map {String($0)} + ["⏎"] + Array(repeating: "", count: half - rightText.count)
        }
        validRange.right = left.count + rightText.count + 2

        self.line = left + right

        self.displayLeftIndex = left.count - half
        self.displayRightIndex = self.displayLeftIndex + itemCount
        self.adjustDeltaForRange()
    }

    fileprivate func getItem(at index: Int) -> String {
        if index < 0 || line.count <= index {
            return ""
        }
        return line[index]
    }

    fileprivate func originalPosition(index: Int) -> CGFloat {
        return CGFloat(index) * self.itemWidth - self.itemWidth / 2
    }

    fileprivate func adjustDeltaForRange() {
        self.delta = -itemWidth * CGFloat(self.centerIndex - 1)
    }

    fileprivate func tap(at index: Int) {
        if index < validRange.left {
            VariableStates.shared.action.registerAction(.moveCursor(-1))
            return
        } else if validRange.right <= index {
            VariableStates.shared.action.registerAction(.moveCursor(1))
            return
        }
        let diff = index - centerIndex
        displayLeftIndex += diff
        displayRightIndex += diff
        adjustDeltaForRange()
        VariableStates.shared.action.registerAction(.moveCursor(diff))
    }

    func clear() {
        self.displayLeftIndex = 0
        self.displayRightIndex = 0
        self.delta = 0
        self.viewWidth = 3000
        self.line = []
    }
}

struct MoveCursorBar: View {
    @ObservedObject private var state = VariableStates.shared.moveCursorBarState
    @Environment(\.themeEnvironment) private var theme

    enum SwipeGestureState {
        case unactive
        case tap(l1: CGPoint, l2: CGPoint, l3: CGPoint)
        case moving(l1: CGPoint, l2: CGPoint, l3: CGPoint, count: Int)
    }
    @State private var swipeGestureState: SwipeGestureState = .unactive

    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged {value in
                switch swipeGestureState {
                case .unactive:
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
                    if direction > 0 {
                        count += 1
                    } else if direction < 0 {
                        count -= 1
                    }
                    withAnimation(.linear(duration: 0.1)) {
                        if count > 2 {
                            state.displayLeftIndex += 1
                            state.displayRightIndex += 1
                            state.adjustDeltaForRange()
                            VariableStates.shared.action.registerAction(.moveCursor(1))
                            count = 0
                        }
                        if count < -2 {
                            state.displayLeftIndex -= 1
                            state.displayRightIndex -= 1
                            state.adjustDeltaForRange()
                            VariableStates.shared.action.registerAction(.moveCursor(-1))
                            count = 0
                        }
                        swipeGestureState = .moving(l1: value.location, l2: l1, l3: l2, count: count)
                    }
                }
            }
            .onEnded {value in
                switch swipeGestureState {
                case .unactive:
                    break
                case .tap:
                    // offsetを計算する
                    // タップした位置を理解する
                    // 左端がx=0の座標系で考える。
                    let center_x = VariableStates.shared.interfacePosition.x + SemiStaticStates.shared.screenWidth / 2
                    let x = value.startLocation.x
                    debug(center_x, x, VariableStates.shared.interfacePosition, VariableStates.shared.interfaceSize)
                    // あpい|う え
                    // pの位置をタップした場合、このdiffは-1*itemWidthに近い値になる
                    let diff_from_center = x - center_x
                    let offset_double = diff_from_center / state.itemWidth
                    // center indexからのoffsetになる
                    let offset = Int(offset_double.rounded(.toNearestOrAwayFromZero))
                    let index = state.centerIndex + offset
                    withAnimation(.easeOut(duration: 0.1)) {
                        state.tap(at: index)
                    }
                case .moving:
                    // 位置を揃える
                    state.adjustDeltaForRange()
                }
                swipeGestureState = .unactive
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

    private var characterFont: Font {
        .system(size: Design.fonts.resultViewFontSize)
    }
    private var background: some View {
        RadialGradient(gradient: Gradient(colors: [centerColor, edgeColor]), center: .center, startRadius: 1, endRadius: state.viewWidth / 2)
            .frame(height: Design.resultViewHeight())
            .cornerRadius(20)
            .gesture(swipeGesture)
    }

    private func symbolFont(size: CGFloat) -> Font {
        return .system(size: size, weight: symbolsFontWeight, design: .default)
    }

    private var foregroundButtons: some View {
        ZStack(alignment: .center) {
            HStack(spacing: .zero) {
                GeometryReader { geometry in
                    ForEach(state.displayLeftIndex ..< state.displayRightIndex, id: \.self) { i in
                        Text(verbatim: state.getItem(at: i))
                            .bold()
                            .font(characterFont)
                            .position(x: state.originalPosition(index: i))
                            .frame(width: state.itemWidth)
                    }
                    .onAppear {
                        state.viewWidth = geometry.size.width * 0.85
                    }
                    .opacity(0.4)
                    .foregroundColor(theme.resultTextColor.color)
                    .frame(height: Design.resultViewHeight())
                    .offset(x: state.delta + geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .drawingGroup()
            HStack(spacing: .zero) {
                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        state.displayLeftIndex -= 1
                        state.displayRightIndex -= 1
                        state.adjustDeltaForRange()
                    }
                    VariableStates.shared.action.registerAction(.moveCursor(-1))
                } label: {
                    Image(systemName: "chevron.left.2")
                        .font(symbolFont(size: 18))
                        .foregroundColor(symbolsColor)
                        .padding()
                }
                Spacer()
                Text(verbatim: "│")
                    .font(characterFont)
                    .foregroundColor(symbolsColor)
                Spacer()
                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        state.displayLeftIndex += 1
                        state.displayRightIndex += 1
                        state.adjustDeltaForRange()
                    }
                    VariableStates.shared.action.registerAction(.moveCursor(1))
                } label: {
                    Image(systemName: "chevron.right.2")
                        .font(symbolFont(size: 18))
                        .foregroundColor(symbolsColor)
                        .padding()
                }
            }
        }
    }

    var body: some View {
        background
            .overlay(foregroundButtons)
            .frame(height: Design.resultViewHeight())
    }
}
