//
//  RefreshableView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/10.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

struct RefreshableView<Content: View>: View {
    private var refresh: Bool
    private let content: () -> Content

    init(refreshValue: Bool, @ViewBuilder _ content: @escaping () -> Content){
        self.content = content
        self.refresh = refreshValue
    }

    var body: some View {
        if refresh{
            content()
        }else{
            content()
        }
    }
}
