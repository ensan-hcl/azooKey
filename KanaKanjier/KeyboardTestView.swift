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

protocol TemplateLiteralProtocol{
    static func `import`(from string: String) -> Self
    func export() -> String
}

enum TemplateLiteralType{
    case date
    case random
}


//QiitaのタグみたいなTextField
struct TestView2: View {
    @State private var text: String = ""
    let borderColor = Color(.sRGB, red: 0.745, green: 0.866, blue: 0.988)
    let fillColor = Color(.sRGB, red: 0.847, green: 0.917, blue: 0.992)
    var body: some View {
        ZStack{
            TextField("入力", text: $text)
                .foregroundColor(.clear)
            HStack(spacing:0){
                let strings = text.split(separator: " ", omittingEmptySubsequences: false)
                ForEach(strings.indices, id: \.self){i in
                    Text(strings[i])
                        .background(
                            fillColor
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(borderColor)
                                )
                        )
                        .padding(.horizontal, 2)
                }
                Spacer()
            }
        }
    }
}

struct TestView: View {
    @State private var selection: TemplateLiteralType = .date
    var body: some View {
        Form{
            Text("テンプレートを作成")
                .font(.title)
            Picker(selection: $selection, label: Text("")){
                Text("時刻").tag(TemplateLiteralType.date)
                Text("ランダム").tag(TemplateLiteralType.random)
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())

            switch selection{
            case .date:
                DateTemplateLiteralSettingView()
            case .random:
                RandomTemplateLiteralSettingView()
            }
        }
    }
}


struct DateTemplateLiteral: TemplateLiteralProtocol {
    var format: String
    var type: CalendarType
    var language: Language
    var delta: String
    var deltaUnit: Int

    enum CalendarType: String{
        case western = "western"
        case japanese = "japanese"

        var identifier: Calendar.Identifier {
            switch self{
            case .western:
                return .gregorian
            case .japanese:
                return .japanese
            }
        }
    }

    enum Language: String{
        case english = "en_US"
        case japanese = "ja_JP"

        var identifier: String {
            return self.rawValue
        }
    }

    static func `import`(from string: String) -> DateTemplateLiteral {
        let splited = string.split(separator: " ")
        let format = (splited.filter{$0.hasPrefix("format")}.first ?? "").dropFirst("format=\"".count).dropLast(1)
        let type = (splited.filter{$0.hasPrefix("type")}.first ?? "").dropFirst("type=\"".count).dropLast(1)
        let language = (splited.filter{$0.hasPrefix("language")}.first ?? "").dropFirst("language=\"".count).dropLast(1)
        let delta = (splited.filter{$0.hasPrefix("delta")}.first ?? "").dropFirst("delta=\"".count).dropLast(1)
        let deltaUnit = (splited.filter{$0.hasPrefix("deltaunit")}.first ?? "").dropFirst("deltaunit=\"".count).dropLast(1)

        return DateTemplateLiteral(
            format: String(format).unescaped(),
            type: CalendarType.init(rawValue: String(type))!,
            language: Language.init(rawValue: String(language))!,
            delta: String(delta),
            deltaUnit: Int(deltaUnit) ?? 0
        )
    }


    func export() -> String {
        return """
        <date format="\(format.escaped())" type="\(type.rawValue)" language="\(language.identifier)" delta="\(delta)" deltaunit="\(deltaUnit)">
        """
    }
}

struct RandomTemplateLiteral: TemplateLiteralProtocol{
    enum ValueType: String {
        case int = "int"
        case double = "double"
        case string = "string"
    }
    enum Value{
        case int(from: Int, to: Int)
        case double(from: Double, to: Double)
        case string([String])

        var type: ValueType {
            switch self{
            case .int(from: _, to: _):
                return .int
            case .double(from: _, to: _):
                return .double
            case .string(_):
                return .string
            }
        }

        var string: String {
            switch self {
            case let .int(from: left, to: right):
                return "\(left),\(right)"
            case let .double(from: left, to: right):
                return "\(left),\(right)"
            case let .string(strings):
                return strings.map{$0.escaped()}.joined(separator: ",")
            }
        }
    }
    var value: Value

