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
    @Published var targetIndex = -1
    @Published var selectedIndex = -1
    @Published var longpressTargetIndex = -1
    @Published var longpressSelectedIndex = -1

    func reset(){
        self.selectedIndex = -1
        self.targetIndex = -1
    }
}
class EditState: ObservableObject{
    enum State{
        case none
        case drag
        case label
        case action
    }
    @Published var state = State.none
    var allowDrag: Bool {
        return state == .drag
    }
    var editLabel: Bool {
        return state == .label
    }
    var editAction: Bool {
        return state == .action
    }

    func toggle(_ state: State){
        if self.state == state{
            self.state = .none
        }else{
            self.state = state
        }
    }
}

struct TestView: View {
    @State private var keys = ["、","。","！","？","・"]
    @ObservedObject private var selectState = SelectState()

    @ObservedObject private var editState = EditState()

    let width: CGFloat = 32
    let padding: CGFloat = 5

    @State private var keyData: [RomanCustomKey]

    init(){
        let data = UserDefaults(suiteName: SharedStore.appGroupKey)!.value(forKey: Setting.numberTabCustomKeys.key)
        let romanCustomKeys = RomanCustomKeys.get(data)!
        self._keyData = State(initialValue: romanCustomKeys.keys)
        //print(romanCustomKeys.keys)
    }

    var separator: some View {
        Rectangle()
            .frame(width: 2, height: 40)
            .foregroundColor(.accentColor)
    }

    var body: some View {
        VStack{
            Spacer(minLength: 50)
                .fixedSize()

            HStack(spacing: 0){
                ForEach(keyData.indices, id: \.self){i in
                    if editState.allowDrag && selectState.targetIndex == i{
                        separator
                            .focus(.accentColor, focused: true)
                    }
                    DraggableItem(selectState: selectState, editState: editState, index: i, label: keyData[i].name, update: update, onEnd: onEnd)
                        .frame(width: width, height: 50)
                        .padding(padding)
                        .zIndex(selectState.selectedIndex == i ? 1:0)
                }
                if editState.allowDrag && selectState.targetIndex == keyData.endIndex{
                    separator
                        .focus(.accentColor, focused: true)
                }
            }.scaledToFit()
            if self.selectState.selectedIndex != -1{
                Spacer(minLength: 50)
                    .fixedSize()
                Text("長押しした時の候補")
                let longpresses = keyData[selectState.selectedIndex].longpresses
                HStack(spacing: 0){
                    ForEach(longpresses.indices, id: \.self){i in
                        if editState.allowDrag && selectState.longpressTargetIndex == i{
                            separator
                                .focus(.accentColor, focused: true)
                        }
                        DraggableItem(selectState: selectState, editState: editState, index: i, label: longpresses[i].name, long: true, update: longPressUpdate, onEnd: longPressOnEnd)
                            .frame(width: width, height: 50)
                            .padding(padding)
                            .zIndex(selectState.longpressSelectedIndex == i ? 1:0)
                    }
                    if editState.allowDrag && selectState.longpressTargetIndex == longpresses.endIndex{
                        separator
                            .focus(.accentColor, focused: true)
                    }
                }.scaledToFit()
                if longpresses.isEmpty{
                    Button{
                        keyData[selectState.selectedIndex].longpresses.append(RomanVariationKey(name: "", input: ""))
                    }label: {
                        Text("追加する")
                    }
                }
            }
            Spacer()
            if editState.editLabel{
                VStack{
                    Text("キーに表示される文字を設定します。")
                        .font(.caption)
                    Text("入力される文字とは異なっていても構いません。")
                        .font(.caption)

                    let sIndex = selectState.selectedIndex
                    let lpsIndex = selectState.longpressSelectedIndex
                    if lpsIndex == -1{
                        TextField("ラベル", text: $keyData[sIndex].name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                    }else{
                        TextField("ラベル", text: $keyData[sIndex].longpresses[lpsIndex].name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                    }
                }
                .frame(maxHeight: 80)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.systemGray5))
                .padding()
            }
            if editState.editAction{
                VStack{
                    Text("キーを押して入力される文字を設定します。")
                        .font(.caption)
                    Text("キーの見た目は「ラベル」で設定できます。")
                        .font(.caption)

                    let sIndex = selectState.selectedIndex
                    let lpsIndex = selectState.longpressSelectedIndex
                    if lpsIndex == -1{

                        TextField("入力される文字", text: $keyData[sIndex].input, onCommit: {
                            if keyData[sIndex].name.isEmpty{
                                keyData[sIndex].name = keyData[sIndex].input
                            }
                        })
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                    }else{
                        TextField("入力される文字", text: $keyData[sIndex].longpresses[lpsIndex].input, onCommit: {
                            if keyData[sIndex].longpresses[lpsIndex].name.isEmpty{
                                keyData[sIndex].longpresses[lpsIndex].name = keyData[sIndex].longpresses[lpsIndex].input
                            }
                        })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                    }
                }
                .frame(maxHeight: 80)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.systemGray5))
                .padding()
            }

