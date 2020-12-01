//
//  RomanCustomKeysImageSlideShow.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/21.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct ImageSlideshowView: View {
    @State private var selection = 0
    private let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    let pictures: [String]
    init(pictures: [String]){
        self.pictures = pictures
    }

    var body: some View {
        HStack{
            ForEach(pictures.indices, id: \.self){i in
                if i == selection{
                    Image(pictures[selection])
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .onReceive(timer){_ in
            self.update()
        }
    }

    func update(){
        print(selection, pictures)
        self.selection = (selection + 1) % pictures.count
    }
}
