//
//  TemplateEditingView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct TemplateEditingView: CancelableEditor {
    enum Appearance {
        case form
        case embed(saveProcess: (TemplateData) -> Void)
    }

    struct Options {
        var nameEdit: Bool = true
        var appearance: Appearance = .form
    }

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    internal let base: TemplateData
    private let options: Options
    @Binding private var template: TemplateData
    @State private var editingTemplate: TemplateData
    // 名前の一覧
    private let validationInfo: [String]

    init(_ template: Binding<TemplateData>, validationInfo: [String], options: Options = Options()) {
        debug("TemplateEditingView.init", template.wrappedValue)
        self._template = template
        self.base = template.wrappedValue
        self._editingTemplate = State(initialValue: template.wrappedValue)
        self.validationInfo = validationInfo
        self.options = options
    }

    @ViewBuilder
    private var editorCore: some View {
        if options.nameEdit {
            VStack {
                HStack {
                    Text("名前")
                    TextField("テンプレート名", text: $editingTemplate.name)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                }
                if case let .nameError(message) = validation() {
                    Label(message, systemImage: "exclamationmark.triangle")
                        .foregroundColor(.primary)
                }
            }
        }
        Picker(selection: $editingTemplate.type, label: Text("")) {
            Text("時刻").tag(TemplateLiteralType.date)
            Text("ランダム").tag(TemplateLiteralType.random)
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        switch editingTemplate.type {
        case .date:
            DateTemplateLiteralSettingView($editingTemplate)
        case .random:
            RandomTemplateLiteralSettingView($editingTemplate)
        }
    }

    var body: some View {
        switch options.appearance {
        case .form:
            Form {
                editorCore
            }
            .navigationBarTitle(Text("テンプレートを編集"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("キャンセル", action: cancel),
                trailing: Button("完了", action: save)
            )
        case .embed(let save):
            editorCore
                .onDisappear {
                    save(editingTemplate)
                }
        }
    }

    private enum ValidationResult {
        case success
        case nameError(LocalizedStringKey)
    }

    private func validation() -> ValidationResult {
        if editingTemplate.name.isEmpty {
            return .nameError("名前を入力してください")
        }
        if editingTemplate.name != base.name {
            let sames = validationInfo.filter {$0 == editingTemplate.name}
            if sames.count == 1 {
                return .nameError("名前が重複しています")
            }
        }
        return .success
    }

    private func save() {
        guard case .success = validation() else {
            return
        }
        // データの更新
        template = editingTemplate
        // 画面を閉じる
        presentationMode.wrappedValue.dismiss()
    }

    func cancel() {
        template = base
        presentationMode.wrappedValue.dismiss()
    }
}

struct RandomTemplateLiteralSettingView: View {
    private static let templateLiteralType = TemplateLiteralType.random
    private enum Error {
        case nan
        case stringIsNil
    }
    // リテラル
    @Binding private var template: TemplateData

    @State private var literal = RandomTemplateLiteral(value: .int(from: 1, to: 6))
    @State private var type: RandomTemplateLiteral.ValueType = .int

    @State private var intStringRange = (left: "1", right: "6")
    @State private var doubleStringRange = (left: "0", right: "1")
    @State private var stringsString: String = "グー,チョキ,パー"

    fileprivate init(_ template: Binding<TemplateData>) {
        self._template = template
        if let template = template.wrappedValue.literal as? RandomTemplateLiteral {
            self._literal = State(initialValue: template)
            self._type = State(initialValue: template.value.type)
            switch template.value {
            case let .int(from: left, to: right):
                self._intStringRange = State(initialValue: ("\(left)", "\(right)"))
            case let .double(from: left, to: right):
                self._doubleStringRange = State(initialValue: ("\(left)", "\(right)"))
            case let .string(strings):
                self._stringsString = State(initialValue: strings.joined(separator: ","))
            }
        }
    }

    private func update() {
        if template.type != Self.templateLiteralType {
            return
        }
        switch self.type {
        case .int:
            guard let left = Int(intStringRange.left),
                  let right = Int(intStringRange.right) else {
                return
            }
            self.literal.value = .int(from: min(left, right), to: max(left, right))
        case .double:
            guard let left = Double(doubleStringRange.left),
                  let right = Double(doubleStringRange.right) else {
                return
            }
            self.literal.value = .double(from: min(left, right), to: max(left, right))
        case .string:
            let strings = stringsString.components(separatedBy: ",")
            self.literal.value = .string(strings)
        }
        self.template.literal = self.literal
    }

    private func warning(_ type: Error) -> some View {
        let warningSymbol = Image(systemName: "exclamationmark.triangle")
        switch type {
        case .nan:
            return Text("\(warningSymbol)値が無効です。有効な数値を入力してください")
        case .stringIsNil:
            return Text("\(warningSymbol)文字列が入っていません。最低一つは必要です")
        }
    }

    var body: some View {
        Group {
            Section(header: Text("値の種類")) {
                Picker("値の種類", selection: $type) {
                    Text("整数").tag(RandomTemplateLiteral.ValueType.int)
                    Text("小数").tag(RandomTemplateLiteral.ValueType.double)
                    Text("文字列").tag(RandomTemplateLiteral.ValueType.string)
                }
            }
            Section(header: Text("プレビュー")) {
                TimelineView(.periodic(from: Date(), by: 0.8)) { _ in
                    Text(self.literal.previewString())
                }
            }

            switch type {
            case .int:
                VStack {
                    HStack {
                        TextField("左端の値", text: $intStringRange.left)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .submitLabel(.done)
                            .onSubmit(update)
                        Text("から")
                    }
                    if Int(intStringRange.left) == nil {
                        warning(.nan)
                    }
                }
                VStack {
                    HStack {
                        TextField("右端の値", text: $intStringRange.right)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .submitLabel(.done)
                            .onSubmit(update)
                        Text("まで")
                    }
                    if Int(intStringRange.right) == nil {
                        warning(.nan)
                    }
                }
            case .double:
                VStack {
                    HStack {
                        TextField("左端の値", text: $doubleStringRange.left)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                            .onSubmit(update)
                        Text("から")
                    }
                    if Double(doubleStringRange.left) == nil {
                        warning(.nan)
                    }
                }
                VStack {
                    HStack {
                        TextField("右端の値", text: $doubleStringRange.right)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                            .onSubmit(update)
                        Text("まで")
                    }
                    if Double(doubleStringRange.right) == nil {
                        warning(.nan)
                    }
                }
            case .string:
                VStack {
                    HStack {
                        TextField("表示する値(カンマ区切り)", text: $stringsString)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .onSubmit(update)
                    }
                    if stringsString.isEmpty {
                        warning(.stringIsNil)
                    }
                }
            }
        }
    }
}

struct DateTemplateLiteralSettingView: View {
    private static let templateLiteralType = TemplateLiteralType.date
    // リテラル
    @Binding private var template: TemplateData

    @State private var literal = DateTemplateLiteral.example
    // 選択されているテンプレート
    @State private var formatSelection = "yyyy年MM月dd日"
    // 表示用
    @State private var date: Date = Date()
    @State private var dateString: String = ""
    @State private var formatter: DateFormatter = DateFormatter()

    fileprivate init(_ template: Binding<TemplateData>) {
        self._template = template
        if let template = template.wrappedValue.literal as? DateTemplateLiteral {
            if template.language == DateTemplateLiteral.example.language,
               template.type == DateTemplateLiteral.example.type,
               template.delta == DateTemplateLiteral.example.delta,
               template.deltaUnit == DateTemplateLiteral.example.deltaUnit,
               ["yyyy年MM月dd日", "HH:mm", "yyyy/MM/dd"].contains(template.format) {
                var literal = DateTemplateLiteral.example
                literal.format = template.format
                self._literal = State(initialValue: literal)
                self._formatSelection = State(initialValue: template.format)
            } else {
                self._literal = State(initialValue: template)
                self._formatSelection = State(initialValue: "カスタム")
            }
        }

        if formatSelection == "カスタム"{
            self.formatter.dateFormat = literal.format
            self.formatter.locale = Locale(identifier: literal.language.identifier)
            self.formatter.calendar = Calendar(identifier: literal.type.identifier)
        } else {
            self.formatter.dateFormat = formatSelection
            self.formatter.locale = Locale(identifier: "ja_JP")
            self.formatter.calendar = Calendar(identifier: .gregorian)
        }
        self.update()
    }

    private static let yyyy年MM月dd日: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月dd日"
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    private static let HH_mm: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    private static let yyyy_MM_dd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    private func update() {
        DispatchQueue.main.async {
            if formatSelection == "カスタム"{
                self.date = Date().advanced(by: (Double(literal.delta) ?? .nan) * Double(literal.deltaUnit))
                self.template.literal = self.literal
            } else {
                self.date = Date()
                self.template.literal = DateTemplateLiteral(format: formatSelection, type: .western, language: .japanese, delta: "0", deltaUnit: 1)
            }
        }
    }

    var body: some View {
        Group {
            Section(header: Text("書式の設定")) {
                VStack {
                    Picker("書式", selection: $formatSelection) {
                        Text(Self.yyyy年MM月dd日.string(from: date)).tag("yyyy年MM月dd日")
                        Text(Self.HH_mm.string(from: date)).tag("HH:mm")
                        Text(Self.yyyy_MM_dd.string(from: date)).tag("yyyy/MM/dd")
                        Text("カスタム").tag("カスタム")
                    }.onChange(of: formatSelection) {value in
                        if value != "カスタム"{
                            formatter.dateFormat = value
                            formatter.locale = Locale(identifier: "ja_JP")
                            formatter.calendar = Calendar(identifier: .gregorian)
                        } else {
                            formatter.dateFormat = literal.format
                            formatter.locale = Locale(identifier: literal.language.identifier)
                            formatter.calendar = Calendar(identifier: literal.type.identifier)
                        }
                        update()
                    }
                }
            }

            Section(header: Text("プレビュー")) {
                TimelineView(.periodic(from: Date(), by: 0.5)) { _ in
                    Text(formatter.string(from: Date()))
                }
            }
            if formatSelection == "カスタム"{
                Section(header: Text("カスタム書式")) {
                    HStack {
                        Text("書式")
                        Spacer()
                        TextField("書式を入力", text: $literal.format)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                    }
                    VStack {
                        HStack {
                            Text("ズレ")
                            Spacer()
                            TextField("ズレ", text: $literal.delta)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .submitLabel(.done)
                            Picker(selection: $literal.deltaUnit, label: Text("")) {
                                Text("日").tag(60 * 60 * 24)
                                Text("時間").tag(60 * 60)
                                Text("分").tag(60)
                                Text("秒").tag(1)
                            }
                        }
                        if Double(literal.delta) == nil {
                            Text("\(systemImage: "exclamationmark.triangle")値が無効です。有効な数値を入力してください")
                        }
                    }
                    Picker("暦の種類", selection: $literal.type) {
                        Text("西暦").tag(DateTemplateLiteral.CalendarType.western)
                        Text("和暦").tag(DateTemplateLiteral.CalendarType.japanese)
                    }
                    Picker("言語", selection: $literal.language) {
                        Text("日本語").tag(DateTemplateLiteral.Language.japanese)
                        Text("英語").tag(DateTemplateLiteral.Language.english)
                    }
                }
                .onChange(of: literal) {value in
                    formatter.dateFormat = value.format
                    formatter.locale = Locale(identifier: value.language.identifier)
                    formatter.calendar = Calendar(identifier: value.type.identifier)
                    update()
                }
                Section(header: Text("書式はyyyyMMddhhmmssフォーマットで記述します。詳しい記法はインターネット等で確認できます。")) {
                    FallbackLink("Web検索", destination: "https://www.google.com/search?q=yyyymmddhhmm")
                }
            }
        }
    }
}
