//
//  AzooKeyUserDictionary.swift
//  MainApp
//
//  Created by ensan on 2020/12/05.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

private final class UserDictManagerVariables: ObservableObject {
    @Published var items: [UserDictionaryData] = [
        UserDictionaryData(ruby: "あずーきー", word: "azooKey", isVerb: false, isPersonName: true, isPlaceName: false, id: 0)
    ]
    @Published var mode: Mode = .list
    @Published var selectedItem: EditableUserDictionaryData?
    @Published var templates = TemplateData.load()

    enum Mode {
        case list, details
    }

    init() {
        if let userDictionary = UserDictionary.get() {
            self.items = userDictionary.items
        }
    }

    @MainActor func save() {
        TemplateData.save(templates)

        let userDictionary = UserDictionary(items: self.items)
        userDictionary.save()

        let builder = LOUDSBuilder(txtFileSplit: 2048)
        builder.process()
    }
}

struct AzooKeyUserDictionaryView: View {
    @ObservedObject private var variables: UserDictManagerVariables = UserDictManagerVariables()

    var body: some View {
        Group {
            switch variables.mode {
            case .list:
                UserDictionaryDataListView(variables: variables)
            case .details:
                if let item = self.variables.selectedItem {
                    UserDictionaryDataEditor(item, variables: variables)
                }
            }
        }
        .onDisappear {
            RequestReviewManager.shared.shouldTryRequestReview = true
        }
    }
}

private struct UserDictionaryDataListView: View {
    private let exceptionKey = "その他"

    @ObservedObject private var variables: UserDictManagerVariables
    @State private var editMode = EditMode.inactive

    init(variables: UserDictManagerVariables) {
        self.variables = variables
    }

