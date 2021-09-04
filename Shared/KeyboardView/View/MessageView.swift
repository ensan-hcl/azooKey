//
//  MessageView.swift
//  Keyboard
//
//  Created by β α on 2021/01/29.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

struct MessageView: View {
    private let data: MessageData
    @Binding private var manager: MessageManager

    init(data: MessageData, manager: Binding<MessageManager>) {
        self.data = data
        self._manager = manager
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: SemiStaticStates.shared.screenWidth*0.8, height: Design.keyboardScreenHeight*0.8)
                .overlay(VStack {
                    Text(data.title)
                        .font(.title.bold())
                        .padding(.top)
                        .foregroundColor(.black)
                    ScrollView {
                        Text(data.description)
                            .padding(.horizontal)
                            .foregroundColor(.black)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Divider()
                    HStack {
                        switch data.leftsideButton {
                        case let .details(urlString):
                            HStack {
                                Spacer()
                                Button("詳細") {
                                    VariableStates.shared.action.registerAction(.openApp(urlString))
                                }
                                Spacer()
                                Divider()
                            }
                        case .later:
                            HStack {
                                Spacer()
                                Button("後で") {
                                    self.manager.done(data.id)
                                }
                                Spacer()
                                Divider()
                            }
                        }
                        switch data.rightsideButton {
                        case let .openContainer(text):
                            HStack {
                                Spacer()
                                Button {
                                    VariableStates.shared.action.registerAction(.openApp("azooKey://"))
                                }label: {
                                    Text(text).bold()
                                }
                                Spacer()
                            }
                        case .OK:
                            HStack {
                                Spacer()
                                Button {
                                    self.manager.done(data.id)
                                }label: {
                                    Text("了解").bold()
                                }
                                Spacer()
                            }
                        }
                    }.padding(.bottom)
                })
        }
    }

}
