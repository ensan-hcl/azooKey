//
//  TemporalMessageView.swift
//  azooKey
//
//  Created by ensan on 2023/03/30.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation
import SwiftUI

@available(iOS 15, *)
struct TemporalMessageView: View {
    let message: TemporalMessage
    let onDismiss: () -> Void
    @EnvironmentObject private var variableStates: VariableStates
    @Environment(\.userActionManager) private var action

    @ViewBuilder
    private var core: some View {
        switch message.dismissCondition {
        case .auto:
            Text(message.title)
                .bold()
                .foregroundColor(.black)
                .onAppear {
                    Task {
                        // 1.5秒待機してからdismissを実行する
                        try await Task.sleep(nanoseconds: 1_500_000_000)
                        self.onDismiss()
                    }
                }
        case .ok:
            VStack {
                Text(message.title)
                    .bold()
                    .foregroundColor(.black)
                Button("OK", action: onDismiss)
            }
        }
    }

    var body: some View {
        core
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.black.opacity(0.5)
            }
    }
}
