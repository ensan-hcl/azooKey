//
//  AboutFullAccessView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct AboutFullAccesView: View {
    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Text("azooKeyは現在フルアクセスなしで全機能をご利用いただけます。")
                Text("今後、キーボード内での通信や、3DTouchなどの機能を追加する場合、フルアクセスが必要となる場合があります。")
                Spacer()
            }
        }.navigationBarTitle(Text("フルアクセスについて"), displayMode: .inline)
    }
}
