//
//  AzooKeyUserDictionary.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/05.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
import Foundation

final class EditableUserDictionaryData: ObservableObject {
    lazy var availableChars: [Character] = {
        do{
            let string = try String(contentsOfFile: Bundle.main.bundlePath + "/charID.chid", encoding: String.Encoding.utf8)

            return Array(string)
        }catch{
            return []
        }
    }()

    @Published var ruby: String
    @Published var word: String

    init(ruby: String, word: String){
        self.ruby = ruby
        self.word = word
    }

    func neadVerbCheck() -> Bool {
        return self.ruby.last == "る" && ["る", "ル"].contains(self.word.last)
    }

    var mizenkeiRuby: String {
        self.ruby.dropLast() + "らない"
    }

    var mizenkeiWord: String {
        self.word.dropLast() + "らない"
    }

    var hasError: Bool {
        return !self.ruby.applyingTransform(.hiraganaToKatakana, reverse: false)!.allSatisfy{self.availableChars.contains($0)}
    }
}

struct UserDictionary: Codable {
    let items: [UserDictionaryData]
}

struct UserDictionaryData: Identifiable, Codable{
    let ruby: String
    let word: String
    let id: Int

    func makeEditableData() -> EditableUserDictionaryData {
        return EditableUserDictionaryData(ruby: ruby, word: word)
    }
}

struct AzooKeyUserDictionaryView: View {
    let exceptionKey = "その他"
    @State private var isActiveAddView = false
    @State private var listMode = true
    @State private var items: [UserDictionaryData] = [
        UserDictionaryData(ruby: "あずき", word: "azooKey", id: 0),
    ]



    var body: some View {
        Form {
            if listMode{
                Section{
                    Text("変換候補に単語を追加することができます。iOSの標準のユーザ辞書とは異なります。")
                }

                Section{
                    HStack{
                        Text("追加する")
                        Spacer()
                        Button{
                            let id = self.items.map{$0.id}.max()
                            items.append(UserDictionaryData(ruby: "", word: "", id: (id ?? -1) + 1))
                        }label: {
                            HStack {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                let currentGroupedItems = Dictionary(grouping: self.items, by: {$0.ruby.first.map{String($0)} ?? exceptionKey})
                let keys = currentGroupedItems.keys
                let currentKeys = keys.contains(exceptionKey) ? [exceptionKey] + keys.filter{$0 != exceptionKey}.sorted() : keys.sorted()

                ForEach(currentKeys, id: \.self){key in
                    Section(header: Text(key)){
                        ForEach(currentGroupedItems[key]!){data in
                            let editableData = data.makeEditableData()
                            Button{
                                self.listMode = true
                            }label: {
                                HStack{
                                    Text(editableData.word)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(editableData.ruby)
                                        .foregroundColor(.systemGray)
                                }
                            }
                        }

                    }
                }
            }else{
                UserDictionaryDataSettingView(EditableUserDictionaryData(ruby:"", word: ""))
            }
        }
        .navigationBarTitle(Text("ユーザ辞書"), displayMode: .inline)
    }
}


struct UserDictionaryDataSettingView: View {
    @ObservedObject private var item: EditableUserDictionaryData

    @State private var isVerb = false
    @State private var isPlaceName = false
    @State private var isPersonName = false

    init(_ item: EditableUserDictionaryData){
        self.item = item
    }

    var body: some View {
        Form {
            Section(header: Text("読みと単語")){
                HStack{
                    TextField("読み", text: $item.ruby)
                    if item.hasError{
                        Image(systemName: "exclamationmark.triangle")
                    }
                }
                TextField("単語", text: $item.word)
            }
            Section(header: Text("詳細な設定")){
                if item.neadVerbCheck(){
                    HStack{
                        Toggle(isOn: $isVerb) {
                            Text("「\(item.mizenkeiWord)(\(item.mizenkeiRuby))」と言える")
                        }
                    }
                }
                HStack{
                    Spacer()
                    Toggle(isOn: $isPersonName) {
                        Text("人・動物などの名前である")
                    }
                }
                HStack{
                    Spacer()
                    Toggle(isOn: $isPlaceName) {
                        Text("場所・建物などの名前である")
                    }
                }

            }
        }
        .onDisappear{
            print("見えなくなるからここで更新処理をかける")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)){_ in
            print("バックグラウンドに入るからここで更新処理をかける")
        }

    }

    func save(){
        //userDefaultから今ある一覧を読み込む

        //一覧にデータを足すか、変更する
    }
}
