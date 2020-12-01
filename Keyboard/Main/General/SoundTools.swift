//
//  SoundTools.swift
//  Keyboard
//
//  Created by β α on 2020/11/26.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import AudioToolbox

struct SoundTools{
    //使えそうな音
    /*
     1103: 高いクリック音
     1104: 純正クリック音
     1105: 木の音っぽいクリック音
     1130: 空洞のある木を叩いたような音
     1131: 電話のキーのような音
     1261: なんかいい感じ
     1306: 純正クリック音
     1522: なんかいい感じ。
     1420: なんかいい感じ。
     1318まで試した
     */
    static func click(){
        if Store.shared.userSetting.soundSetting{
            AudioServicesPlaySystemSound(1104)
        }
    }

    static func tabOrOtherKey(){
        if Store.shared.userSetting.soundSetting{
            AudioServicesPlaySystemSound(1156)
        }
    }

    static func delete(){
        if Store.shared.userSetting.soundSetting{
            AudioServicesPlaySystemSound(1155)
        }
    }

    static func smoothDelete(){
        if Store.shared.userSetting.soundSetting{
            AudioServicesPlaySystemSound(1105)
        }
    }
}