    static func `import`(from string: String) -> RandomTemplateLiteral {
        let splited = string.split(separator: " ")
        let type = (splited.filter{$0.hasPrefix("type")}.first ?? "").dropFirst("type=\"".count).dropLast(1)
        let valueString = (splited.filter{$0.hasPrefix("value")}.first ?? "").dropFirst("value=\"".count).dropLast(1)

        let valueType = ValueType.init(rawValue: String(type))!
        let value: Value
        switch valueType{
        case .int:
            value = .int(from: Int(splited[0]) ?? 0, to: Int(splited[1]) ?? 0)
        case .double:
            let splited = valueString.split(separator: ",")
            value = .double(from: Double(splited[0]) ?? .nan, to: Double(splited[1]) ?? .nan)
        case .string:
            value = .string(valueString.components(separatedBy: ","))
        }
        return RandomTemplateLiteral(value: value)
    }

    func export() -> String {
        return """
        <random type="\(value.type.rawValue)" value="\(value.string)">
        """
    }

}

struct RandomTemplateLiteralSettingView: View {
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    //リテラル
    @State private var literal = RandomTemplateLiteral(value: .int(from: 1, to: 6))
    //表示用
    @State private var previewString: String = ""

    @State private var type: RandomTemplateLiteral.ValueType = .int {
        didSet{
            self.update()
        }
    }

    @State private var intStringFrom: String = "1"
    @State private var intStringTo: String = "6"

    @State private var doubleStringFrom: String = "0"
    @State private var doubleStringTo: String = "1"

    @State private var stringsString: String = "グー,チョキ,パー"

    func update(){
        switch self.type{
        case .int:
            guard let left = Int(intStringFrom),
                  let right = Int(intStringTo) else{
                return
            }
            let min = left<right ? left:right
            let max = left<right ? right:left
            previewString = "\(Int.random(in: min...max))"
            self.literal.value = .int(from: min, to: max)
        case .double:
            guard let left = Double(doubleStringFrom),
                  let right = Double(doubleStringTo) else{
                return
            }
            let min = left<right ? left:right
            let max = left<right ? right:left
            previewString = "\(Double.random(in: min...max))"
            self.literal.value = .double(from: min, to: max)
        case .string:
            let strings = stringsString.components(separatedBy: ",")
            previewString = strings.randomElement() ?? "値を設定してください"
            self.literal.value = .string(strings)
        }
    }

    var warning: some View {
        Text("\(Image(systemName: "exclamationmark.triangle"))値が無効です。有効な数値を入力してください")
    }

