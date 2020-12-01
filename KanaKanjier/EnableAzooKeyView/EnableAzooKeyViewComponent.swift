//
//  EnableAzooKeyViewComponent.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct EnableAzooKeyViewHeader: View {
    let text: String
    init(_ text: String){
        self.text = text
    }

    var body: some View {
        CenterAlignedView{
            HStack{
                if let font = Store.shared.iconFont(30, relativeTo: .title){
                    Text("1")
                        .font(font)
                }
                Text(text)
                    .font(Font.system(.title))
            }
            .multilineTextAlignment(.leading)
            .padding(.vertical)
        }
    }
}

struct EnableAzooKeyViewText: View {
    let text: String
    let systemName: String
    init(_ text: String, with systemName: String){
        self.text = text
        self.systemName = systemName
    }

    var body: some View {
        HStack{
            if let systemName = systemName{
                Image(systemName: systemName)
            }
            Text(text)
        }
        .multilineTextAlignment(.leading)
    }
}

struct EnableAzooKeyViewButton: View {
    enum Style{
        case emphisized, normal
    }
    let text: String
    let systemName: String?
    let style: Style
    let action: () -> Void
    
    init(_ text: String, systemName: String? = nil, style: Style = .normal, action: @escaping () -> Void){
        self.text = text
        self.systemName = systemName
        self.style = style
        self.action = action
    }

    var body: some View {
        let button = Button(action: {
            self.action()
        }, label: {
            if let systemName = systemName{
                Image(systemName: systemName)
            }
            Text(text)
        })
        .padding()
        .cornerRadius(5)

        Group{
            switch self.style{
            case .normal:
                button
            case .emphisized:
                button.border(Color(.blue), width: 2)
            }
        }
    }
}

struct EnableAzooKeyViewImage: View {
    let identifier: String
    init(_ identifier: String){
        self.identifier = identifier
    }

    var body: some View {
        Image(identifier)
            .resizable()
            .scaledToFit()
            .cornerRadius(2)
    }
}
