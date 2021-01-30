//
//  MessageView.swift
//  Keyboard
//
//  Created by β α on 2021/01/29.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

struct MessageView: View {
    let data: MessageData
    @Binding private var manager: MessageManager

    init(data: MessageData, manager: Binding<MessageManager>){
        self.data = data
        self._manager = manager
    }

    var body: some View {
        ZStack{
            Color.black.opacity(0.5)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: Design.shared.keyboardWidth*0.8, height: Design.shared.keyboardHeight*0.8)
                .overlay(VStack{
                    Text(data.title)
                        .font(.title)
                        .bold()
                        .padding(.top)
                        .foregroundColor(.black)
                    ScrollView{
                        Text(data.description)
                            .padding(.horizontal)
                            .foregroundColor(.black)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Divider()
                    HStack{
                        if let urlString = data.detailsURL{
                            HStack{
                                Spacer()
                                Button{
                                    Store.shared.action.openApp(scheme: urlString)
                                }label: {
                                    Text("詳細")
                                }
                                Spacer()
                            }
                            Divider()
                        }
                        if data.needOpenContainer{
                            HStack{
                                Spacer()
                                Button{
                                    Store.shared.action.openApp(scheme: "azooKey://")
                                }label: {
                                    Text("更新").bold()
                                }
                                Spacer()
                            }
                        }else{
                            HStack{
                                Spacer()
                                Button{
                                    //FIXME: このコードは動作しない。
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
