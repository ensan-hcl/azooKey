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

enum DragGestureState{
    case inactive
    case started
    case ringAppeared

}

/*
 struct DoubleSwipeGesture: Gesture {
 typealias Value = <#type#>

 typealias Body = <#type#>
 }
 */

struct FocusViewModifier: ViewModifier {
    let color: Color
    let focused: Bool

    func body(content: Content) -> some View {
        let shadowColor = focused ? color:.clear
        let shadowRadius: CGFloat = focused ? 0.5:.zero
        return content
            .shadow(color: shadowColor, radius: shadowRadius, x: 1)
            .shadow(color: shadowColor, radius: shadowRadius, x: -1)
            .shadow(color: shadowColor, radius: shadowRadius, y: 1)
            .shadow(color: shadowColor, radius: shadowRadius, y: -1)
    }
}

extension View {
    func focus(_ color: Color, focused: Bool) -> some View {
        self.modifier(FocusViewModifier(color: color, focused: focused))
    }
}
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

class SelectState: ObservableObject{
    @Published var between = false
    @Published var targetIndex = -1
    @Published var selectedIndex = -1

    func reset(){
        self.selectedIndex = -1
        self.targetIndex = -1
        self.between = false
    }

    func isFocused(_ index: Int) -> Bool {
        return !between && targetIndex == index && selectedIndex != index
    }
}

struct TestView: View {
    @State private var keys = ["、","。","！","？","・"]
    @ObservedObject private var selectState = SelectState()

    let width: CGFloat = 32
    let padding: CGFloat = 5

    var separator: some View {
        Rectangle()
            .frame(width: 2)
            .foregroundColor(.accentColor)
    }

    var body: some View {
        HStack(spacing: 0){
            ForEach(keys.indices){i in
                if selectState.between && selectState.targetIndex == i{
                    separator
                        .focus(.accentColor, focused: true)
                }
                DraggableItem(selectState: selectState, index: i, label: keys[i], update: update, onEnd: onEnd)
                    .frame(width: width, height: 50)
                    .padding(padding)
                    .zIndex(selectState.selectedIndex == i ? 1:0)
            }
            if selectState.between && selectState.targetIndex == keys.endIndex{
                separator
                    .focus(.accentColor, focused: true)
            }

        }.scaledToFit()
    }

    func pointedIndex(index: Int, delta: CGFloat) -> (index: Int, between: Bool) {
        print(index, delta)
        if delta.isZero{
            return (index, false)
        }
        if delta < 0{
            //負の場合
            var position = CGFloat.zero
            var index = index
            while index >= 0{
                position -= (width/2 - padding/2)
                if position < delta{
                    return (index, false)
                }

                position -= 3*padding
                if position < delta{
                    return (index, true)
                }

                index -= 1
            }
            return (0, true)
        }else{
            //正の場合
            var position = CGFloat.zero
            var index = index
            while index < keys.endIndex{
                position += (width/2 - padding/2)
                if delta < position{
                    return (index, false)
                }

                index += 1

                position += 3*padding
                if delta < position{
                    return (index, true)
                }
            }
            return (keys.endIndex, true)
        }

    }

    func update(index: Int, delta: CGFloat){
        let (targetIndex, between) = self.pointedIndex(index: index, delta: delta)
        self.selectState.between = between
        self.selectState.targetIndex = targetIndex
    }

    func onEnd(){
        let selectedIndex = selectState.selectedIndex
        let targetIndex = selectState.targetIndex
        let between = selectState.between

        if between{
            if selectedIndex > targetIndex{
                let item = self.keys.remove(at: selectedIndex)
                self.keys.insert(item, at: targetIndex)
            }else if selectedIndex < targetIndex{
                self.keys.insert(self.keys[selectedIndex], at: targetIndex)
                self.keys.remove(at: selectedIndex)
            }
        }else{

        }
        self.selectState.reset()

    }
}