            if selectState.selectedIndex != -1{
                HStack{
                    Group{
                        ToolBarButton(systemImage: "trash", labelText: "削除"){
                            if !editState.allowDrag{
                                let sIndex = selectState.selectedIndex
                                let lpsIndex = selectState.longpressSelectedIndex
                                if lpsIndex == -1{
                                    self.keyData.remove(at: sIndex)
                                    self.selectState.selectedIndex = -1
                                }else{
                                    self.keyData[sIndex].longpresses.remove(at: lpsIndex)
                                    self.selectState.longpressSelectedIndex = -1
                                }
                            }
                        }
                        .foregroundColor(.primary)

                        Spacer()
                    }/*
                    Group{
                        ToolBarButton(systemImage: "bubble.middle.bottom", labelText: "長押し設定"){
                            editState.state = .none
                        }
                        .foregroundColor(.primary)

                        Spacer()
                    }
 */
                    
                    Group{
                        ToolBarButton(systemImage: "arrow.left.arrow.right", labelText: "移動"){
                            editState.toggle(.drag)
                        }
                        .foregroundColor(editState.allowDrag ? .accentColor:.primary)
                        Spacer()
                    }
                    Group{
                        ToolBarButton(systemImage: "text.cursor", labelText: "入力"){
                            editState.state = .action
                        }
                        .foregroundColor(editState.editAction ? .accentColor:.primary)

                        Spacer()
                    }
                    Group{
                        ToolBarButton(systemImage: "questionmark.square", labelText: "ラベル"){
                            editState.state = .label
                        }
                        .foregroundColor(editState.editLabel ? .accentColor:.primary)

                        Spacer()
                    }
                    Group{
                        ToolBarButton(systemImage: "plus", labelText: "追加"){
                            let sIndex = selectState.selectedIndex
                            let lpsIndex = selectState.longpressSelectedIndex
                            if lpsIndex == -1{
                                self.keyData.append(RomanCustomKey(name: "", longpress: []))
                            }else{
                                self.keyData[sIndex].longpresses.append(RomanVariationKey(name: "", input: ""))
                            }
                        }
                        .foregroundColor(.primary)

                    }
                }
                .frame(maxHeight: 50)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.systemGray5))
                .padding()
            }
        }
    }


    private func pointedIndex(index: Int, delta: CGFloat) -> Int{
        print(index, delta)
        if delta.isZero{
            return index
        }
        if delta < 0{
            //負の場合
            var position = CGFloat.zero
            var index = index
            while index >= 0{
                position -= (width + padding*2)
                if position < delta{
                    return index
                }
                index -= 1
            }
            return 0
        }else{
            //正の場合
            var position = CGFloat.zero
            var index = index + 1
            let endIndex: Int
            if selectState.longpressSelectedIndex == -1{
                endIndex = keyData.endIndex
            }else{
                endIndex = keyData[selectState.selectedIndex].longpresses.endIndex
            }
            while index < endIndex{
                position += (width + padding*2)
                if delta < position{
                    return index
                }

                index += 1
            }
            return endIndex
        }

    }

    func update(index: Int, delta: CGFloat){
        let targetIndex = self.pointedIndex(index: index, delta: delta)
        self.selectState.targetIndex = targetIndex
    }

    func longPressUpdate(index: Int, delta: CGFloat){
        let targetIndex = self.pointedIndex(index: index, delta: delta)
        self.selectState.longpressTargetIndex = targetIndex
    }

    func onEnd(){
        let selectedIndex = selectState.selectedIndex
        let targetIndex = selectState.targetIndex
        if targetIndex != -1{
            if selectedIndex > targetIndex{
                let item = self.keyData.remove(at: selectedIndex)
                self.keyData.insert(item, at: targetIndex)
                self.selectState.selectedIndex = targetIndex
            }else if selectedIndex < targetIndex{
                self.keyData.insert(self.keyData[selectedIndex], at: targetIndex)
                self.keyData.remove(at: selectedIndex)
                self.selectState.selectedIndex = targetIndex - 1
            }
        }
        self.selectState.targetIndex = -1
    }

    func longPressOnEnd(){
        let selectedKeyIndex = selectState.selectedIndex
        let selectedIndex = selectState.longpressSelectedIndex
        let targetIndex = selectState.longpressTargetIndex
        if targetIndex != -1{
            if selectedIndex > targetIndex{
                let item = keyData[selectedKeyIndex].longpresses.remove(at: selectedIndex)
                keyData[selectedKeyIndex].longpresses.insert(item, at: targetIndex)
                self.selectState.longpressSelectedIndex = targetIndex
            }else if selectedIndex < targetIndex{
                keyData[selectedKeyIndex].longpresses.insert(keyData[selectedKeyIndex].longpresses[selectedIndex], at: targetIndex)
                keyData[selectedKeyIndex].longpresses.remove(at: selectedIndex)
                self.selectState.longpressSelectedIndex = targetIndex - 1
            }
        }
        self.selectState.longpressTargetIndex = -1

    }

}

