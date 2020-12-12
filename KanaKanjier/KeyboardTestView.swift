//
//  KeyboardTestView.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
import AudioToolbox
class VariableSection: ObservableObject{
}

extension CGPoint{
    func distance(to point: CGPoint) -> CGFloat {
        let x1: CGFloat = self.x
        let x2: CGFloat = point.x
        let y1: CGFloat = self.y
        let y2: CGFloat = point.y
        let d2: CGFloat = (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
        let d: CGFloat = sqrt(d2)
        return d
    }

    func direction(to point: CGPoint) -> Int {

        let value = atan2((point.x - self.x), (point.y - self.y))
        let result = (-value + .pi)/(2*CGFloat.pi)*5
        return (Int(result) + 4) % 5
    }
}


extension DispatchQueue{
    func cancelableAsyncAfter(deadline: DispatchTime, execute: @escaping () -> Void) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: execute)
        asyncAfter(deadline: deadline, execute: item)
        return item
    }
}


/*
 struct DoubleSwipeGesture: Gesture {
 typealias Value = <#type#>

 typealias Body = <#type#>
 }
 */
/*
 enum SelectState{
 case none
 case item(index: Int, delta: CGFloat)

 var item: (index: Int, delta: CGFloat)? {
 switch self{
 case .none:
 return nil
 case let .item(index, delta):
 return (index, delta)
 }
 }
 }
 */


struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .clipShape(Circle())
    }
}

/*

 enum DragGestureState{
 case inactive
 case started
 case ringAppeared

 }

 struct TestView: View {
 @State var location: CGPoint = .zero
 @State var showRing = false
 @State var gestureState = DragGestureState.inactive
 @State var timer: DispatchWorkItem? = nil
 @State var direction: Int = -1
 @GestureState var isLongPressed = false
 let generator = UINotificationFeedbackGenerator()


 func reserveShowRing(after distance: Double){
 self.timer = DispatchQueue.main.cancelableAsyncAfter(deadline: .now() + distance){[unowned generator] in
 self.showRing = true
 self.gestureState = .ringAppeared
 generator.notificationOccurred(.success)
 }
 }

 func ring(from x: CGFloat, to y: CGFloat, tag: Int) -> some View {
 return Circle()
 .trim(from: (x + 0.05), to: (y - 0.05))
 .stroke(direction == tag ? Color.pink:Color.white, style: StrokeStyle(lineWidth: 30, lineCap: .round))
 .frame(width: 120, height: 120)
 .offset(x: location.x, y: location.y)
 .allowsHitTesting(false)
 }

 var body: some View {
 ZStack{
 Color.yellow
 //.gesture(gesture)
 .gesture(doubleTapGesture)
 Circle()
 .frame(width: 30, height: 30)
 .foregroundColor(.white)
 .offset(x: location.x, y: location.y)
 .scaleEffect(isLongPressed ? 1.1 : 1)
 .allowsHitTesting(false)

 if showRing{
 ring(from: 0.0, to: 0.2, tag: 0)
 ring(from: 0.2, to: 0.4, tag: 1)
 ring(from: 0.4, to: 0.6, tag: 2)
 ring(from: 0.6, to: 0.8, tag: 3)
 ring(from: 0.8, to: 1.0, tag: 4)
 }
 }
 }

 var doubleTapGesture: some Gesture {
 LongPressGesture(minimumDuration: 1)
 .updating($isLongPressed){ value, state, transition in
 state = value
 }.simultaneously(with: DragGesture()
 .onChanged {
 self.location = CGPoint(x: $0.translation.width, y: $0.translation.height)
 }
 .onEnded {_ in
 self.location = .zero
 }
 )
 }
 var gesture: some Gesture {
 DragGesture(minimumDistance: 0, coordinateSpace: .global)
 .onChanged{value in
 switch self.gestureState{
 case .inactive:
 let x = value.location.x - UIScreen.main.bounds.width/2
 let y = value.location.y - UIScreen.main.bounds.height/2
 self.location = CGPoint(x: x, y: y)

 self.gestureState = .started
 withAnimation(Animation.linear.delay(0.2)){
 self.reserveShowRing(after: 0.2)
 }
 case .started:
 let x = value.location.x - UIScreen.main.bounds.width/2
 let y = value.location.y - UIScreen.main.bounds.height/2
 self.location = CGPoint(x: x, y: y)

 let distance = value.location.distance(to: value.startLocation)
 if distance > 30{
 self.gestureState = .inactive
 self.showRing = false
 self.timer?.cancel()
 }
 case .ringAppeared:
 let distance = value.location.distance(to: value.startLocation)
 if distance > 30{
 self.direction = value.startLocation.direction(to: value.location)
 print(self.direction)
 }
 }
 }.onEnded{value in
 self.showRing = false
 self.gestureState = .inactive
 self.timer?.cancel()
 self.direction = -1
 }
 }
 }

 */
