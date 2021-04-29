//
//  FallbackLink.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct FallbackLink: View {
    @State private var showAlert = false
    private let title: LocalizedStringKey
    private let url: URL

    init(_ title: LocalizedStringKey, destination: String) {
        self.title = title
        self.url = URL(string: destination)!
    }

    init(_ title: LocalizedStringKey, destination: URL) {
        self.title = title
        self.url = destination
    }

    var body: some View {
        Button("\(systemImage: "arrow.up.forward.square") \(title)") {
            // 外部ブラウザでURLを開く
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("ブラウザを開けませんでした"), message: Text("URLをコピーします。"), dismissButton: .default(Text("OK"), action: {
                UIPasteboard.general.string = url.absoluteString
                self.showAlert = false
            }))
        }
    }
}
