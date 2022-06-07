//
//  EnableAzooKeyViewComponent.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct EnableAzooKeyViewHeader: View {
    private let text: LocalizedStringKey
    init(_ text: LocalizedStringKey) {
        self.text = text
    }

    var body: some View {
        CenterAlignedView {
            HStack {
                AzooKeyIcon(fontSize: 30, relativeTo: .title)
                Text(text)
                    .font(.title.bold())
            }
            .multilineTextAlignment(.leading)
            .padding(.vertical)
        }
    }
}

struct EnableAzooKeyViewText: View {
    private let text: LocalizedStringKey
    private let systemName: String
    init(_ text: LocalizedStringKey, with systemName: String) {
        self.text = text
        self.systemName = systemName
    }

    var body: some View {
        HStack {
            if let systemName {
                Image(systemName: systemName)
            }
            Text(text)
        }
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.leading)
    }
}

struct EnableAzooKeyViewButton: View {
    enum Style {
        case emphasized, destructive
    }
    private let text: LocalizedStringKey
    private let systemName: String?
    private let style: Style
    private let action: () -> Void

    init(_ text: LocalizedStringKey, systemName: String? = nil, style: Style = .emphasized, action: @escaping () -> Void) {
        self.text = text
        self.systemName = systemName
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if let systemName {
                    Image(systemName: systemName)
                }
                Text(text)
            }
            .foregroundColor(.white)
        }
        .buttonStyle(LargeButtonStyle(backgroundColor: self.style == .emphasized ? .blue : .red))
    }
}

struct EnableAzooKeyViewImage: View {
    private let identifier: String
    init(_ identifier: String) {
        self.identifier = identifier
    }

    var body: some View {
        Image(identifier)
            .resizable()
            .scaledToFit()
            .cornerRadius(2)
    }
}
