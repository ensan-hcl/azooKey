//
//  KeyboardModelProtocol.swift
//  Keyboard
//
//  Created by β α on 2020/09/23.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
protocol KeyboardModelProtocol {
    func setTabState(state: TabState)
    func expandResultView(_ results: [ResultData])
    func collapseResultView()
    var resultModel: ResultModel {get}
    var expandedResultModel: ExpandedResultModel {get}
    var enterKeyModel: EnterKeyModelProtocol {get}
    var tabState: TabState {get}

}

protocol EnterKeyModelProtocol {
    func setKeyState(new state: EnterKeyState)
}
