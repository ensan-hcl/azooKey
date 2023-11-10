//
//  TipsVIew.swift
//  MainApp
//
//  Created by ensan on 2020/10/02.
//  Copyright © 2020 ensan. All rights reserved.
//

import KeyboardViews
import SwiftUI

struct TipsTabView: View {
    @EnvironmentObject private var appStates: MainAppStates
    var body: some View {
        NavigationView {
            Form {
                Section("キーボードを使えるようにする") {
                    if !appStates.isKeyboardActivated {
                        Text("キーボードを有効化する")
                            .onTapGesture {
                                appStates.requireFirstOpenView = true
                            }
                    }
                    NavigationLink("入力方法を選ぶ", destination: SelctInputStyleTipsView())
                }
                TipsNewsSection()
                Section("便利な使い方") {
                    let imageColor = Color.blue
                    IconNavigationLink("片手モードを使う", systemImage: "aspectratio", imageColor: imageColor, destination: OneHandedModeTipsView())
                    IconNavigationLink("カーソルを自由に移動する", systemImage: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right", imageColor: imageColor, destination: CursorMoveTipsView())
                    IconNavigationLink("文頭まで一気に消す", systemImage: "xmark", imageColor: imageColor, destination: SmoothDeleteTipsView())
                    IconNavigationLink("漢字を拡大表示する", systemImage: "plus.magnifyingglass", imageColor: imageColor, destination: KanjiLargeTextTipsView())
                    IconNavigationLink("大文字に固定する", systemImage: "capslock.fill", imageColor: imageColor, destination: CapsLockTipsView())
                    IconNavigationLink("タイムスタンプを使う", systemImage: "clock", imageColor: imageColor, destination: TemplateSettingTipsView())
                    IconNavigationLink("キーをカスタマイズする", systemImage: "hammer", imageColor: imageColor, destination: CustomKeyTipsView())
                    IconNavigationLink("フルアクセスが必要な機能を使う", systemImage: "lock.open", imageColor: imageColor, destination: FullAccessTipsView())
                    if SemiStaticStates.shared.hasFullAccess {
                        IconNavigationLink("「ほかのAppからペースト」について", systemImage: "doc.on.clipboard", imageColor: imageColor, destination: PasteFromOtherAppsPermissionTipsView())
                    }
                }

                Section("困ったときは") {
                    NavigationLink("インストール直後、特定のアプリでキーボードが開かない", destination: KeyboardBehaviorIssueAfterInstallTipsView())
                    NavigationLink("特定のアプリケーションで入力がおかしくなる", destination: UseMarkedTextTipsView())
                    NavigationLink("絵文字や顔文字の変換候補を表示したい", destination: EmojiKaomojiTipsView())
                    NavigationLink("バグの報告や機能のリクエストをしたい", destination: ContactView())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HeaderLogoView()
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
