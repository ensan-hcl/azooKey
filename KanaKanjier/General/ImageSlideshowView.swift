//
//  ImageSlideShow.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/21.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct ImageSlideshowView: View {
    @State private var selection = 0
    private let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    private let pictures: [String]
    init(pictures: [String]) {
        self.pictures = pictures
    }
    
    var body: some View {
        CenterAlignedView {
            HStack {
                ForEach(pictures.indices, id: \.self) {i in
                    if i == selection {
                        
                        Image(pictures[selection])
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: Store.shared.imageMaximumWidth)
                    }
                }
            }
            .onReceive(timer) {_ in
                self.update()
            }
        }
    }
    
    private func update() {
        self.selection = (selection + 1) % pictures.count
    }
}
