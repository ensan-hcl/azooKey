//
//  CursorMoveView.swift
//  Keyboard
//
//  Created by β α on 2020/09/21.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

private enum CursorMoveViewGestureState{
    case unactive
    case moving(CGPoint, Int)   //右だったら+1、左だったら-1
}

struct CursorMoveView: View{
    @State private var gestureState: CursorMoveViewGestureState = .unactive
    private var gesture: some Gesture {
        DragGesture(minimumDistance: 0).onChanged({value in
            switch self.gestureState{
            case .unactive:
                self.gestureState = .moving(value.location, 0)
            case let .moving(previous, count):
                let dx = (value.location.x - previous.x)
                if dx.isZero{
                    break
                }
                let newCount = count + Int(dx/abs(dx))
                if newCount > 1{
                    self.gestureState = .moving(value.location, 0)
                    VariableStates.shared.action.registerAction(.moveCursor(1))
                }
                else if newCount < -1{
                    self.gestureState = .moving(value.location, 0)
                    VariableStates.shared.action.registerAction(.moveCursor(-1))
                }
                else{
                    self.gestureState = .moving(value.location, newCount)
                }
            }
        }).onEnded{value in
            self.gestureState = .unactive
        }
    }

    private var centerColor: Color {
        VariableStates.shared.themeManager.theme.pushedKeyFillColor.color
    }

    private var edgeColor: Color {
        VariableStates.shared.themeManager.theme.pushedKeyFillColor.color
    }

    private var symbolsFontWeight: Font.Weight {
        VariableStates.shared.themeManager.weight
    }

    private var symbolsColor: Color {
        VariableStates.shared.themeManager.theme.resultTextColor
    }


    var body: some View {
        Group{
         //   Rectangle()
            RadialGradient(gradient: Gradient(colors: [centerColor, edgeColor]), center: .center, startRadius: 1, endRadius: 200)
                .frame(height: Design.shared.resultViewHeight)
                .cornerRadius(20)
                .gesture(gesture)
                .overlay(HStack{
                    Spacer()

                    Button(action: {
                        VariableStates.shared.action.registerAction(.moveCursor(-1))
                    }, label: {
                        Image(systemName: "chevron.left.2").font(.system(size: 18, weight: symbolsFontWeight, design: .default))
                            .padding()
                    })
                    Spacer()
                    Image(systemName: "circle.fill").font(.system(size: 22, weight: symbolsFontWeight, design: .default))
                    Spacer()
                    Button(action: {
                        VariableStates.shared.action.registerAction(.moveCursor(1))
                    }, label: {
                        Image(systemName: "chevron.right.2").font(.system(size: 18, weight: symbolsFontWeight, design: .default))
                            .padding()
                    })
                    Spacer()
                }.foregroundColor(symbolsColor))
        }.frame(height: Design.shared.resultViewHeight)

    }
}

