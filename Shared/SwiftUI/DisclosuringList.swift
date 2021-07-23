//
//  DisclosuringList.swift
//  DisclosuringList
//
//  Created by β α on 2021/07/23.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

struct DisclosuringList<Item: Identifiable, Label: View, Content: View>: View {
    @Environment(\.editMode) var editMode
    @Binding private var items: [Item]
    private let label: (Item) -> Label
    private let content: (Binding<Item>) -> Content
    private var delete: Optional<(IndexSet) -> ()> = nil
    private var move: Optional<(IndexSet, Int) -> ()> = nil

    init(_ items: Binding<[Item]>, @ViewBuilder content: @escaping (Binding<Item>) -> Content, @ViewBuilder label: @escaping (Item) -> Label) {
        self._items = items
        self.label = label
        self.content = content
    }
    var body: some View {
        if editMode?.wrappedValue == .inactive {
            ForEach($items.identifiableItems) { value in
                MiniDisclosureGroup {
                    content(value.$item)
                        .listRowSeparator(.hidden, edges: .top)
                } label: {
                    label(value.item)
                        .listRowSeparator(.hidden, edges: .bottom)
                }
            }
        } else {
            List {
                ForEach($items.identifiableItems) {value in
                    label(value.item)
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
        }
    }

    func onDelete(perform action: Optional<(IndexSet) -> ()>) -> Self {
        var result = self
        result.delete = action
        return result
    }

    func onMove(perform action: Optional<(IndexSet, Int) -> ()>) -> Self {
        var result = self
        result.move = action
        return result
    }
}

private struct MiniDisclosureGroup<Label: View, Content: View>: View {
    private let label: () -> Label
    private let content: () -> Content
    @State private var hidden = true
    init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label) {
        self.label = label
        self.content = content
    }

    var body: some View {
        HStack {
            self.label()
            Spacer()
            Button {
                hidden.toggle()
            } label: {
                Image(systemName: hidden ? "chevron.right" : "chevron.down")
                    .font(.system(.caption).bold())
                    .foregroundColor(.accentColor)
            }
        }
        if !hidden {
            self.content()
        }
    }

}
