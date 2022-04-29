//
//  Store.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

final class Store {
    static let shared = Store()
    static var variableSection = StoreVariableSection()
    var feedbackGenerator = UINotificationFeedbackGenerator()
    var messageManager = MessageManager()

    init() {
        SemiStaticStates.shared.setNeedsInputModeSwitchKeyMode(DeviceName.shared.hasHomeButton())
        // ユーザ辞書に登録がない場合
        self.messageManager.getMessagesContainerAppShouldMakeWhichDone().forEach {
            messageManager.done($0.id)
        }
        /*
         let contents = ["user0.loudstxt2", "user.loudschars2", "user1.loudstxt2", "user.louds", "user4.loudstxt2", "user2.loudstxt2", "user5.loudstxt2", "user3.loudstxt2"]
         for fileName in contents{
         let filePath = directoryPath.appendingPathComponent(fileName).path
         if let attr = try? FileManager.default.attributesOfItem(atPath: filePath){
         print(attr[.size], fileName)
         }
         }

         print("themes内部")
         let theme_contents = ["theme_15.theme", "theme_22_bg.png", "theme_18_bg.png", "theme_20_bg.png", "theme_18.theme", "theme_4.theme", "theme_23.theme", "theme_2.theme", "theme_15_bg.png", "theme_19.theme", "theme_2_bg.png", "theme_23_bg.png", "index.json", "theme_24.theme", "theme_3.theme", "theme_20.theme", "theme_22.theme", "theme_1.theme"]

         for fileName in theme_contents{
         let filePath = directoryPath.appendingPathComponent("themes/"+fileName).path
         if let attr = try? FileManager.default.attributesOfItem(atPath: filePath){
         print(attr[.size], fileName)
         }
         }

         if let files = try? FileManager.default.contentsOfDirectory(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path){
         print(files)
         }
         */
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

    let imageMaximumWidth: CGFloat = 500

    var shouldTryRequestReview: Bool = false

    func shouldRequestReview() -> Bool {
        self.shouldTryRequestReview = false
        if let lastDate = UserDefaults.standard.value(forKey: "last_reviewed_date") as? Date {
            if -lastDate.timeIntervalSinceNow < 10000000 {   // 約3ヶ月半経過していたら
                return false
            }
        }

        let rand = Int.random(in: 0...4)

        if rand == 0 {
            UserDefaults.standard.set(Date(), forKey: "last_reviewed_date")
            return true
        }
        return false
    }

    func showCustardImportView(url: URL) {
        Self.variableSection.importFile = url
    }

}

final class StoreVariableSection: ObservableObject {
    @Published var isKeyboardActivated: Bool = Store.shared.isKeyboardActivated
    @Published var requireFirstOpenView: Bool = !Store.shared.isKeyboardActivated
    @Published var japaneseLayout: LanguageLayout = .flick
    @Published var englishLayout: LanguageLayout = .flick
    @Published var importFile: URL?

    init() {
        @KeyboardSetting(.japaneseKeyboardLayout) var japaneseKeyboardLayout
        self.japaneseLayout = japaneseKeyboardLayout
        @KeyboardSetting(.englishKeyboardLayout) var englishKeyboardLayout
        self.englishLayout = englishKeyboardLayout
    }
}
