//
//  DesignLogic.swift
//  Keyboard
//
//  Created by β α on 2021/02/05.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum KeyboardOrientation{
    case vertical       //width<height
    case horizontal     //height<width
}

struct DesignLogic{
    static func keyViewSize(keyboardLayout: KeyboardLayout, orientation: KeyboardOrientation, screenWidth: CGFloat) -> CGSize {
        let interface = UIDevice.current.userInterfaceIdiom
        switch (keyboardLayout, orientation){
        case (.flick, .vertical):
            if interface == .pad{
                return CGSize(width: screenWidth/5.6, height: screenWidth/12)
            }
            return CGSize(width: screenWidth/5.6, height: screenWidth/8)
        case (.flick, .horizontal):
            if interface == .pad{
                return CGSize(width: screenWidth/9, height: screenWidth/22)
            }
            return CGSize(width: screenWidth/9, height: screenWidth/18)
        case (.qwerty, .vertical):
            if interface == .pad{
                return CGSize(width: screenWidth/12.2, height: screenWidth/12)
            }
            return CGSize(width: screenWidth/12.2, height: screenWidth/8.3)
        case (.qwerty, .horizontal):
            return CGSize(width: screenWidth/13, height: screenWidth/20)
        }
    }
}
