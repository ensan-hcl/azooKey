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
                    Store.shared.action.registerPressAction(.moveCursor(1))
                }
                else if newCount < -1{
                    self.gestureState = .moving(value.location, 0)
                    Store.shared.action.registerPressAction(.moveCursor(-1))
                }
                else{
                    self.gestureState = .moving(value.location, newCount)
                }
            }
        }).onEnded{value in
            self.gestureState = .unactive
        }
    }
    var body: some View {
        Group{
         //   Rectangle()
            RadialGradient(gradient: Gradient(colors: [Store.shared.design.colors.highlightedKeyColor, Store.shared.design.colors.backGroundColor]), center: .center, startRadius: 1, endRadius: 200)
                .frame(height: Store.shared.design.resultViewHeight)
                .foregroundColor(Color(UIColor.systemGray6))
                .cornerRadius(20)
                /*
                .border(
                    RadialGradient(gradient: Gradient(colors: [Color(UIColor.systemGray2), Color(UIColor.systemGray6)]), center: .center, startRadius: 1, endRadius: 180),
                    width: 5
                )
                */
                .gesture(gesture)
                .overlay(HStack{
                    Spacer()

                    Button(action: {
                        Store.shared.action.registerPressAction(.moveCursor(-1))
                    }, label: {
                        Image(systemName: "chevron.left.2").font(.system(size: 18, weight: .light, design: .default))
                            .padding()
                    })
                    Spacer()
                    Image(systemName: "circle.fill").font(.system(size: 22, weight: .light, design: .default))
                    Spacer()
                    Button(action: {
                        Store.shared.action.registerPressAction(.moveCursor(1))
                    }, label: {
                        Image(systemName: "chevron.right.2").font(.system(size: 18, weight: .light, design: .default))
                            .padding()
                    })
                    Spacer()
                }.foregroundColor(.primary))
        }.frame(height: Store.shared.design.resultViewHeight)

    }
}

