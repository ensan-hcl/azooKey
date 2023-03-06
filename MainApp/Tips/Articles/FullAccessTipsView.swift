//
//  FullAccessTipsView.swift
//  azooKey
//
//  Created by ensan on 2023/03/06.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

struct FullAccessTipsView: View {
    var body: some View {
        TipsContentView("フルアクセスについて") {
            TipsContentParagraph {
                Text("azooKeyは、キーボードの振動フィードバックや、キーボードからのペーストを実現するために、フルアクセスの許可が必要です。フルアクセスを許可していただくことで、これらの機能が使用できます。")
            }
            TipsContentParagraph {
                Text("以下は、フルアクセスをオンにすることで利用できる設定項目です。フルアクセスを必要とする機能は、すべてデフォルトで無効になっているため、フルアクセスを許可しただけでキーボードの振る舞いが変わることはありません。")
                Text("また、フルアクセスをオンにしたあとでも、いつでもフルアクセスをオフにすることができます。")
            }
            BoolSettingView(.enableKeyHaptics)
            BoolSettingView(.enablePasteButton)
            BoolSettingView(.enableClipboardHistoryManagerTab)

            TipsContentParagraph {
                Text("フルアクセスを許可しなくても、キーボードは完全に動作します。上記の機能を使わない場合は、オンにしないことを強くおすすめします。")
            }
            
            TipsContentParagraph {
                Text("フルアクセスを有効化する際、以下のような警告が表示されますが、すべてのキーボードアプリで共通して表示されている警告です。")
                TipsImage("fullAccessAlert")
                Text("azooKeyは安全なキーボードアプリであり、ユーザの明示的な同意なく、個人情報を外部に送信したり、保存したりすることはありません。")
                Text("なお、azooKeyはオープンソースであり、誰もが実装を確認することができます。")
            }
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Button(Store.shared.isFullAccessEnabled
                       ? "フルアクセスをオフにする（設定アプリが開きます）"
                       : "フルアクセスをオンにする（設定アプリが開きます）") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            Section("参考情報") {
                FallbackLink("azooKeyのソースコードを閲覧する", destination: URL(string: "https://github.com/ensan-hcl/azooKey/tree/main")!)
                FallbackLink("Configuring open access for a custom keyboard | Apple Developer Documentation (英語)", destination: URL(string: "https://developer.apple.com/documentation/uikit/keyboards_and_input/creating_a_custom_keyboard/configuring_open_access_for_a_custom_keyboard")!)
            }
        }
    }
}
