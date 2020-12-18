//
//  TimeMesureTools.swift
//  Keyboard
//
//  Created by β α on 2020/12/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

class TimeMesureTools{
    private static var start: Date?

    static func startTimeMesure(){
        Self.start = Date()
    }

    static func endTimeMesure(_ message: String = ""){
        debug(message, -(Self.start?.timeIntervalSinceNow ?? .nan))
        Self.start = nil
    }

    static func endAndStart(_ message: String = ""){
        Self.endTimeMesure(message)
        Self.startTimeMesure()
    }

}
