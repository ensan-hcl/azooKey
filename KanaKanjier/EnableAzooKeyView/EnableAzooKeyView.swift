//
//  EnableAzooKeyView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

private enum EnableAzooKeyViewStep{
    case menu
    case append
    case finish
    case setting
}

struct EnableAzooKeyView: View {
    @State private var step: EnableAzooKeyViewStep = .menu
    @State private var text = ""
    @State private var showDoneMessage = false

    var body: some View {
        ScrollView{
            ScrollViewReader{value in
                CenterAlignedView(padding: 30){
                    switch self.step{
                    case .menu:
                        VStack(alignment: .leading, spacing: 20){
                            Spacer()
                            CenterAlignedView{
                                HeaderIconView()
                            }
                            EnableAzooKeyViewText("azooKeyを使う前に、iPhoneのキーボードのリストにazooKeyを追加する必要があります", with: "exclamationmark.triangle.fill")
                            CenterAlignedView{
                                EnableAzooKeyViewButton("手順を見る", systemName: "arrowtriangle.right.fill", style: .emphisized){
                                    self.step = .append
                                }
                            }
                        }
                        .onAppear{
                            value.scrollTo(0, anchor: .top)
                        }
                    case .append:
                        VStack(alignment: .leading, spacing: 20){

                            EnableAzooKeyViewHeader("追加する")
                            EnableAzooKeyViewText("下にスクロールして「追加する」を押して", with: "plus.circle")
                            EnableAzooKeyViewText("「キーボード」を押して", with: "keyboard")
                            EnableAzooKeyViewImage("initSettingKeyboardImage-hand")
                            EnableAzooKeyViewText("azooKeyをオンにして", with: "square.and.line.vertical.and.square.fill")
                            EnableAzooKeyViewImage("initSettingAzooKeySwitchImage-hand")
                            EnableAzooKeyViewText("このアプリを再び開いてください", with: "arrow.turn.down.left")
                            CenterAlignedView{
                                EnableAzooKeyViewButton("追加する", systemName: "plus.circle", style: .emphisized){
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                            EnableAzooKeyViewText("この設定をしないとキーボードが使えません", with: "exclamationmark.triangle.fill")
                            CenterAlignedView{
                                EnableAzooKeyViewButton("閉じる", systemName: "xmark"){
                                    Store.variableSection.requireFirstOpenView = false
                                }
                            }
                        }
                        .onAppear{
                            value.scrollTo(0, anchor: .top)
                        }
                    case .setting:
                        VStack(alignment: .leading, spacing: 20){
                            EnableAzooKeyViewHeader("最初の設定")
                            Divider()
                            EnableAzooKeyViewText("キーボードの種類をお選びください", with: "keyboard")
                            KeyboardLayoutSettingItemView(Store.shared.keyboardTypeSetting, setTogether: true)
                            Divider()
                            EnableAzooKeyViewText("絵文字と顔文字を設定しましょう", with: "face.smiling")
                            AdditionalDictManageViewMain(style: .simple)
                            Divider()
                            EnableAzooKeyViewText("設定は「設定タブ」でいつでも変えられます", with: "gearshape")
                            CenterAlignedView{
                                EnableAzooKeyViewButton("完了", systemName: "checkmark", style: .emphisized){
                                    self.step = .finish
                                }
                            }
                        }
                        .onAppear{
                            value.scrollTo(0, anchor: .top)
                        }

                    case .finish:
                        VStack(alignment: .leading, spacing: 20){
                            EnableAzooKeyViewHeader("azooKeyが使えます！")
                            EnableAzooKeyViewText("準備は完了です！", with: "checkmark")
                            if showDoneMessage{
                                EnableAzooKeyViewText("azooKeyが開かれました！", with: "checkmark")
                                CenterAlignedView{
                                    EnableAzooKeyViewButton("始める", systemName: "arrowshape.turn.up.right.fill", style: .emphisized){
                                        Store.variableSection.requireFirstOpenView = false
                                    }
                                }
                            }else{
                                EnableAzooKeyViewText("キーボードの地球儀ボタンを長押しし、azooKeyを選択してください", with: "globe")
                            }
                            TextField("キーボードを開く", text: $text).textFieldStyle(RoundedBorderTextFieldStyle())
                            EnableAzooKeyViewImage("initSettingGlobeTapImage")
                            EnableAzooKeyViewText("azooKeyをお楽しみください！", with: "star.fill")
                            CenterAlignedView{
                                EnableAzooKeyViewButton("始める", systemName: "arrowshape.turn.up.right.fill", style: .emphisized){
                                    Store.variableSection.requireFirstOpenView = false
                                }
                            }
                        }
                        .onAppear{
                            value.scrollTo(0, anchor: .top)
                        }.onTapGesture {
                            UIApplication.shared.closeKeyboard()
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)){notification in
                            //キーボードが開いた時
                            //参考：https://stackoverflow.com/questions/26153336/how-do-i-find-out-the-current-keyboard-used-on-ios8
                            let currentKeyboardIdentifier = NSArray(array: UITextInputMode.activeInputModes)
                                .filtered(using: NSPredicate(format: "isDisplayed = YES"))
                                .first
                                .flatMap{($0 as? UITextInputMode)?.value(forKey: "identifier") as? String}
                            if currentKeyboardIdentifier == SharedStore.bundleName{
                                showDoneMessage = true
                            }
                        }
                    }
                }
                .id(0)
            }

        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if Store.shared.isKeyboardActivated{
                self.step = .setting
                Store.variableSection.isKeyboardActivated = true
            }
        }

    }
}
