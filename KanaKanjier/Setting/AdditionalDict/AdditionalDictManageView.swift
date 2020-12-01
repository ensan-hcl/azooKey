//
//  AdditionalDictManageView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/13.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum AdditionalDict: String {
    case emoji = "emoji"
    case kaomoji = "kaomoji"

    var dictFileIdentifiers: [String] {
        switch self{
        case .emoji:
            if #available(iOS 14.2, *){
                return ["emoji...12_dict.tsv", "emoji13_dict.tsv"]
            }else{
                return ["emoji...12_dict.tsv"]
            }
        case .kaomoji:
            return ["kaomoji_dict.tsv"]
        }
    }
}

final private class AdditionalDictManageViewModel: ObservableObject {
    @Published var kaomoji: Bool {
        didSet{
            self.userDictUpdate()
        }
    }

    @Published var emoji: Bool {
        didSet{
            self.userDictUpdate()
        }
    }

    @Published var gokiburi: Bool {
        didSet{
            self.userDictUpdate()
        }
    }

    init(){
        if let list = UserDefaults.standard.array(forKey: "additional_dict") as? [String]{
            self.kaomoji = list.contains("kaomoji")
            self.emoji = list.contains("emoji")
        }else{
            self.kaomoji = false
            self.emoji = false
        }

        if let list = UserDefaults.standard.array(forKey: "additional_dict_blocks") as? [String]{
            self.gokiburi = list.contains("gokiburi")
        }else{
            self.gokiburi = true
        }
    }

    func userDictUpdate(){
        var targets: [String] = []
        var list: [String] = []
        if kaomoji{
            targets.append(contentsOf: AdditionalDict.kaomoji.dictFileIdentifiers)
            list.append("kaomoji")
        }
        if emoji{
            targets.append(contentsOf: AdditionalDict.emoji.dictFileIdentifiers)
            list.append("emoji")
        }

        var blocklist: [String] = []
        var blockTargets: [String] = []
        if gokiburi{
            blocklist.append("gokiburi")
            blockTargets.append("\u{1FAB3}")    //ゴキブリの絵文字
        }
        let builder = LOUDSBuilder(txtFileSplit: 2048)
        builder.process(from: targets, block: blockTargets)
        UserDefaults.standard.setValue(list, forKey: "additional_dict")
        UserDefaults.standard.setValue(blocklist, forKey: "additional_dict_blocks")

        Store.shared.noticeReloadUserDict()
    }

}

struct AdditionalDictManageViewMain: View {
    enum Style{
        case simple
        case all
    }
    private let style: Style
    @ObservedObject private var viewModel = AdditionalDictManageViewModel()

    init(style: Style = .all){
        self.style = style
    }

    var body: some View {
            Section(header: Text("利用するもの")){
                HStack{
                    Text("絵文字")
                    Text("🥺🌎♨️")
                    Spacer()
                    Toggle(isOn: $viewModel.emoji, label: {})
                }
                HStack{
                    Text("顔文字")
                    Text("(◍•ᴗ•◍)")
                    Spacer()
                    Toggle(isOn: $viewModel.kaomoji, label: {})
                }
            }
            if self.style == .all{
                if #available(iOS 14.2, *){
                    Section(header: Text("不快な絵文字を表示しない")){
                        HStack{
                            Text("ゴキブリの絵文字を非表示")
                            Toggle(isOn: $viewModel.gokiburi, label: {})
                        }
                    }
                }
            }
    }
}

struct AdditionalDictManageView: View {
    var body: some View {
        NavigationView {
            Form {
                AdditionalDictManageViewMain()
            }
        }.navigationBarTitle(Text("絵文字と顔文字"), displayMode: .inline)
    }
}

