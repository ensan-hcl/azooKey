//
//  ManageCustardView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/22.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct ManageCustardView: View {
    var body: some View {
        Form{
            Section(header: Text("作る")){
                
            }
            Section(header: Text("読み込む")){
                Text("カスタムタブファイルの読み込み")
                    VStack{
                        Text("カスタムタブをファイルとして外部で作成し、azooKeyに読み込むことができます。より高機能なタブの作成が可能です。詳しくは以下をご覧ください。")
                        FallbackLink("カスタムタブファイルの作り方", destination: "https://google.com")
                    }
                }

        }
        .navigationBarTitle(Text("カスタムタブの管理"), displayMode: .inline)

    }
}