struct DraggableItem: View {
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }

    @GestureState var dragState = DragState.inactive
    @State var viewState: CGSize = .zero
    @ObservedObject private var selectState: SelectState
    @State private var animationEnabled = false

    let index: Int
    let label: String

    let onEnd: () -> ()
    let update: (Int, CGFloat) -> ()

    init(selectState: SelectState, index: Int, label: String, update: @escaping (Int, CGFloat) -> (), onEnd: @escaping () -> ()){
        self.selectState = selectState
        self.index = index
        self.label = label
        self.update = update
        self.onEnd = onEnd
    }


    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(selectState.isFocused(index) ? Color.accentColor:Color.primary)
            .background(RoundedRectangle(cornerRadius: 10).fill(selectState.isFocused(index) ? Color.systemGray4 : Color.systemGray6))
            .focus(.accentColor, focused: selectState.isFocused(index))
            .overlay(Text(label))
            .offset(
                x: viewState.width + dragState.translation.width,
                y: viewState.height + dragState.translation.height
            )
            .contextMenu{
                Button{
                    print("並び替え")
                    self.selectState.selectedIndex = index
                    animationEnabled = true
                    Store.shared.feedbackGenerator.notificationOccurred(.success)
                } label: {
                    Text("並び替え")
                    Image(systemName: "arrow.left.arrow.right")
                }

                Button{
                    print("削除")
                } label: {
                    Text("削除").foregroundColor(.red)
                    Image(systemName: "trash").foregroundColor(.red)
                }

            }
            .gesture(
                DragGesture()
                    .updating($dragState){value, state, transaction in
                        if self.selectState.selectedIndex == index{
                            update(index, value.translation.width)
                            state = .dragging(translation: value.translation)
                        }
                    }
                    .onEnded {_ in
                        print("終了")
                        animationEnabled = false
                        self.onEnd()
                    }
        )
/*
            .gesture(
                LongPressGesture(minimumDuration: 0.5).onEnded{_ in Store.shared.feedbackGenerator.notificationOccurred(.success)}
                    .sequenced(before: DragGesture())
                    .updating($dragState) { value, state, transaction in
                        switch value {
                        case .first(true):  // Long press begins.
                            state = .pressing
                            self.selectState.selectedIndex = index
                        case .second(true, let drag):    // Long press confirmed, dragging may begin.
                            update(index, drag?.translation.width ?? .zero)
                            state = .dragging(translation: drag?.translation ?? .zero)
                        default:    // Dragging ended or the long press cancelled.
                            print("いつ呼ばれるの？default")
                            state = .inactive
                        }
                    }
                    .onEnded { value in
                        guard case .second(true, let drag?) = value else { return }
                        print("終了")
                        self.onEnd()
                    }
            )
 */

    }
}


struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .clipShape(Circle())
    }
}

/*
 struct KeyButton: View {
 @State private var pressed = false

 var longTapGesture: some Gesture {
 LongPressGesture(minimumDuration: 0.5, maximumDistance: 20)
 .onChanged{value in
 self.pressed = value
 }
 .onEnded{value in
 self.pressed = value
 UINotificationFeedbackGenerator().notificationOccurred(.success)
 }
 }

 var body: some View {
 RoundedRectangle(cornerRadius: 5)
 .stroke(Color.primary, lineWidth: 3)
 .frame(width: 30, height: 40)
 .background(self.pressed ? Color.yellow : Color.clear)
 .gesture(longTapGesture)
 }
 }

 struct TestView: View {
 @State private var selection: Int = -1

 var body: some View {
 HStack{
 Spacer()
 ForEach(0..<6){_ in
 KeyButton()
 }
 Spacer()
 Circle()
 .foregroundColor(.blue)
 .frame(width: 40, height: 40)
 .overlay(Image(systemName: "plus").foregroundColor(.white))
 }
 }
 }
 */
/*
 struct TestView: View {
 @State private var input = ""
 var body: some View {
 VStack{
 TextField("番号を入力", text: $input).keyboardType(.numberPad)
 Button{
 if let value = Int(input){
 AudioServicesPlaySystemSound(SystemSoundID(value))
 }
 }label: {
 Label("聴く！", systemImage: "speaker.wave.2")
 }
 }
 }
 }
 */
/*
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