    var body: some View {
        Group{
            Section(header: Text("プレビュー")){
                HStack{
                    Text(previewString)
                    Spacer()
                }
            }
            Section(header: Text("値の種類")){
                VStack{
                    HStack{
                        Spacer()
                        Text("値の種類")
                        Spacer()
                    }
                    Picker("値の種類", selection: $type){
                        Text("整数").tag(RandomTemplateLiteral.ValueType.int)
                        Text("小数").tag(RandomTemplateLiteral.ValueType.double)
                        Text("文字列").tag(RandomTemplateLiteral.ValueType.string)
                    }
                    .labelsHidden()
                    .pickerStyle(WheelPickerStyle())
                    .padding(.vertical, -2)
                }
            }
            switch type{
            case .int:
                VStack{
                    HStack{
                        TextField("左端の値", text: $intStringFrom)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("から")
                    }
                    if Int(intStringFrom) == nil{
                        warning
                    }

                }
                VStack{
                    HStack{
                        TextField("右端の値", text: $intStringTo)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("まで")
                    }
                    if Int(intStringTo) == nil{
                        warning
                    }

                }
            case .double:
                VStack{
                    HStack{
                        TextField("左端の値", text: $doubleStringFrom)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("から")
                    }
                    if Double(doubleStringFrom) == nil{
                        warning
                    }
                }
                VStack{
                    HStack{
                        TextField("右端の値", text: $doubleStringTo)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("まで")
                    }
                    if Double(doubleStringTo) == nil{
                        warning
                    }
                }
            case .string:
                TextField("表示する値(カンマ区切り)", text: $stringsString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }.font(.body)
        .onReceive(timer){_ in
            self.update()
        }
    }
}


struct DateTemplateLiteralSettingView: View {
    private let timer = Timer.publish(every: 1/90, on: .main, in: .common).autoconnect()
    //リテラル
    @State private var literal = DateTemplateLiteral(format: "yyyy年MM月dd日(EEE) a hh:mm:ss", type: .western, language: .japanese, delta: "0", deltaUnit: 1) {
        didSet{
            self.update()
        }
    }
    //選択されているテンプレート
    @State private var formatSelection = "yyyy年MM月dd日"
    //表示用
    @State private var date: Date = Date()
    @State private var dateString: String = ""


    func update(){
        self.date = Date()
        let f = DateFormatter()
        if formatSelection == "カスタム"{
            f.dateFormat = literal.format
            f.locale = Locale(identifier: literal.language.identifier)
            f.calendar = Calendar(identifier: literal.type.identifier)
            dateString = f.string(from: date.advanced(by: (Double(literal.delta) ?? .nan) * Double(literal.deltaUnit)))
        }else{
            f.dateFormat = formatSelection
            f.locale = Locale(identifier: "ja_JP")
            f.calendar = Calendar(identifier: .gregorian)
            dateString = f.string(from: date)

        }
    }

    let yyyy年MM月dd日: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月dd日"
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    let HH_mm: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    let yyyy_MM_dd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    var body: some View {
        Group{
            Section(header: Text("プレビュー")){
                HStack{
                    Text(dateString)
                    Spacer()
                }
            }
            Section(header: Text("書式の設定")){
                VStack{
                    HStack{
                        Spacer()
                        Text("書式")
                        Spacer()
                    }
                    Picker("書式", selection: $formatSelection){
                        Text(date, formatter: yyyy年MM月dd日).tag("yyyy年MM月dd日")
                        Text(date, formatter: HH_mm).tag("HH:mm")
                        Text(date, formatter: yyyy_MM_dd).tag("yyyy/MM/dd")
                        Text("カスタム").tag("カスタム")
                    }
                    .labelsHidden()
                    .pickerStyle(WheelPickerStyle())
                    .padding(.vertical, -2)
                }
            }
            if formatSelection == "カスタム"{
                Section(header: Text("カスタム書式")){
                    HStack{
                        Text("書式")
                        Spacer()
                        TextField("書式を入力", text: $literal.format)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    VStack{
                        HStack{
                            Text("ズレ")

                            Spacer()
                            TextField("ズレ", text: $literal.delta)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Picker(selection: $literal.deltaUnit, label: Text("")) {
                                Text("日").tag(60*60*24)
                                Text("時間").tag(60*60)
                                Text("分").tag(60)
                                Text("秒").tag(1)
                            }
                            .labelsHidden()
                            .pickerStyle(InlinePickerStyle())
                            .frame(maxWidth: 100, maxHeight: 70)
                            .clipped()
                        }
                        if Double(literal.delta) == nil{
                            Text("\(Image(systemName: "exclamationmark.triangle"))値が無効です。有効な数値を入力してください")
                        }
                    }

                    HStack{
                        Text("暦の種類")
                        Spacer()
                        Picker(selection: $literal.type, label: Text("")) {
                            Text("西暦").tag(DateTemplateLiteral.CalendarType.western)
                            Text("和暦").tag(DateTemplateLiteral.CalendarType.japanese)
                        }
                        .labelsHidden()
                        .pickerStyle(InlinePickerStyle())
                        .frame(maxWidth: 100, maxHeight: 70)
                        .clipped()
                    }
                    HStack{
                        Text("言語")
                        Spacer()
                        Picker(selection: $literal.language, label: Text("")) {
                            Text("日本語").tag(DateTemplateLiteral.Language.japanese)
                            Text("英語").tag(DateTemplateLiteral.Language.english)
                        }
                        .labelsHidden()
                        .pickerStyle(InlinePickerStyle())
                        .frame(maxWidth: 100, maxHeight: 70)
                        .clipped()
                    }
                }
                Section(header: Text("書式はyyyyMMddhhmmssフォーマットで記述します。詳しい記法はインターネット等で確認できます。")){
                    FallbackLink("Web検索", destination: "https://www.google.com/search?q=yyyymmddhhmm")
                }
            }
        }.font(.body)
        .onReceive(timer){_ in
            self.update()
        }
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
 debug(self.direction)
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
