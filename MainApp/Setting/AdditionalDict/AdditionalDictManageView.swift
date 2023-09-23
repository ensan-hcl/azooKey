//
//  AdditionalDictManageView.swift
//  MainApp
//
//  Created by ensan on 2020/11/13.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

protocol OnOffSettingSet {
    associatedtype Target: Hashable, CaseIterable, RawRepresentable where Target.RawValue == String
    var state: [Target: Bool] { get set }
}

extension OnOffSettingSet {
    subscript(_ key: Target) -> Bool {
        get {
            state[key, default: false]
        }
        set {
            state[key] = newValue
        }
    }
}

struct AdditionalSystemDictManager: OnOffSettingSet {
    var state: [Target: Bool]

    init(dataList: [String]) {
        self.state = Target.allCases.reduce(into: [:]) {dict, target in
            dict[target] = dataList.contains(target.rawValue)
        }
    }

    enum Target: String, CaseIterable {
        case emoji
        case kaomoji

        var dictFileIdentifiers: [String] {
            switch self {
            case .emoji:
                if #available(iOS 16.4, *) {
                    return ["emoji_dict_E15.0.txt.gen"]
                } else if #available(iOS 15.4, *) {
                    return ["emoji_dict_E14.0.txt.gen"]
                } else {
                    return ["emoji_dict_E13.1.txt.gen"]
                }
            case .kaomoji:
                return ["kaomoji_dict.tsv"]
            }
        }
    }
}

struct AdditionalDictBlockManager: OnOffSettingSet {
    var state: [Target: Bool]

    init(dataList: [String]) {
        self.state = Target.allCases.reduce(into: [:]) {dict, target in
            dict[target] = dataList.contains(target.rawValue)
        }
    }

    enum Target: String, CaseIterable {
        case gokiburi
        case spiders

        var characters: [String] {
            switch self {
            case .gokiburi:
                return ["\u{1FAB3}"]
            case .spiders:
                return ["🕸", "🕷"]
            }
        }
    }
}

final class AdditionalDictManager: ObservableObject {
    @MainActor @Published var systemDict: AdditionalSystemDictManager {
        didSet {
            self.userDictUpdate()
        }
    }

    @MainActor @Published var blockTargets: AdditionalDictBlockManager {
        didSet {
            self.userDictUpdate()
        }
    }

    @MainActor init() {
        let systemDictList = UserDefaults.standard.array(forKey: "additional_dict") as? [String]
        self.systemDict = .init(dataList: systemDictList ?? [])

        let blockList = UserDefaults.standard.array(forKey: "additional_dict_blocks") as? [String]
        self.blockTargets = .init(dataList: blockList ?? [])
    }

    @MainActor func userDictUpdate() {
        var list: [String] = []
        AdditionalSystemDictManager.Target.allCases.forEach { target in
            if self.systemDict[target] {
                list.append(target.rawValue)
            }
        }

        var blocklist: [String] = []
        var blockTargets: [String] = []
        AdditionalDictBlockManager.Target.allCases.forEach { target in
            if self.blockTargets[target] {
                blocklist.append(target.rawValue)
                blockTargets.append(contentsOf: target.characters)
            }
        }

        UserDefaults.standard.setValue(list, forKey: "additional_dict")
        UserDefaults.standard.setValue(blocklist, forKey: "additional_dict_blocks")

        let builder = LOUDSBuilder(txtFileSplit: 2048)
        builder.process()
    }

}

@MainActor
struct AdditionalDictManageViewMain: View {
    enum Style {
        case simple
        case all
    }
    private let style: Style
    @StateObject private var viewModel = AdditionalDictManager()

    init(style: Style = .all) {
        self.style = style
    }

    var body: some View {
        Section(header: Text("利用するもの")) {
            Toggle(isOn: $viewModel.systemDict[.emoji]) {
                Text("絵文字")
                Text(verbatim: "🥺🌎♨️")
            }
            Toggle(isOn: $viewModel.systemDict[.kaomoji]) {
                Text("顔文字")
                Text(verbatim: "(◍•ᴗ•◍)")
            }
        }
        if self.style == .all {
            Section(header: Text("不快な絵文字を表示しない")) {
                Toggle("ゴキブリの絵文字を非表示", isOn: $viewModel.blockTargets[.gokiburi])
                Toggle("クモの絵文字を非表示", isOn: $viewModel.blockTargets[.spiders])
            }
        }
    }
}

struct AdditionalDictManageView: View {
    @EnvironmentObject private var appStates: MainAppStates
    var body: some View {
        Form {
            AdditionalDictManageViewMain()
        }
        .navigationBarTitle(Text("絵文字と顔文字"), displayMode: .inline)
        .onDisappear {
            appStates.requestReviewManager.shouldTryRequestReview = true
        }
    }
}
