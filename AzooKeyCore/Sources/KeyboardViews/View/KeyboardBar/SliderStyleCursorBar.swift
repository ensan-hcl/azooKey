//
//  SliderStyleCursorBar.swift
//  Keyboard
//
//  Created by ensan on 2020/09/21.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUIUtils
import SwiftUtils

@MainActor
struct SliderStyleCursorBar<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    enum SwipeGestureState {
        case inactive
        case start(l1: CGPoint, l2: CGPoint, l3: CGPoint)
        case moving(l1: CGPoint, l2: CGPoint, l3: CGPoint, count: Double)
    }

    init() {}

    @EnvironmentObject private var variableStates: VariableStates
    @State private var swipeGestureState: SwipeGestureState = .inactive
    @Environment(Extension.Theme.self) private var theme
    @Environment(\.userActionManager) private var action

    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged {value in
                switch swipeGestureState {
                case .inactive:
                    swipeGestureState = .start(l1: value.location, l2: value.location, l3: value.location)
                case let .start(l1, l2, _):
                    let d = value.startLocation.distance(to: value.location)
                    if d > 20 {
                        swipeGestureState = .moving(l1: value.location, l2: l1, l3: l2, count: 0)
                    } else {
                        swipeGestureState = .start(l1: value.location, l2: l1, l3: l2)
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
                    let threshlod: Double = 12
                    if count >= threshlod {
                        action.registerAction(.moveCursor(-1), variableStates: variableStates)
                        count -= threshlod
                    }
                    if count <= -threshlod {
                        action.registerAction(.moveCursor(1), variableStates: variableStates)
                        count += threshlod
                    }
                    swipeGestureState = .moving(l1: value.location, l2: l1, l3: l2, count: count)
                }
            }
            .onEnded {_ in
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

    private var buttonColors: [Color] {
        [symbolsColor.opacity(0.8), symbolsColor.opacity(0.8), symbolsColor.opacity(0.4)]
    }
    private var symbolsFont: Font {
        .system(size: 22, weight: symbolsFontWeight, design: .default)
    }

    @ViewBuilder private var moveLeftButton: some View {
        Button {
            self.action.registerAction(.moveCursor(-1), variableStates: variableStates)
        } label: {
            let interval: Double = 0.4
            TimelineView(.periodic(from: Date(), by: interval)) { timeline in
                let target = Int(timeline.date.timeIntervalSince1970 / interval)
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: "chevron.compact.left")
                            .font(symbolsFont)
                            .foregroundStyle(buttonColors[(target + i) % 3])
                    }
                }
                .compositingGroup()
                .padding()
            }
        }
    }

    @ViewBuilder private var moveRightButton: some View {
        Button {
            self.action.registerAction(.moveCursor(1), variableStates: variableStates)
        } label: {
            let interval: Double = 0.4
            TimelineView(.periodic(from: Date(), by: interval)) { timeline in
                let target = Int(timeline.date.timeIntervalSince1970 / interval)
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: "chevron.compact.right")
                            .font(symbolsFont)
                            .foregroundStyle(buttonColors[(target + 2 - i) % 3])
                    }
                }
                .compositingGroup()
                .padding()
            }
        }
    }

    var body: some View {
        RadialGradient(gradient: Gradient(colors: [centerColor, edgeColor]), center: .center, startRadius: 1, endRadius: 200)
            .cornerRadius(20)
            .gesture(swipeGesture)
            .overlay(
                HStack {
                    Spacer()
                    moveLeftButton
                    Spacer()
                    Image(systemName: "circle.fill")
                        .font(symbolsFont)
                        .foregroundStyle(symbolsColor)
                    Spacer()
                    moveRightButton
                    Spacer()
                }
            )
    }
}
