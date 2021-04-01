//
//  ThemeShareView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/11.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

final class ShareImage {
    private(set) var image: UIImage?

    func setImage(_ uiImage: UIImage?) {
        if let uiImage = uiImage {
            self.image = uiImage
        }
    }
}

struct ThemeShareView: View {
    private let theme: ThemeData
    private let dismissProcess: () -> Void
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(theme: ThemeData, shareImage: ShareImage, dismissProcess: @escaping () -> Void) {
        self.theme = theme
        self.dismissProcess = dismissProcess
        self.shareImage = shareImage
    }
    @State private var showActivityView: Bool = false
    // キャプチャ用
    @State private var captureRect: CGRect = .zero
    private var shareImage: ShareImage

    var body: some View {
        VStack {
            Text("着せ替えが完成しました🎉")
                .font(.title)
                .bold()
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                shareImage.setImage(UIApplication.shared.windows[0].rootViewController?.view!.getImage(rect: self.captureRect))
                showActivityView = true
            }label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("シェアする")
                }
                .font(Font.body.bold())
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 3).foregroundColor(.blue))
                .padding()
            }
            KeyboardPreview(theme: theme, scale: 0.9)
                .background(RectangleGetter(rect: $captureRect))
            Button {
                self.dismissProcess()
            }label: {
                HStack {
                    Image(systemName: "xmark")
                    Text("閉じる")
                }
                .font(Font.body.bold())
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 3).foregroundColor(.blue))
                .padding()
            }

        }.sheet(isPresented: self.$showActivityView) {
            if let image = shareImage.image {
                ActivityView(
                    activityItems: [TextActivityItem("azooKeyで着せ替えました！", hashtags: ["#azooKey"], links: ["https://apps.apple.com/jp/app/azookey/id1542709230"]), ImageActivityItem(image)],
                    applicationActivities: nil
                )
            }
        }

    }

    private func shareOnTwitter() {
        let parameters = [
            "text": "azooKeyで着せ替えました！",
            "url": "https://apps.apple.com/jp/app/azookey/id1542709230",
            "hashtags": "azooKey",
            "related": "azooKey_dev"
        ]
        // 作成したテキストをエンコード
        let encodedText = parameters.map {"\($0.key)=\($0.value)"}.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        // エンコードしたテキストをURLに繋げ、URLを開いてツイート画面を表示させる
        if let encodedText = encodedText,
           let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {

    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {
        // Nothing to do
    }
}

private final class TextActivityItem: NSObject, UIActivityItemSource {
    let text: String
    let hashtags: [String]
    let links: [String]

    init(_ text: String, hashtags: [String] = [], links: [String] = []) {
        self.text = text
        self.links = links
        self.hashtags = hashtags
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == .postToTwitter {
            return text + " " + hashtags.joined(separator: " ") + "\n" + links.joined(separator: "\n")
        }
        return text + "\n" + links.joined(separator: "\n")
    }
}

private final class ImageActivityItem: NSObject, UIActivityItemSource {

    var image: UIImage?
    init(_ image: UIImage?) {
        self.image = image
    }

    // 実際に渡す
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }

    // 仮に渡す
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image ?? UIImage()
    }
}
