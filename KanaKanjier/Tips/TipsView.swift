//
//  TipsVIew.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/02.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct TipsTabView: View {
    @ObservedObject private var storeVariableSection = Store.variableSection
    @State private var isTop = true
    
    var body: some View {
        VStack{
            if isTop{
                HeaderIconView()
            }
            NavigationView {
                Form {
                    Section(header: Text("キーボードを使えるようにする")){
                        if !storeVariableSection.isKeyboardActivated{
                            Text("キーボードを有効化する")
                                .onTapGesture {
                                    Store.variableSection.requireFirstOpenView = true
                                }
                        }
                        NavigationLink(destination: SelctInputStyleTipsView()) {
                            Text("入力方法を選ぶ")
                        }
                    }

                    Section(header: Text("便利な使い方")){
                        NavigationLink(destination: OneHandedModeTipsView()) {
                            Text("片手モードを使う")
                        }
                        NavigationLink(destination: CursorMoveTipsView()) {
                            Text("カーソルを自由に移動する")
                        }
                        NavigationLink(destination: SmoothDeleteTipsView()) {
                            Text("文頭まで一気に消す")
                        }
                        NavigationLink(destination: KanjiLargeTextTipsView()) {
                            Text("漢字を拡大表示する")
                        }
                        NavigationLink(destination: CapsLockTipsView()) {
                            Text("大文字に固定する")
                        }
                        NavigationLink(destination: TemplateSettingTipsView()) {
                            Text("タイムスタンプを使う")
                        }
                        NavigationLink(destination: CustomKeyTipsView()) {
                            Text("キーをカスタマイズする")
                        }
                    }

                    Section(header: Text("困ったときは")){
                        NavigationLink(destination: DynamicTypeSettingFailureTipsView()) {
                            Text("端末の文字サイズ設定が反映されない")
                        }
                        NavigationLink(destination: EmojiKaomojiTipsView()) {
                            Text("絵文字や顔文字の変換候補を表示したい")
                        }
                        NavigationLink(destination: ContactView()) {
                            Text("バグの報告や機能のリクエストをしたい")
                        }

                    }
                }
                .navigationBarTitle(Text("使い方"), displayMode: .large)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
