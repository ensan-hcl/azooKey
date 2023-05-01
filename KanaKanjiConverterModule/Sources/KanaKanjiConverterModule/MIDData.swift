//
//  MIDData.swift
//  azooKey
//
//  Created by ensan on 2022/10/25.
//  Copyright © 2022 ensan. All rights reserved.
//

import Foundation

public enum MIDData {
    static var totalCount: Int {
        503
    }
    case BOS
    case EOS
    case 一般
    case 数
    case 英単語
    case 小さい数字
    case 年
    case 絵文字
    public var mid: Int {
        switch self {
        case .BOS: return 500
        case .EOS: return 500
        case .一般: return 501
        case .年: return 237
        case .英単語: return 40
        case .数: return 452
        case .小さい数字: return 361
        case .絵文字: return 502
        }
    }
}
