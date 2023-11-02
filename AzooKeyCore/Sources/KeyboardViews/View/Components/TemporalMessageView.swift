//
//  TemporalMessageView.swift
//  azooKey
//
//  Created by ensan on 2023/03/30.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct TemporalMessageView: View {
    init(message: TemporalMessage, isPresented: Binding<Bool>) {
        self.message = message
        self._isPresented = isPresented
    }

    private let message: TemporalMessage
    @Binding private var isPresented: Bool

    @MainActor
    @ViewBuilder
    private var core: some View {
        switch message.dismissCondition {
        case .auto:
            Text(message.title)
                .bold()
                .foregroundStyle(.black)
                .task {
                    // 1.5秒待機してからdismissを実行する
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    self.dismiss()
                }
        case .ok:
            VStack {
                Text(message.title)
                    .bold()
                    .foregroundStyle(.black)
                Button("OK", action: self.dismiss)
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

    private func dismiss() {
        withAnimation(.easeIn) {
            self.isPresented = false
        }
    }
}

#Preview {
    TemporalMessageView(message: .doneReportWrongConversion, isPresented: .init(get: { true }, set: { _ in }))
}
