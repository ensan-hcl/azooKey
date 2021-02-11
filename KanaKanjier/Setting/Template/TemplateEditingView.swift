//
//  TemplateEditingView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct TemplateEditingView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject private var data: TemplateDataList
    let index: Int

    @ObservedObject private var variableSection: TemplateEditingViewVariableSection
    @State private var name: String = ""

    init(_ data: TemplateDataList, index: Int){
        self.index = index
        self.data = data
        self._name = State(initialValue: data.templates[index].data.name)
        self.variableSection = data.templates[index].variableSection
    }

    var doneButton: some View {
        Button{
            //validation
            let sames = data.templates.indices.filter{data.templates[$0].data.name == name}
            if sames != [index] && !sames.isEmpty{
                return
            }
            if name.isEmpty{
                return
            }
            //データの更新
            data.templates[index].data.name = self.name
            data.templates[index].data.type = self.variableSection.selection
            //画面を閉じる
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("完了")
        }
    }

    var body: some View {
        Form{
            VStack{
                HStack{
                    Text("名前")
                    TextField("テンプレート名", text: $name)

                }
                let sames = data.templates.indices.filter{data.templates[$0].data.name == name}
                if sames != [index] && !sames.isEmpty{
                    Text("\(systemImage: "exclamationmark.triangle")名前が重複しています")
                }
                if name.isEmpty{
                    Text("\(systemImage: "exclamationmark.triangle")名前を入力してください")
                }
            }
            Picker(selection: $variableSection.selection, label: Text("")){
                Text("時刻").tag(TemplateLiteralType.date)
                Text("ランダム").tag(TemplateLiteralType.random)
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())

            switch variableSection.selection{
            case .date:
                DateTemplateLiteralSettingView(data, index: index, variableSection: variableSection)
            case .random:
                RandomTemplateLiteralSettingView(data, index: index, variableSection: variableSection)
            }
        }.navigationBarTitle(Text("テンプレートを編集"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing: doneButton)
    }
}

struct RandomTemplateLiteralSettingView: View {
    static let templateLiteralType = TemplateLiteralType.random
    enum Error{
        case nan
        case stringIsNil
    }
    private let timer = Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()
    //リテラル
    @ObservedObject private var data: TemplateDataList

    @State private var literal = RandomTemplateLiteral(value: .int(from: 1, to: 6))
    @State private var type: RandomTemplateLiteral.ValueType = .int
    //表示用
    @State private var previewString: String = ""

    @State private var intStringFrom: String = "1"
    @State private var intStringTo: String = "6"

    @State private var doubleStringFrom: String = "0"
    @State private var doubleStringTo: String = "1"

    @State private var stringsString: String = "グー,チョキ,パー"

    @ObservedObject private var variableSection: TemplateEditingViewVariableSection
    private let index: Int

    fileprivate init(_ data: TemplateDataList, index: Int, variableSection: TemplateEditingViewVariableSection){
        self.index = index
        self.data = data
        self.variableSection = variableSection
        if let template = data.templates[index].data.literal as? RandomTemplateLiteral{
            self._literal = State(initialValue: template)
            self._type = State(initialValue: template.value.type)
            switch template.value{
            case let .int(from: left, to: right):
                self._intStringFrom = State(initialValue: "\(left)")
                self._intStringTo = State(initialValue: "\(right)")
            case let .double(from: left, to: right):
                self._doubleStringFrom = State(initialValue: "\(left)")
                self._doubleStringTo = State(initialValue: "\(right)")
            case let .string(strings):
                self._stringsString = State(initialValue: strings.joined(separator: ","))
            }
        }
        self._previewString = State(initialValue: self.literal.previewString())
    }

    func update(){
        if variableSection.selection != Self.templateLiteralType{
            return
        }
        switch self.type{
        case .int:
            guard let left = Int(intStringFrom),
                  let right = Int(intStringTo) else{
                return
            }
            let min = left<right ? left:right
            let max = left<right ? right:left
            self.literal.value = .int(from: min, to: max)
        case .double:
            guard let left = Double(doubleStringFrom),
                  let right = Double(doubleStringTo) else{
                return
            }
            let min = left<right ? left:right
            let max = left<right ? right:left
            self.literal.value = .double(from: min, to: max)
        case .string:
            let strings = stringsString.components(separatedBy: ",")
            self.literal.value = .string(strings)
        }
        self.previewString = self.literal.previewString()
        self.data.templates[index].data.literal = self.literal
    }

    func warning(_ type: Error) -> some View {
        let warningSymbol = Image(systemName: "exclamationmark.triangle")
        switch type{
        case .nan:
            return Text("\(warningSymbol)値が無効です。有効な数値を入力してください")
        case .stringIsNil:
            return Text("\(warningSymbol)文字列が入っていません。最低一つは必要です")
        }
    }

    var body: some View {
        Group{
            Section(header: Text("値の種類")){
                Picker("値の種類", selection: $type){
                    Text("整数").tag(RandomTemplateLiteral.ValueType.int)
                    Text("小数").tag(RandomTemplateLiteral.ValueType.double)
                    Text("文字列").tag(RandomTemplateLiteral.ValueType.string)
                }
            }
            Section(header: Text("プレビュー")){
                HStack{
                    Text(previewString)
                    Spacer()
                }
            }.onReceive(timer){_ in
                self.update()
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
                        warning(.nan)
                    }
                }
                VStack{
                    HStack{
                        TextField("右端の値", text: $intStringTo)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("まで")
                    }
                    if Int(intStringTo) == nil{
                        warning(.nan)
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
                        warning(.nan)
                    }
                }
                VStack{
                    HStack{
                        TextField("右端の値", text: $doubleStringTo)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("まで")
                    }
                    if Double(doubleStringTo) == nil{
                        warning(.nan)
                    }
                }
            case .string:
                VStack{
                    HStack{
                        TextField("表示する値(カンマ区切り)", text: $stringsString)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    if stringsString.isEmpty{
                        warning(.stringIsNil)
                    }
                }
            }
        }.font(.body)
    }

}


