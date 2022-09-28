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
    @Published private(set) var displayLeftIndex = 0
    @Published private(set) var displayRightIndex = 12
    fileprivate var centerIndex: Int {
        return displayLeftIndex + itemCount / 2
    }

    fileprivate var itemCount: Int {
        // 偶数にする
        return (Int(self.viewWidth / self.itemWidth) >> 1) << 1
    }
    fileprivate var itemWidth: CGFloat {
        return Design.fonts.resultViewFontSize * 1.3
    }
    fileprivate var viewWidth: CGFloat {
        return VariableStates.shared.interfaceSize.width * 0.85
    }
    @Published fileprivate var line: [String] = []

    func updateLine(leftText: String, rightText: String) {
        debug("updateLine", viewWidth, itemWidth, itemCount, line)
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

    fileprivate func move(_ count: Int) {
        displayLeftIndex += count
        displayRightIndex += count
        VariableStates.shared.action.registerAction(.moveCursor(count))
    }

    fileprivate func originalPosition(index: Int) -> CGFloat {
        return CGFloat(index) * self.itemWidth
    }

    fileprivate func tap(at index: Int) {
        let diff: Int
        if index < 0 {
            diff = -1
            return
        } else if line.count <= index {
            diff = 1
        } else {
            diff = index - centerIndex
        }
        move(diff)
    }

    func clear() {
        self.displayLeftIndex = 0
        self.displayRightIndex = 0
        self.line = []
    }
}

struct MoveCursorBar: View {
    @ObservedObject private var state = VariableStates.shared.moveCursorBarState
    @Environment(\.themeEnvironment) private var theme

    enum SwipeGestureState {
        case unactive
        case tap(l1: CGPoint, l2: CGPoint, l3: CGPoint)
        case moving(l1: CGPoint, l2: CGPoint, l3: CGPoint, count: Double)
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
                    if direction > 0 && value.location.x < l3.x {
                        count += (Double(direction) / 3) * (l3.x - value.location.x) / 3
                    } else if direction < 0 && value.location.x > l3.x {
                        count -= (Double(direction) / 3) * (l3.x - value.location.x) / 3
                    }
                    withAnimation(.linear(duration: 0.1)) {
                        if count >= 15 {
                            state.move(1)
                            count -= 15
                        }
                        if count <= -15 {
                            state.move(-1)
                            count += 15
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
                    break
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

    private var background: some View {
        RadialGradient(gradient: Gradient(colors: [centerColor, edgeColor]), center: .center, startRadius: 1, endRadius: state.viewWidth / 2)
            .frame(height: Design.resultViewHeight())
            .cornerRadius(20)
            .gesture(swipeGesture)
    }

    private func symbolFont(size: CGFloat) -> Font {
        return .system(size: size, weight: symbolsFontWeight, design: .default)
    }

    private var textView: some View {
        HStack(spacing: .zero) {
            ForEach(state.displayLeftIndex ..< state.displayRightIndex, id: \.self) { i in
                Text(verbatim: state.getItem(at: i))
                    .font(.system(size: Design.fonts.resultViewFontSize).bold())
                    .frame(width: state.itemWidth, height: Design.resultViewHeight())
            }
        }
        .allowsHitTesting(false)
        .foregroundColor(theme.resultTextColor.color.opacity(0.4))
        .drawingGroup()
    }

    private var foregroundButtons: some View {
        ZStack(alignment: .center) {
            textView
            HStack(spacing: .zero) {
                Button {
                    withAnimation(.linear(duration: 0.15)) {
                        state.move(-1)
                    }
                } label: {
                    Image(systemName: "chevron.left.2")
                        .font(symbolFont(size: 18))
                        .foregroundColor(symbolsColor)
                        .padding()
                }
                Spacer()
                Text(verbatim: "│")
                    .font(.system(size: Design.fonts.resultViewFontSize + 4))
                    .foregroundColor(symbolsColor)
                Spacer()
                Button {
                    withAnimation(.linear(duration: 0.15)) {
                        state.move(1)
                    }
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
