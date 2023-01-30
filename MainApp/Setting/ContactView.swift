//
//  ContactView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct ContactView: View {
    var body: some View {
        Form {
            Section {
                Text("お問い合わせ内容を選んでください。ブラウザでGoogle Formが開きます。")
            }
            Section {
                FallbackLink("不具合報告", destination: URL(string: "https://forms.gle/kkpBLbBySwGNDLzH9")!)
                FallbackLink("機能の改善・追加", destination: URL(string: "https://forms.gle/4PrdgaC2mZEaYed76")!)
                FallbackLink("変換候補の追加", destination: URL(string: "https://forms.gle/EG4sxm2t6RxRTyqV6")!)
            }
            Section {
                FallbackLink("その他の質問・連絡など", destination: URL(string: "mailto:azooKey.dev@gmail.com")!, icon: .mail)
            }
        }
        .multilineTextAlignment(.leading)
        .navigationBarTitle(Text("お問い合わせ"), displayMode: .inline)

    }
}
