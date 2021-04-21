//
//  AzooKeyUserDictionaryData.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/23.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

final class EditableUserDictionaryData: ObservableObject {
    lazy var availableChars: [Character] = {
        do {
            let string = try String(contentsOfFile: Bundle.main.bundlePath + "/charID.chid", encoding: String.Encoding.utf8)

            return Array(string).filter {!["\t", ",", " ", "\0"].contains($0)}
        } catch {
            return []
        }
    }()

    @Published var data: UserDictionaryData
    let id: Int

    init(data: UserDictionaryData) {
        self.data = data
        self.id = data.id
    }

    func neadVerbCheck() -> Bool {
        let result = self.data.ruby.last == "る" && ["る", "ル"].contains(self.data.word.last)
        return result
    }

    var mizenkeiRuby: String {
        self.data.ruby.dropLast() + "らない"
    }

    var mizenkeiWord: String {
        self.data.word.dropLast() + "らない"
    }

    enum AppendError {
        case rubyEmpty
        case wordEmpty
        case unavailableCharacter

        var message: LocalizedStringKey {
            switch self {
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
        if self.data.word.isEmpty {
            return .wordEmpty
        }
        if self.data.ruby.isEmpty {
            return .rubyEmpty
        }
        if !self.data.ruby.applyingTransform(.hiraganaToKatakana, reverse: false)!.allSatisfy({self.availableChars.contains($0)}) {
            return .unavailableCharacter
        }
        return nil
    }

    func makeStableData() -> UserDictionaryData {
        var result = self.data
        if !self.neadVerbCheck() && self.data.isVerb {
            result.isVerb = false
        }
        return result
    }

    func copy() -> EditableUserDictionaryData {
        return .init(data: data)
    }

    func reset(from copy: EditableUserDictionaryData) {
        self.data = copy.data
    }
}

struct UserDictionary: Codable {
    let items: [UserDictionaryData]

    init(items: [UserDictionaryData]) {
        self.items = items.indices.map {i in
            let item = items[i]
            return UserDictionaryData(ruby: item.ruby, word: item.word, isVerb: item.isVerb, isPersonName: item.isPersonName, isPlaceName: item.isPlaceName, id: i)
        }
    }

    func save() {
        let encoder = JSONEncoder()
        let saveData: Data
        if let encodedValue = try? encoder.encode(self) {
            saveData = encodedValue
        } else {
            saveData = Data()
        }
        UserDefaults.standard.set(saveData, forKey: "user_dict")
    }
    static func get() -> Self? {
        if let value = UserDefaults.standard.value(forKey: "user_dict") as? Data {
            let decoder = JSONDecoder()
            if let userDictionary = try? decoder.decode(UserDictionary.self, from: value) {
                return userDictionary
            }
        }
        return nil
    }
}

struct UserDictionaryData: Identifiable, Codable {
    var ruby: String
    var word: String
    var isVerb: Bool
    var isPersonName: Bool
    var isPlaceName: Bool
    let id: Int

    func makeEditableData() -> EditableUserDictionaryData {
        return EditableUserDictionaryData(data: self)
    }

    static func emptyData(id: Int) -> Self {
        return UserDictionaryData(ruby: "", word: "", isVerb: false, isPersonName: false, isPlaceName: false, id: id)
    }
}
