//
//  TipsNewsSection.swift
//  azooKey
//
//  Created by miwa on 2023/11/11.
//  Copyright © 2023 DevEn3. All rights reserved.
//

import SwiftUI

struct TipsNewsSection: View {
    @AppStorage("read_article_iOS15_service_termination") private var readArticle_iOS15_service_termination = false
    @EnvironmentObject private var appStates: MainAppStates

    @MainActor
    private var needUseShiftKeySettingNews: Bool {
        appStates.englishLayout == .qwerty
    }

    @MainActor
    private var neadUseNextCandidateKeySettingNews: Bool {
        if case .custard = appStates.japaneseLayout, case .custard = appStates.englishLayout {
            false
        } else {
            true
        }
    }

    var iOS15TerminationNewsViewLabel: some View {
        Label(
            title: {
                Text("iOS15のサポートを終了します")
            },
            icon: {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        )
    }
    var body: some View {
        if #unavailable(iOS 16) {
            Section("お知らせ") {
                NavigationLink(destination: iOS15TerminationNewsView($readArticle_iOS15_service_termination)) {
                    if !readArticle_iOS15_service_termination {
                        iOS15TerminationNewsViewLabel
                    } else {
                        iOS15TerminationNewsViewLabel.labelStyle(.titleOnly)
                    }
                }
            }
        }
        Section("新機能") {
            if needUseShiftKeySettingNews {
                IconNavigationLink("シフトキーが使えるようになりました！", systemImage: "shift", imageColor: .orange, destination: UseShiftKeyNews())
            }
            if neadUseNextCandidateKeySettingNews {
                IconNavigationLink("次候補キーが使えるようになりました！", systemImage: "sparkles", imageColor: .orange, destination: UseNextCandidateKeyNews())
            }
            IconNavigationLink("連絡先情報を読み込めるようになりました！", systemImage: "person.text.rectangle", imageColor: .orange, destination: UseContactInfoSettingNews())
        }
    }
}
