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
    private enum MoveCursorBarGestureState {
        case inactive
        case moving(CGPoint, Int)   // 右だったら+1、左だったら-1
    }

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

    var body: some View {
        RadialGradient(gradient: Gradient(colors: [centerColor, edgeColor]), center: .center, startRadius: 1, endRadius: 200)
            .cornerRadius(20)
            .gesture(gesture)
            .overlay(
                HStack {
                    Spacer()
                    Button {
                        self.action.registerAction(.moveCursor(-1), variableStates: variableStates)
                    } label: {
                        Image(systemName: "chevron.left.2").font(.system(size: 18, weight: symbolsFontWeight, design: .default))
                            .padding()
                    }
                    Spacer()
                    Image(systemName: "circle.fill").font(.system(size: 22, weight: symbolsFontWeight, design: .default))
                    Spacer()
                    Button {
                        self.action.registerAction(.moveCursor(1), variableStates: variableStates)
                    } label: {
                        Image(systemName: "chevron.right.2").font(.system(size: 18, weight: symbolsFontWeight, design: .default))
                            .padding()
                    }
                    Spacer()
                }
                    .foregroundStyle(symbolsColor)
            )
    }
}
