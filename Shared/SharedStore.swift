//
//  SharedStore.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

struct SharedStore{
    static let bundleName = "DevEn3.azooKey.keyboard"
    static let appGroupKey = "group.com.azooKey.keyboard"
}

func debug(_ items: Any...){
    #if DEBUG
        print(items)
    #endif
}
