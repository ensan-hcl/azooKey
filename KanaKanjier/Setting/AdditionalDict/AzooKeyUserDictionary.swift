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
        UserDictionaryData(ruby: "あずき", word: "azooKey", isVerb: false, isPersonName: true, isPlaceName: false, id: 0)
    ]
    @Published var mode: Mode = .list
    @Published var selectedItem: EditableUserDictionaryData?

    enum Mode {
        case list
        case details(Cancelable)
    }

    enum Cancelable {
        case cancelable
        case incancelable
    }

    init() {
        if let userDictionary = UserDictionary.get() {
            self.items = userDictionary.items
        }
    }
}

struct AzooKeyUserDictionaryView: View {
    @ObservedObject private var variables: UserDictManagerVariables = UserDictManagerVariables()

    var body: some View {
        Group {
            switch variables.mode {
            case .list:
                UserDictionaryDataListView(variables: variables)
            case let .details(cancelable):
                switch cancelable {
                case .cancelable:
                    if let item = self.variables.selectedItem {
                        UserDictionaryDataSettingView(item, variables: variables, cancelable: true)
                    }
                case .incancelable:
                    if let item = self.variables.selectedItem {
                        UserDictionaryDataSettingView(item, variables: variables)
                    }
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
                HStack {
                    Spacer()
                    Button {
                        let id = variables.items.map {$0.id}.max()
                        self.variables.selectedItem = UserDictionaryData.emptyData(id: (id ?? -1) + 1).makeEditableData()
                        self.variables.mode = .details(.cancelable)

                    }label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("追加する")
                        }
                    }
                    Spacer()

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
                                self.variables.mode = .details(.incancelable)
                            }label: {
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
        .navigationBarItems(trailing: EmptyView())
    }

    func delete(section: String) -> (IndexSet) -> Void {
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
            let userDictionary = UserDictionary(items: variables.items)
            userDictionary.save()

            let builder = LOUDSBuilder(txtFileSplit: 2048)
            builder.process()
            Store.shared.noticeReloadUserDict()

        }
    }

}

private struct UserDictionaryDataSettingView: View {
    @ObservedObject private var item: EditableUserDictionaryData
    @ObservedObject private var variables: UserDictManagerVariables
    private let cancelable: Bool

    init(_ item: EditableUserDictionaryData, variables: UserDictManagerVariables, cancelable: Bool = false) {
        self.item = item
        self.variables = variables
        self.cancelable = cancelable
    }

    var body: some View {
        Form {
            Section(header: Text("読みと単語"), footer: Text("\(systemImage: "doc.on.clipboard")を長押しでペースト")) {
                HStack {
                    TextField("単語", text: $item.word)
                        .padding(.vertical, 2)
                    // FIXME: 技術的に厳しかった
                    /*
                     HighlightableTextField("単語", text: $item.word){text in
                     let parts = highlight(text)
                     HStack(spacing: 0){
                     ForEach(parts.indices, id: \.self){i in
                     switch parts[i].type{
                     case .normal:
                     Text(parts[i].text)
                     case .background:
                     Text(parts[i].text)
                     .foregroundColor(.orange)
                     .bold()
                     .tracking(-0.5)
                     }
                     }
                     Spacer()
                     }
                     }
                     */
                    Divider()
                    PasteLongPressButton($item.word)
                        .padding(.horizontal, 5)
                }
                HStack {
                    TextField("読み", text: $item.ruby)
                        .padding(.vertical, 2)
                    Divider()
                    PasteLongPressButton($item.ruby)
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
                    HStack {
                        Toggle(isOn: $item.isVerb) {
                            Text("「\(item.mizenkeiWord)(\(item.mizenkeiRuby))」と言える")
                        }
                    }
                }
                HStack {
                    Spacer()
                    Toggle(isOn: $item.isPersonName) {
                        Text("人・動物・会社などの名前である")
                    }
                }
                HStack {
                    Spacer()
                    Toggle(isOn: $item.isPlaceName) {
                        Text("場所・建物などの名前である")
                    }
                }

            }
        }
        .navigationTitle(Text("詳細設定"))
        .navigationBarBackButtonHidden(true)

        .navigationBarItems(
            leading: Group {
                if self.cancelable {
                    Button {
                        variables.mode = .list
                    } label: {
                        Text("キャンセル")
                    }
                }
            },
            trailing: Button {
                if item.error == nil {
                    self.save()
                    variables.mode = .list
                    Store.shared.feedbackGenerator.notificationOccurred(.success)
                }
            } label: {
                Text("完了")
            }
        )
        .onDisappear {
            self.save()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) {_ in
            self.save()
        }
    }

    private enum HighlightType {
        case normal
        case background
    }

    private func highlight<S: StringProtocol>(_ text: S) -> [(text: String, type: HighlightType)] {
        if let range = text.range(of: "\\{\\{.*?\\}\\}", options: .regularExpression) {
            let lowerSide = text[text.startIndex ..< range.lowerBound]
            let internalSide = text[range]
            let upperSide = text[range.upperBound ..< text.endIndex]

            return highlight(lowerSide) + [(String(internalSide), .background)] + highlight(upperSide)
        } else {
            return [(String(text), .normal)]
        }
    }

    private func save() {
        if item.error == nil {
            if let itemIndex = variables.items.firstIndex(where: {$0.id == self.item.id}) {
                variables.items[itemIndex] = item.makeStableData()
            } else {
                variables.items.append(item.makeStableData())
            }

            let userDictionary = UserDictionary(items: variables.items)
            userDictionary.save()

            let builder = LOUDSBuilder(txtFileSplit: 2048)
            builder.process()
            Store.shared.noticeReloadUserDict()
        }
    }
}

private struct HighlightableTextField<Content: View>: View {
    private let title: LocalizedStringKey
    @Binding private var text: String
    private let covering: (String) -> Content

    init(_ title: LocalizedStringKey, text: Binding<String>, @ViewBuilder covering: @escaping (String) -> Content) {
        self.title = title
        self._text = text
        self.covering = covering
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            covering(text)
                .allowsHitTesting(false)
                .lineLimit(1)
                .truncationMode(.head)
            TextField(title, text: $text)
                .foregroundColor(.clear)

        }
    }
}
