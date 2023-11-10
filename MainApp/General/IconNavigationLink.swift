//
//  IconNavigationLink.swift
//  azooKey
//
//  Created by miwa on 2023/11/11.
//  Copyright © 2023 DevEn3. All rights reserved.
//

import SwiftUI

struct IconNavigationLink<Destination: View>: View {
    init(_ titleKey: LocalizedStringKey, systemImage: String, imageColor: Color? = nil, destination: Destination) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.imageColor = imageColor
        self.destination = destination
    }
    
    var titleKey: LocalizedStringKey
    var systemImage: String
    var imageColor: Color?
    var destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            Label(
            title: {
                Text(titleKey)
            },
            icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(imageColor ?? .primary)
                    .font(.caption)
            })
        }
    }
}