    var body: some View {
        Form {
            Section {
                Text("変換候補に単語を追加することができます。iOSの標準のユーザ辞書とは異なります。")
            }

            Section {
                Button("\(systemImage: "plus")追加する") {
                    let id = variables.items.map {$0.id}.max()
                    self.variables.selectedItem = UserDictionaryData.emptyData(id: (id ?? -1) + 1).makeEditableData()
                    self.variables.mode = .details
                }
            }

            let currentGroupedItems: [String: [UserDictionaryData]] = Dictionary(grouping: variables.items, by: {$0.ruby.first.map {String($0)} ?? exceptionKey}).mapValues {$0.sorted {$0.id < $1.id}}
            let keys = currentGroupedItems.keys
            let currentKeys: [String] = keys.contains(exceptionKey) ? [exceptionKey] + keys.filter {$0 != exceptionKey}.sorted() : keys.sorted()
            List {
                ForEach(currentKeys, id: \.self) {key in
                    Section(header: Text(key)) {
                        ForEach(currentGroupedItems[key]!) {data in
                            Button {
                                self.variables.selectedItem = data.makeEditableData()
                                self.variables.mode = .details
                            } label: {
                                HStack {
                                    Text(data.word)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(data.ruby)
                                        .foregroundColor(.systemGray)
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    variables.items.removeAll(where: {$0.id == data.id})
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: self.delete(section: key))
                    }.environment(\.editMode, $editMode)
                }
            }
        }
        .onAppear {
            variables.templates = TemplateData.load()
        }
        .navigationBarTitle(Text("ユーザ辞書"), displayMode: .inline)
    }

    private func delete(section: String) -> (IndexSet) -> Void {
        {(offsets: IndexSet) in
            let indices: [Int]
            if section == exceptionKey {
                indices = variables.items.indices.filter {variables.items[$0].ruby.first == nil}
            } else {
                indices = variables.items.indices.filter {variables.items[$0].ruby.hasPrefix(section)}
            }
            let sortedIndices = indices.sorted {
                variables.items[$0].id < variables.items[$1].id
            }
            variables.items.remove(atOffsets: IndexSet(offsets.map {sortedIndices[$0]}))
            variables.save()
        }
    }
}

private struct UserDictionaryDataEditor: CancelableEditor {
    @ObservedObject private var item: EditableUserDictionaryData
    @ObservedObject private var variables: UserDictManagerVariables
    @State private var selectedTemplate: (name: String, index: Int)? = nil

    // CancelableEditor Conformance
    typealias EditTarget = (EditableUserDictionaryData, [TemplateData])
    fileprivate let base: EditTarget

    init(_ item: EditableUserDictionaryData, variables: UserDictManagerVariables) {
        self.item = item
        self.variables = variables
        self.base = (item.copy(), variables.templates)
    }

    @available(iOS 16.0, *)
    private func hasTemplate(word: String) -> Bool {
        return word.contains(templateRegex)
    }

    private func templateIndex(name: String) -> Int? {
        return variables.templates.firstIndex(where: {$0.name == name})
    }

    // こちらは「今まで同名のテンプレートがなかった」場合にのみテンプレートを追加する
    private func addNewTemplate(name: String) {
        if !variables.templates.contains(where: {$0.name == name}) {
            variables.templates.append(TemplateData(template: DateTemplateLiteral.example.export(), name: name))
        }
    }

    @State private var wordEditMode: Bool = false
    @State private var pickerTemplateName: String? = nil
    @FocusState private var focusOnWordField: Bool?

    @available(iOS 16.0, *)
    private var templateRegex: some RegexComponent {
        /{{.+?}}/
    }

    @available(iOS 16.0, *)
    private func parsedWord(word: String) -> [String] {
        var result: [String] = []
        var startIndex = word.startIndex
        while let range = word[startIndex...].firstMatch(of: templateRegex)?.range {
            result.append(String(word[startIndex ..< range.lowerBound]))
            result.append(String(word[range]))
            startIndex = range.upperBound
        }
        result.append(String(word[startIndex ..< word.endIndex]))

        return result
    }

    @available(iOS 16.0, *)
    private func replaceTemplate(selectedTemplate: (name: String, index: Int), newName: String) {
        var parsedWords = parsedWord(word: item.data.word)
        if parsedWords.indices.contains(selectedTemplate.index) && parsedWords[selectedTemplate.index] == "{{\(selectedTemplate.name)}}" {
            parsedWords[selectedTemplate.index] = "{{\(newName)}}"
            item.data.word = parsedWords.joined()
        }
    }

    @ViewBuilder
    @available(iOS 16.0, *)
    private func templateWordView(word: String) -> some View {
        let parsedWords = parsedWord(word: word)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(parsedWords.indices, id: \.self) { i in
                    let isTemplate = parsedWords[i].wholeMatch(of: templateRegex) != nil
                    if isTemplate {
                        Button {
                            debug("Template:", parsedWords[i])
                            selectedTemplate = (String(parsedWords[i].dropFirst(2).dropLast(2)), i)
                        } label: {
                            Text(parsedWords[i])
                                .foregroundColor(.primary)
                                .padding(0)
                                .background(Color.orange.opacity(0.7).cornerRadius(5))
                        }
                    } else {
                        Text(parsedWords[i])
                            .padding(0)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var wordField: some View {
        TextField("単語", text: $item.data.word)
            .padding(.vertical, 2)
            .focused($focusOnWordField, equals: true)
            .submitLabel(.done)
            .onSubmit {
                selectedTemplate = nil
                wordEditMode = false
            }
    }

    @available(iOS 16.0, *)
    @ViewBuilder
    private func templateEditor(index: Int, selectedTemplate: (name: String, index: Int)) -> some View {
        if variables.templates[index].name == selectedTemplate.name {
            TemplateEditingView($variables.templates[index], validationInfo: variables.templates.map{$0.name}, options: .init(nameEdit: false, appearance: .embed { template in
                if template.name == selectedTemplate.name && index < variables.templates.endIndex  {
                    variables.templates[index] = template
                } else {
                    debug("templateEditor: Unknown situation:", template, selectedTemplate, variables.templates[index])
                }
            }))
        }
    }

    var body: some View {
        Form {
            Section(header: Text("読みと単語"), footer: Text("\(systemImage: "doc.on.clipboard")を長押しでペースト")) {
                HStack {
                    if wordEditMode {
                        wordField
                    } else {
                        if #available(iOS 16.0, *), hasTemplate(word: item.data.word) {
                            templateWordView(word: item.data.word)
                            Spacer()
                            Divider()
                            Button {
                                wordEditMode = true
                                focusOnWordField = true
                                selectedTemplate = nil
                            } label: {
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            }
                        } else  {
                            wordField
                        }
                        Divider()
                        PasteLongPressButton($item.data.word)
                            .padding(.horizontal, 5)
                    }
                }
                HStack {
                    TextField("読み", text: $item.data.ruby)
                        .padding(.vertical, 2)
                        .submitLabel(.done)
                    Divider()
                    PasteLongPressButton($item.data.ruby)
                        .padding(.horizontal, 5)
                }
                if let error = item.error {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text(error.message)
                            .font(.caption)
                    }
                }
            }
            Section(header: Text("詳細な設定")) {
                if item.neadVerbCheck() {
                    Toggle("「\(item.mizenkeiWord)(\(item.mizenkeiRuby))」と言える", isOn: $item.data.isVerb)
                }
                Toggle("人・動物・会社などの名前である", isOn: $item.data.isPersonName)
                Toggle("場所・建物などの名前である", isOn: $item.data.isPlaceName)
            }
            if #available(iOS 16.0, *), let selectedTemplate {
                if let index = templateIndex(name: selectedTemplate.name) {
                    Section(header: Text("テンプレートを編集する")) {
                        Text("{{\(selectedTemplate.name)}}を編集できます")
                    }
                    templateEditor(index: index, selectedTemplate: selectedTemplate)
                } else {
                    Section(header: Text("テンプレートを編集する")) {
                        Text("{{\(selectedTemplate.name)}}というテンプレートが見つかりません。")
                        Button {
                            self.addNewTemplate(name: selectedTemplate.name)
                        } label: {
                            Text("{{\(selectedTemplate.name)}}を新規作成")
                        }
                        if !variables.templates.isEmpty {
                            Picker("テンプレートを選ぶ", selection: $pickerTemplateName) {
                                Text("なし").tag(String?.none)
                                ForEach(variables.templates, id: \.name) {
                                    Text($0.name).tag(String?.some($0.name))
                                }
                            }
                            .onChange(of: pickerTemplateName) { newValue in
                                if let newValue {
                                    self.replaceTemplate(selectedTemplate: selectedTemplate, newName: newValue)
                                    self.selectedTemplate?.name = newValue
                                    self.pickerTemplateName = nil
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("設定"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("キャンセル", action: cancel),
            trailing: Button("完了") {
                if item.error == nil {
                    self.save()
                    variables.mode = .list
                    MainAppFeedback.success()
                }
            }
        )
        .onDisappear {
            self.save()
        }
        .onEnterBackground {_ in
            self.save()
        }
    }

    fileprivate func cancel() {
        item.reset(from: base.0)
        variables.templates = base.1
        variables.mode = .list
    }

    private func save() {
        if item.error == nil {
            if let itemIndex = variables.items.firstIndex(where: {$0.id == self.item.id}) {
                variables.items[itemIndex] = item.makeStableData()
            } else {
                variables.items.append(item.makeStableData())
            }
            variables.save()
        }
    }
}
