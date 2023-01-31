//
//  CIDData.swift
//  KanaKanjier
//
//  Created by β α on 2022/05/05.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

enum CIDData {
    static var totalCount: Int {
        1319
    }
    case BOS
    case 記号
    case 係助詞ハ
    case 助動詞デス基本形
    case 一般名詞
    case 固有名詞
    case 人名一般
    case 地名一般
    case 数
    case EOS
    var cid: Int {
        switch self {
        case .BOS: return 0
        case .記号: return 5
        case .係助詞ハ: return 261
        case .助動詞デス基本形: return 460
        case .一般名詞: return 1285
        case .固有名詞: return 1288
        case .人名一般: return 1289
        case .地名一般: return 1293
        case .数: return 1295
        case .EOS: return 1316
        }
    }
}
