//
//  AzooKeyUserDictionary.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/05.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
import Foundation

private final class UserDictManagerVariables: ObservableObject {
    @Published var items: [UserDictionaryData] = [
        UserDictionaryData(ruby: "あずーきー", word: "azooKey", isVerb: false, isPersonName: true, isPlaceName: false, id: 0)
    ]
    @Published var mode: Mode = .list
    @Published var selectedItem: EditableUserDictionaryData?

    enum Mode {
        case list, details
    }

    init() {
        if let userDictionary = UserDictionary.get() {
            self.items = userDictionary.items
        }
    }

    func save() {
        let userDictionary = UserDictionary(items: self.items)
        userDictionary.save()

        let builder = LOUDSBuilder(txtFileSplit: 2048)
        builder.process()
        Store.shared.noticeReloadUserDict()
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
        }.onDisappear {
            Store.shared.shouldTryRequestReview = true
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
                CenterAlignedView {
                    Button {
                        let id = variables.items.map {$0.id}.max()
                        self.variables.selectedItem = UserDictionaryData.emptyData(id: (id ?? -1) + 1).makeEditableData()
                        self.variables.mode = .details
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("追加する")
                        }
                    }
                }
            }

            let currentGroupedItems: [String: [UserDictionaryData]] = Dictionary(grouping: variables.items, by: {$0.ruby.first.map {String($0)} ?? exceptionKey}).mapValues {$0.sorted {$0.id < $1.id}}
            let keys = currentGroupedItems.keys
            let currentKeys: [String] = keys.contains(exceptionKey) ? [exceptionKey] + keys.filter {$0 != exceptionKey}.sorted() : keys.sorted()

            ForEach(currentKeys, id: \.self) {key in
                Section(header: Text(key)) {
                    List {
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
                        }
                        .onDelete(perform: self.delete(section: key))
                    }.environment(\.editMode, $editMode)
                }
            }
        }
        .navigationBarTitle(Text("ユーザ辞書"), displayMode: .inline)
    }

    private func delete(section: String) -> (IndexSet) -> Void {
        return {(offsets: IndexSet) in
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
    typealias EditTarget = EditableUserDictionaryData
    fileprivate let base: EditableUserDictionaryData

    init(_ item: EditableUserDictionaryData, variables: UserDictManagerVariables) {
        self.item = item
        self.variables = variables
        self.base = item.copy()
    }

    var body: some View {
        Form {
            Section(header: Text("読みと単語"), footer: Text("\(systemImage: "doc.on.clipboard")を長押しでペースト")) {
                HStack {
                    TextField("単語", text: $item.data.word)
                        .padding(.vertical, 2)
                    Divider()
                    PasteLongPressButton($item.data.word)
                        .padding(.horizontal, 5)
                }
                HStack {
                    TextField("読み", text: $item.data.ruby)
                        .padding(.vertical, 2)
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
                        Toggle(isOn: $item.data.isVerb) {
                            Text("「\(item.mizenkeiWord)(\(item.mizenkeiRuby))」と言える")
                        }
                }
                    Toggle(isOn: $item.data.isPersonName) {
                        Text("人・動物・会社などの名前である")
                    }
                    Toggle(isOn: $item.data.isPlaceName) {
                        Text("場所・建物などの名前である")
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
                    Store.shared.feedbackGenerator.notificationOccurred(.success)
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
        item.reset(from: base)
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