struct ToolBarButton: View{
    let systemImage: String
    let labelText: String
    let action: () -> ()

    var body: some View {
        Button{
            action()
        }label: {
            VStack{
                Image(systemName: systemImage)
                    .font(.system(size: 23))
                Spacer()
                Text(labelText)
                    .font(.system(size: 10))

            }
        }
        .padding(.horizontal, 10)
    }
}

struct DraggableItem: View {
    enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }

    @GestureState var dragState = DragState.inactive
    @State var viewState: CGSize = .zero
    @ObservedObject private var selectState: SelectState
    @ObservedObject private var editState: EditState

    let index: Int
    let label: String
    let long: Bool

    let onEnd: () -> ()
    let update: (Int, CGFloat) -> ()

    init(selectState: SelectState, editState: EditState, index: Int, label: String, long: Bool = false, update: @escaping (Int, CGFloat) -> (), onEnd: @escaping () -> ()){
        self.selectState = selectState
        self.editState = editState
        self.index = index
        self.label = label
        self.long = long
        self.update = update
        self.onEnd = onEnd
    }

    var focused: Bool {
        if long && selectState.longpressSelectedIndex == index{
            return true
        }
        if !long && selectState.selectedIndex == index{
            return selectState.longpressSelectedIndex == -1
        }
        return false
    }

    var strokeColor: Color {
        if focused{
            return .accentColor
        }
        if longpressFocused{
            return .gray
        }
        return .primary
    }

    var longpressFocused: Bool {
        return !long && selectState.selectedIndex == index && selectState.longpressSelectedIndex != -1
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(strokeColor)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemGray6))
            .focus(.accentColor, focused: focused)
            .focus(.gray, focused: longpressFocused)

            .overlay(Text(label))
            .offset(
                x: viewState.width + dragState.translation.width,
                y: viewState.height + dragState.translation.height
            )
            .onTapGesture {
                if !long{
                    self.selectState.selectedIndex = index
                    self.selectState.longpressSelectedIndex = -1
                }else{
                    self.selectState.longpressSelectedIndex = index
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragState){value, state, transaction in
                        if !long{
                            if self.selectState.selectedIndex == index && editState.allowDrag{
                                update(index, value.translation.width)
                                state = .dragging(translation: value.translation)
                                return
                            }
                        }else{
                            if self.selectState.longpressSelectedIndex == index && editState.allowDrag{
                                update(index, value.translation.width)
                                state = .dragging(translation: value.translation)
                                return
                            }
                        }
                    }
                    .onEnded {_ in
                        if editState.allowDrag{
                            print("終了")
                            self.onEnd()
                        }
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
