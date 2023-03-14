//
//  Store.swift
//  MainApp
//
//  Created by ensan on 2020/09/16.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import class CoreHaptics.CHHapticEngine

final class Store {
    static let shared = Store()
    var feedbackGenerator = UINotificationFeedbackGenerator()
    var messageManager = MessageManager()
    var hapticsEnabled = false

    init() {
        SemiStaticStates.shared.setNeedsInputModeSwitchKeyMode(UIInputViewController().needsInputModeSwitchKey)
        // ユーザ辞書に登録がない場合など
        self.messageManager.getMessagesContainerAppShouldMakeWhichDone().forEach {
            messageManager.done($0.id)
        }
        SharedStore.setInitialAppVersion()
        SharedStore.setLastAppVersion()
        self.hapticsEnabled = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    func noticeReloadUserDict() {
        SharedStore.userDefaults.set(true, forKey: "reloadUserDict")
    }

    var isKeyboardActivated: Bool {
        let bundleName = SharedStore.bundleName
        guard let keyboards = UserDefaults.standard.dictionaryRepresentation()["AppleKeyboards"] as? [String] else {
            return true
        }
        return keyboards.contains(bundleName)
    }

    /// - note:フルアクセスの状態は`UIInputViewController`のインスタンスを1つ作るとわかる。
    var isFullAccessEnabled: Bool {
        UIInputViewController().hasFullAccess
    }

    let imageMaximumWidth: CGFloat = 500

    var shouldTryRequestReview: Bool = false

    func shouldRequestReview() -> Bool {
        self.shouldTryRequestReview = false
        if let lastDate = UserDefaults.standard.value(forKey: "last_reviewed_date") as? Date {
            if -lastDate.timeIntervalSinceNow < 3000000 {   // 最後に表示してから1ヶ月は再度表示しない
                return false
            }
        }

        // 1/5の確率で表示する
        let rand = Int.random(in: 0...4)

        if rand == 0 {
            UserDefaults.standard.set(Date(), forKey: "last_reviewed_date")
            return true
        }
        return false
    }
}

final class MainAppStates: ObservableObject {
    @Published var isKeyboardActivated: Bool = Store.shared.isKeyboardActivated
    @Published var requireFirstOpenView: Bool = !Store.shared.isKeyboardActivated
    @Published var japaneseLayout: LanguageLayout = .flick
    @Published var englishLayout: LanguageLayout = .flick
    @Published var custardManager: CustardManager

    init() {
        @KeyboardSetting(.japaneseKeyboardLayout) var japaneseKeyboardLayout
        self.japaneseLayout = japaneseKeyboardLayout
        @KeyboardSetting(.englishKeyboardLayout) var englishKeyboardLayout
        self.englishLayout = englishKeyboardLayout
        self.custardManager = CustardManager.load()
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
