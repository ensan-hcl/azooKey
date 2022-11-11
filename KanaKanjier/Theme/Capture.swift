//
//  Capture.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/08.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

extension UIView {
    func getImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
