//
//  AzooKeyUserDictionary.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/05.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
import Foundation

struct UserDictionaryData{
    let ruby: String
    let word: String
}

struct AzooKeyUserDictionaryView: View {
    @State private var items: [UserDictionaryData] = [
        UserDictionaryData(ruby: "とりぷる", word: "トリプる"),
        UserDictionaryData(ruby: "くえ", word: "クエ"),
        UserDictionaryData(ruby: "あんみんさくいおん", word: "アンミン錯イオン"),
        UserDictionaryData(ruby: "だいいっせい", word: "第一声"),
        UserDictionaryData(ruby: "だいにせい", word: "第二声"),
        UserDictionaryData(ruby: "だいさんせい", word: "第三声"),
        UserDictionaryData(ruby: "だいよんせい", word: "第四声"),
        UserDictionaryData(ruby: "すうけん", word: "数研"),
        UserDictionaryData(ruby: "しめじ", word: "Simeji"),
    ]

    var groupedItems: [String: UserDictionaryData] {
        return [:]
    }

    var body: some View {
        Form {
            Section{
                Text("変換候補に出てこない単語を追加することができます。iOSの標準のユーザ辞書とは異なります。")
            }
            Section{
                List(0..<10){i in
                    Text("item\(i)")
                }
            }
        }
        .navigationBarTitle(Text("ユーザ辞書"), displayMode: .inline)
        .navigationBarItems(trailing: Button{
            print("押された")
        }label: {
            HStack {
                Image(systemName: "plus")
            }
        })

    }
}
