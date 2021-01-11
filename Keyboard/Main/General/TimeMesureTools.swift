//
//  TimeMesureTools.swift
//  Keyboard
//
//  Created by β α on 2020/12/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

final class TimeMesureTools{
    private static var start: Date?

    static func startTimeMesure(){
        #if DEBUG
        Self.start = Date()
        #endif
    }

    static func endTimeMesure(_ message: String = ""){
        #if DEBUG
        debug(message, -(Self.start?.timeIntervalSinceNow ?? .nan))
        Self.start = nil
        #endif
    }

    static func endAndStart(_ message: String = ""){
        #if DEBUG
        Self.endTimeMesure(message)
        Self.startTimeMesure()
        #endif
    }

}
