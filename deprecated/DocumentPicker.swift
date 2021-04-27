//
//  DocumentPicker.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/23.
//  Copyright © 2021 DevEn3. All rights reserved.
//
/*
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    init(pickerResult: Binding<Data?>, isPresented: Binding<Bool>, extensions: [String]) {
        self.extensions = extensions
        self._pickerResult = pickerResult
        self._isPresented = isPresented
    }

    @Binding private var pickerResult: Data?
    @Binding private var isPresented: Bool
    private let extensions: [String]

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: extensions.compactMap {UTType(filenameExtension: $0, conformingTo: .text)}, asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        private let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first, let data = try? Data.init(contentsOf: url) {
                parent.pickerResult = data
                parent.isPresented = false
            }
        }
    }
}
*/
