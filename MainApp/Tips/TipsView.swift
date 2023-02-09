//
//  TipsVIew.swift
//  MainApp
//
//  Created by ensan on 2020/10/02.
//  Copyright © 2020 ensan. All rights reserved.
//

import SwiftUI

struct TipsTabView: View {
    @ObservedObject private var storeVariableSection = Store.variableSection
    @State private var isTop = true
    @AppStorage("read_article_iOS14_service_termination") private var readArticle_iOS14_service_termination = false

    var body: some View {
        VStack {
            if isTop {
                HeaderLogoView()
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
                    if #unavailable(iOS 15) {
                        Section(header: Text("お知らせ")) {
                            HStack {
                                if !readArticle_iOS14_service_termination {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                NavigationLink("iOS14のサポートを終了します", destination: iOS14TerminationNewsView($readArticle_iOS14_service_termination))
                            }
                        }
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
                        NavigationLink("インストール直後、特定のアプリでキーボードが開かない", destination: KeyboardBehaviorIssueAfterInstallTipsView())
                        NavigationLink("特定のアプリケーションで入力がおかしくなる", destination: UseMarkedTextTipsView())
                        NavigationLink("端末の文字サイズ設定が反映されない", destination: DynamicTypeSettingFailureTipsView())
                        NavigationLink("絵文字や顔文字の変換候補を表示したい", destination: EmojiKaomojiTipsView())
                        NavigationLink("バグの報告や機能のリクエストをしたい", destination: ContactView())
                    }
                }
                .navigationBarTitle(Text("使い方"), displayMode: .large)
            }
            .navigationViewStyle(.stack)
        }
    }
}
