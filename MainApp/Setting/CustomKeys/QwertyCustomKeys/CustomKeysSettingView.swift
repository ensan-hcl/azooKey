//
//  CustomKeysSettingView.swift
//  CustomKeysSettingView
//
//  Created by ensan on 2021/07/24.
//  Copyright © 2021 ensan. All rights reserved.
//

import SwiftUI

struct CustomKeysSettingView: View {
    var body: some View {
        ImageSlideshowView(pictures: ["flickCustomKeySetting0", "flickCustomKeySetting1", "flickCustomKeySetting2"])
            .listRowSeparator(.hidden, edges: .bottom)
        Text("「小ﾞﾟ」キーと「､｡?!」キーで入力する文字をカスタマイズすることができます。")
        NavigationLink("設定する", destination: FlickCustomKeysSettingSelectView())
            .foregroundColor(.accentColor)
            .listRowSeparator(.visible, edges: .all)
        ImageSlideshowView(pictures: ["qwertyCustomKeySetting0", "qwertyCustomKeySetting1", "qwertyCustomKeySetting2"])
            .listRowSeparator(.hidden, edges: .bottom)
        Text("数字タブの青枠部分に好きな記号や文字を割り当てられます。")
        NavigationLink("設定する", destination: QwertyCustomKeysSettingView(.numberTabCustomKeys))
            .foregroundColor(.accentColor)
            .listRowSeparator(.visible, edges: .all)
    }
}
