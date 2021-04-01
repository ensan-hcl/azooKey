//
//  extension CGPoint.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
extension CGPoint {
    @inlinable
    func distance(to point: CGPoint) -> CGFloat {
        let dx: CGFloat = x-point.x
        let dy: CGFloat = y-point.y
        let d2: CGFloat = dx*dx + dy*dy
        return sqrt(d2)
    }

    func direction(to point: CGPoint) -> FlickDirection {
        let x: CGFloat = point.x - self.x
        let y: CGFloat = point.y - self.y

        if x>0 && abs(y) < x {
            return FlickDirection.right
        }
        if x<0 && abs(y) < -x {
            return FlickDirection.left
        }
        // CGは座標が下の方が大きい
        if y>0 && abs(x) < y {
            return FlickDirection.bottom
        }
        if y<0 && abs(x) < -y {
            return FlickDirection.top
        }
        return FlickDirection.top
    }

}