struct DateTemplateLiteralSettingView: View {
    static let templateLiteralType = TemplateLiteralType.date
    //リテラル
    @ObservedObject private var data: TemplateDataList

    @State private var literal = DateTemplateLiteral.example
    private let index: Int
    //選択されているテンプレート
    @State private var formatSelection = "yyyy年MM月dd日"
    //表示用
    @State private var date: Date = Date()
    @State private var dateString: String = ""
    @ObservedObject private var variableSection: TemplateEditingViewVariableSection

    @State private var formatter: DateFormatter = DateFormatter()

    fileprivate init(_ data: TemplateDataList, index: Int, variableSection: TemplateEditingViewVariableSection){
        self.data = data
        self.index = index
        self.variableSection = variableSection
        if let template = data.templates[index].data.literal as? DateTemplateLiteral{
            if template.language == DateTemplateLiteral.example.language,
               template.type == DateTemplateLiteral.example.type,
               template.delta == DateTemplateLiteral.example.delta,
               template.deltaUnit == DateTemplateLiteral.example.deltaUnit,
               ["yyyy年MM月dd日", "HH:mm", "yyyy/MM/dd"].contains(template.format){
                var literal = DateTemplateLiteral.example
                literal.format = template.format
                self._literal = State(initialValue: literal)
                self._formatSelection = State(initialValue: template.format)
            }else{
                self._literal = State(initialValue: template)
                self._formatSelection = State(initialValue: "カスタム")
            }
        }

        if formatSelection == "カスタム"{
            self.formatter.dateFormat = literal.format
            self.formatter.locale = Locale(identifier: literal.language.identifier)
            self.formatter.calendar = Calendar(identifier: literal.type.identifier)
        }else{
            self.formatter.dateFormat = formatSelection
            self.formatter.locale = Locale(identifier: "ja_JP")
            self.formatter.calendar = Calendar(identifier: .gregorian)
        }
    }

    static let yyyy年MM月dd日: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月dd日"
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    static let HH_mm: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    static let yyyy_MM_dd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    func update(){
        if formatSelection == "カスタム"{
            self.date = Date().advanced(by: (Double(literal.delta) ?? .nan) * Double(literal.deltaUnit))
            self.data.templates[index].data.literal = self.literal
        }else{
            self.date = Date()
            self.data.templates[index].data.literal = DateTemplateLiteral(format: formatSelection, type: .western, language: .japanese, delta: "0", deltaUnit: 1)
        }
    }

    var body: some View {
        Group{
            Section(header: Text("書式の設定")){
                VStack{
                    Picker("書式", selection: $formatSelection){
                        Text(Self.yyyy年MM月dd日.string(from: date)).tag("yyyy年MM月dd日")
                        Text(Self.HH_mm.string(from: date)).tag("HH:mm")
                        Text(Self.yyyy_MM_dd.string(from: date)).tag("yyyy/MM/dd")
                        Text("カスタム").tag("カスタム")
                    }.onChange(of: formatSelection) {value in
                        if value != "カスタム"{
                            formatter.dateFormat = value
                            formatter.locale = Locale(identifier: "ja_JP")
                            formatter.calendar = Calendar(identifier: .gregorian)
                            update()
                        }else{
                            formatter.dateFormat = literal.format
                            formatter.locale = Locale(identifier: literal.language.identifier)
                            formatter.calendar = Calendar(identifier: literal.type.identifier)
                            update()
                        }
                        update()
                    }
                }
            }
            Section(header: Text("プレビュー")){
                HStack{
                    Text(formatter.string(from: date))
                    Spacer()
                    Button{
                        update()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                        Text("更新")
                    }
                    
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
                        }
                        if Double(literal.delta) == nil{
                            Text("\(systemImage: "exclamationmark.triangle")値が無効です。有効な数値を入力してください")
                        }
                    }

                    HStack{
                        Text("暦の種類")
                        Spacer()
                        Picker(selection: $literal.type, label: Text("")) {
                            Text("西暦").tag(DateTemplateLiteral.CalendarType.western)
                            Text("和暦").tag(DateTemplateLiteral.CalendarType.japanese)
                        }
                    }
                    HStack{
                        Text("言語")
                        Spacer()
                        Picker(selection: $literal.language, label: Text("")) {
                            Text("日本語").tag(DateTemplateLiteral.Language.japanese)
                            Text("英語").tag(DateTemplateLiteral.Language.english)
                        }

                    }
                }
                .onChange(of: literal){value in
                    formatter.dateFormat = value.format
                    formatter.locale = Locale(identifier: value.language.identifier)
                    formatter.calendar = Calendar(identifier: value.type.identifier)
                    update()
                }
                Section(header: Text("書式はyyyyMMddhhmmssフォーマットで記述します。詳しい記法はインターネット等で確認できます。")){
                    FallbackLink("Web検索", destination: "https://www.google.com/search?q=yyyymmddhhmm")
                }
            }

        }
    }
}
