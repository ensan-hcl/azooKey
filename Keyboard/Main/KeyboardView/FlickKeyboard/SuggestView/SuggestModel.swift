//
//  SuggestModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/05.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum SuggestModelKeyType{
    case normal
    case enter
    case kogaki
}

struct SuggestModel{
    var variableSection = SuggestModelVariableSection()
    let _flickModels: [FlickDirection: FlickedKeyModel]
    var flickModels: [FlickDirection: FlickedKeyModel] {
        switch self.keyType{
        case .normal, .enter:
            return _flickModels
        case .kogaki:
            return Store.shared.userSetting.kogakiFlickSetting
        }
    }
    
    let keyType: SuggestModelKeyType
    
    init(_ flickModels: [FlickDirection: FlickedKeyModel] = [:], keyType: SuggestModelKeyType = .normal){
        self._flickModels = flickModels
        self.keyType = keyType
    }
    
    func setSuggestState(_ state: SuggestState){
        self.variableSection.suggestState = state
    }
    
    var keySize: CGSize {
        switch self.keyType{
        case .normal, .kogaki:
            return Store.shared.design.keyViewSize
        case .enter:
            return Store.shared.design.flickEnterKeySize
        }
    }


}

final class SuggestModelVariableSection: ObservableObject{
    @Published var suggestState: SuggestState = .nothing
    deinit{
        print("deinit SuggestModelVariableSection")
    }
}

