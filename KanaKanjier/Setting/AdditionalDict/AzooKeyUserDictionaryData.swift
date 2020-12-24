//
//  AzooKeyUserDictionaryData.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/23.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

final class EditableUserDictionaryData: ObservableObject {
    lazy var availableChars: [Character] = {
        do{
            let string = try String(contentsOfFile: Bundle.main.bundlePath + "/charID.chid", encoding: String.Encoding.utf8)

            return Array(string).filter{!["\t",","," ","\0"].contains($0)}
        }catch{
            return []
        }
    }()

    @Published var ruby: String
    @Published var word: String
    @Published var isVerb: Bool
    @Published var isPersonName: Bool
    @Published var isPlaceName: Bool

    let id: Int

    init(ruby: String, word: String, isVerb: Bool, isPersonName: Bool, isPlaceName: Bool, id: Int){
        self.ruby = ruby
        self.word = word
        self.id = id
        self.isVerb = isVerb
        self.isPersonName = isPersonName
        self.isPlaceName = isPlaceName
    }

    func neadVerbCheck() -> Bool {
        let result = self.ruby.last == "る" && ["る", "ル"].contains(self.word.last)
        return result
    }

    var mizenkeiRuby: String {
        self.ruby.dropLast() + "らない"
    }

    var mizenkeiWord: String {
        self.word.dropLast() + "らない"
    }

    enum AppendError{
        case rubyEmpty
        case wordEmpty
        case unavailableCharacter

        var message: String {
            switch self{
            case .rubyEmpty:
                return "読みが空です"
            case .wordEmpty:
                return "単語が空です"
            case .unavailableCharacter:
                return "読みに使用できない文字が含まれます。ひらがな、英字、数字を指定してください"
            }
        }

    }

    var error: AppendError? {
        if ruby.isEmpty{
            return .rubyEmpty
        }
        if word.isEmpty{
            return .wordEmpty
        }
        if !self.ruby.applyingTransform(.hiraganaToKatakana, reverse: false)!.allSatisfy({self.availableChars.contains($0)}){
            return .unavailableCharacter
        }
        return nil
    }

    func makeStableData() -> UserDictionaryData {
        if !self.neadVerbCheck() && isVerb{
            isVerb = false
        }
        return UserDictionaryData(ruby: ruby, word: word, isVerb: isVerb, isPersonName: isPersonName, isPlaceName: isPlaceName, id: id)
    }

}

struct UserDictionary: Codable {
    let items: [UserDictionaryData]

    init(items: [UserDictionaryData]){
        self.items = items.indices.map{i in
            let item = items[i]
            return UserDictionaryData(ruby: item.ruby, word: item.word, isVerb: item.isVerb, isPersonName: item.isPersonName, isPlaceName: item.isPlaceName, id: i)
        }
    }

    func save(){
        let encoder = JSONEncoder()
        let saveData: Data
        if let encodedValue = try? encoder.encode(self) {
            saveData = encodedValue
        }else{
            saveData = Data()
        }
        UserDefaults.standard.set(saveData, forKey: "user_dict")
    }
    static func get() -> Self? {
        if let value = UserDefaults.standard.value(forKey: "user_dict") as? Data{
            let decoder = JSONDecoder()
            if let userDictionary = try? decoder.decode(UserDictionary.self, from: value) {
                return userDictionary
            }
        }
        return nil
    }
}

struct UserDictionaryData: Identifiable, Codable{
    let ruby: String
    let word: String
    let isVerb: Bool
    let isPersonName: Bool
    let isPlaceName: Bool
    let id: Int

    func makeEditableData() -> EditableUserDictionaryData {
        return EditableUserDictionaryData(ruby: ruby, word: word, isVerb: isVerb, isPersonName: isPersonName, isPlaceName: isPlaceName, id: id)
    }

    static func emptyData(id: Int) -> Self {
        return UserDictionaryData(ruby: "", word: "", isVerb: false, isPersonName: false, isPlaceName: false, id: id)
    }
}



