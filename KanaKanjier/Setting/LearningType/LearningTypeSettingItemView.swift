//
//  LearningTypeSettingItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct LearningTypeSettingView: View {
    @State private var selection: LearningType
    init() {
        self._selection = .init(initialValue: LearningTypeSetting.value)
    }

    private var learningType: Binding<LearningType> {
        Binding(
            get: {
                return selection
            },
            set: { newValue in
                selection = newValue
                LearningTypeSetting.value = newValue
            }
        )
    }

    var body: some View {
        HStack {
            Text(LearningTypeSetting.title)
            Spacer()
            Picker(selection: $selection, label: Text("")) {
                ForEach(0 ..< LearningType.allCases.count, id: \.self) { i in
                    Text(LearningType.allCases[i].string).tag(LearningType.allCases[i])
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
