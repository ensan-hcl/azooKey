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
        VStack {
            if isTop {
                HeaderIconView()
            }
            NavigationView {
                Form {
                    Section(header: Text("キーボードを使えるようにする")) {
                        if !storeVariableSection.isKeyboardActivated {
                            Text("キーボードを有効化する")
                                .onTapGesture {
                                    Store.variableSection.requireFirstOpenView = true
                                }
                        }
                        NavigationLink("入力方法を選ぶ", destination: SelctInputStyleTipsView())
                    }
                    
                    Section(header: Text("便利な使い方")) {
                        NavigationLink("片手モードを使う", destination: OneHandedModeTipsView())
                        NavigationLink("カーソルを自由に移動する", destination: CursorMoveTipsView())
                        NavigationLink("文頭まで一気に消す", destination: SmoothDeleteTipsView())
                        NavigationLink("漢字を拡大表示する", destination: KanjiLargeTextTipsView())
                        NavigationLink("大文字に固定する", destination: CapsLockTipsView())
                        NavigationLink("タイムスタンプを使う", destination: TemplateSettingTipsView())
                        NavigationLink("キーをカスタマイズする", destination: CustomKeyTipsView())
                    }
                    
                    Section(header: Text("困ったときは")) {
                        NavigationLink("端末の文字サイズ設定が反映されない", destination: DynamicTypeSettingFailureTipsView())
                        NavigationLink("絵文字や顔文字の変換候補を表示したい", destination: EmojiKaomojiTipsView())
                        NavigationLink("バグの報告や機能のリクエストをしたい", destination: ContactView())
                    }
                }
                .navigationBarTitle(Text("使い方"), displayMode: .large)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
