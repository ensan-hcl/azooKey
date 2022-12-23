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
        if let uiImage {
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

    @ViewBuilder private var keyboardPreview: some View {
        KeyboardPreview(theme: theme, scale: 0.9)
    }
    var body: some View {
        VStack {
            Text("着せ替えが完成しました🎉")
                .font(.title.bold())
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                if #available(iOS 16, *) {
                    let renderer = ImageRenderer(content: keyboardPreview)
                    renderer.scale = 3.0
                    if let image = renderer.uiImage {
                        shareImage.setImage(image)
                    }
                } else {
                    shareImage.setImage(keyboardPreview.snapshot())
                }
                showActivityView = true
            } label: {
                Label("シェアする", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(ShareButtonStyle())
            keyboardPreview
            Button {
                self.dismissProcess()
            } label: {
                Label("閉じる", systemImage: "xmark")
            }
            .buttonStyle(ShareButtonStyle())
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
        if let encodedText,
           let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {

    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        UIActivityViewController(
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
        NSObject()
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
        image
    }

    // 仮に渡す
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image ?? UIImage()
    }
}

private struct ShareButtonStyle: ButtonStyle {
    @ViewBuilder func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.body.bold())
            .foregroundColor(.white)
            .padding()
            .background(RoundedRectangle(cornerRadius: 3).foregroundColor(.blue))
            .padding()
    }
}

private extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
