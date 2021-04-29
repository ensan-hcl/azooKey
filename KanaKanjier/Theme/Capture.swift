//
//  Capture.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/08.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct RectangleGetter: View {
    @Binding private var rect: CGRect
    
    init(rect: Binding<CGRect>) {
        self._rect = rect
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.createView(proxy: geometry)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }
        return Rectangle().fill(Color.clear)
    }
}

extension UIView {
    func getImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
