//
//  App.swift
//  App
//
//  Created by ensan on 2021/08/22.
//  Copyright © 2021 ensan. All rights reserved.
//

import SwiftUI

final class MainAppStates: ObservableObject {
    @Published var isKeyboardActivated: Bool
    @Published var requireFirstOpenView: Bool
    @Published var japaneseLayout: LanguageLayout = .flick
    @Published var englishLayout: LanguageLayout = .flick
    @Published var custardManager: CustardManager

    init() {
        let keyboardActivation = SharedStore.checkKeyboardActivation()
        self.isKeyboardActivated = keyboardActivation
        self.requireFirstOpenView = !keyboardActivation
        @KeyboardSetting(.japaneseKeyboardLayout) var japaneseKeyboardLayout
        self.japaneseLayout = japaneseKeyboardLayout
        @KeyboardSetting(.englishKeyboardLayout) var englishKeyboardLayout
        self.englishLayout = englishKeyboardLayout
        self.custardManager = CustardManager.load()
        SemiStaticStates.shared.setHapticsAvailable()
    }
}

@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MainAppStates())
                .onAppear {
                    // MARK: セットアップ
                    SharedStore.setInitialAppVersion()
                    SharedStore.setLastAppVersion()
                    // 本体アプリで特定の作業を行わなずにDoneにできる場合。
                    var messageManager = MessageManager()
                    messageManager.getMessagesContainerAppShouldMakeWhichDone().forEach {
                        messageManager.done($0.id)
                    }
                }
        }
    }
}
