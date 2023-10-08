//
//  PhotosTab.swift
//  AzooKeyCore
//

import Foundation
import SwiftUI
import SwiftUIUtils
import PhotosUI
import CoreTransferable

// To support multiple transferrable cases, use these boiler plates.
@available(iOS 17, *)
private enum ItemData {
    case gif(GifImageData)
    case heic(HeicImageData)
    case heif(HeifImageData)
    case image(ImageData)
    case jpg(JpgImageData)
    case livePhoto(LivePhotoData)
    case movie(MovieImageData)
    case mp3(Mp3ImageData)
    case mpeg(MpegImageData)
    case mpeg4Movie(Mpeg4MovieData)
    case pdf(PdfImageData)
    case png(PngImageData)
    case quickTimeMovie(QuickTimeMovieData)
}

@available(iOS 17, *)
private protocol TransferableWrapper: Transferable {
    var data: Data { get set }
    init(data: Data)
    static var utType: UTType { get }
}

@available(iOS 17, *)
extension TransferableWrapper {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: Self.utType) { item in
            item.data
        } importing: { data in
            Self(data: data)
        }
    }
}

@available(iOS 17, *)
private struct GifImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .gif
}

@available(iOS 17, *)
private struct HeicImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .heic
}

@available(iOS 17, *)
private struct HeifImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .heif
}

@available(iOS 17, *)
private struct ImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .image
}

@available(iOS 17, *)
private struct JpgImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .jpeg
}

@available(iOS 17, *)
private struct LivePhotoData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .livePhoto
}

@available(iOS 17, *)
private struct MovieImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .movie
}

@available(iOS 17, *)
private struct Mp3ImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .mp3
}

@available(iOS 17, *)
private struct MpegImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .mpeg
}

@available(iOS 17, *)
private struct Mpeg4MovieData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .mpeg4Movie
}

@available(iOS 17, *)
private struct PdfImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .pdf
}

@available(iOS 17, *)
private struct PngImageData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .png
}

@available(iOS 17, *)
private struct QuickTimeMovieData: TransferableWrapper {
    var data: Data
    static let utType: UTType = .quickTimeMovie
}

@available(iOS 17, *)
private extension ItemData {
    private struct InitError: Error {
        var message: String
    }
    init(_ item: PhotosPickerItem) async throws {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw InitError(message: "Failed to load data")
        }
        if let type = item.supportedContentTypes.first {
            switch type {
            case .gif:
                self = .gif(.init(data: data))
            case .heic:
                self = .heic(.init(data: data))
            case .heif:
                self = .heif(.init(data: data))
            case .image:
                self = .image(.init(data: data))
            case .jpeg:
                self = .jpg(.init(data: data))
            case .livePhoto:
                self = .livePhoto(.init(data: data))
            case .movie:
                self = .movie(.init(data: data))
            case .mp3:
                self = .mp3(.init(data: data))
            case .mpeg:
                self = .mpeg(.init(data: data))
            case .mpeg4Movie:
                self = .mpeg4Movie(.init(data: data))
            case .pdf:
                self = .pdf(.init(data: data))
            case .png:
                self = .png(.init(data: data))
            case .quickTimeMovie:
                self = .quickTimeMovie(.init(data: data))
            default:
                throw InitError(message: "Unsupported type \(type)")
            }
        } else {
            self = .image(.init(data: data))
        }
    }
    
    var data: Data {
        switch self {
        case 
            let .gif(value as any TransferableWrapper),
            let .heic(value as any TransferableWrapper),
            let .heif(value as any TransferableWrapper),
            let .image(value as any TransferableWrapper),
            let .jpg(value as any TransferableWrapper),
            let .livePhoto(value as any TransferableWrapper),
            let .movie(value as any TransferableWrapper),
            let .mp3(value as any TransferableWrapper),
            let .mpeg(value as any TransferableWrapper),
            let .mpeg4Movie(value as any TransferableWrapper),
            let .pdf(value as any TransferableWrapper),
            let .png(value as any TransferableWrapper),
            let .quickTimeMovie(value as any TransferableWrapper):
            return value.data
        }
    }

    var utType: UTType {
        switch self {
            case
            let .gif(value as any TransferableWrapper),
            let .heic(value as any TransferableWrapper),
            let .heif(value as any TransferableWrapper),
            let .image(value as any TransferableWrapper),
            let .jpg(value as any TransferableWrapper),
            let .livePhoto(value as any TransferableWrapper),
            let .movie(value as any TransferableWrapper),
            let .mp3(value as any TransferableWrapper),
            let .mpeg(value as any TransferableWrapper),
            let .mpeg4Movie(value as any TransferableWrapper),
            let .pdf(value as any TransferableWrapper),
            let .png(value as any TransferableWrapper),
            let .quickTimeMovie(value as any TransferableWrapper):
            return type(of: value).utType
        }
    }
}
@available(iOS 17, *)
private extension View {
    @ViewBuilder
    func draggable(_ data: ItemData) -> some View {
        switch data {
        case let .gif(value):
            self.draggable(value)
        case let .heic(value):
            self.draggable(value)
        case let .heif(value):
            self.draggable(value)
        case let .image(value):
            self.draggable(value)
        case let .jpg(value):
            self.draggable(value)
        case let .livePhoto(value):
            self.draggable(value)
        case let .movie(value):
            self.draggable(value)
        case let .mp3(value):
            self.draggable(value)
        case let .mpeg(value):
            self.draggable(value)
        case let .mpeg4Movie(value):
            self.draggable(value)
        case let .pdf(value):
            self.draggable(value)
        case let .png(value):
            self.draggable(value)
        case let .quickTimeMovie(value):
            self.draggable(value)
        }
    }
}

@available(iOS 17, *)
@MainActor
struct PhotosTab<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var data: ItemData?
    @EnvironmentObject private var variableStates: VariableStates
    @State private var toastTask: Task<Void, any Error>? = nil
    @State private var showToast = false
    @State private var copied = false
    
    var body: some View {
        VStack {
            PhotosPicker("写真を選ぶ", selection: $photosPickerItem)
                .photosPickerStyle(.inline)
                .photosPickerAccessoryVisibility(.hidden, edges: .top)
                .photosPickerAccessoryVisibility(.hidden, edges: .bottom)
                .overlay(alignment: .bottom) {
                    if showToast, let data {
                        HStack {
                            Text("長押し&ドラッグで貼り付け")
                                .padding(5)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                                .compositingGroup()
                                .draggable(data)
                            Group {
                                if !self.copied {
                                    Label("コピー", systemImage: "doc.on.doc")
                                        .labelStyle(.titleOnly)
                                } else {
                                    Label("完了", systemImage: "checkmark")
                                        .labelStyle(.iconOnly)
                                }
                            }
                                .padding(5)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                                .compositingGroup()
                                .onTapGesture {
                                    UIPasteboard.general.setData(data.data, forPasteboardType: data.utType.identifier)
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        self.copied = true
                                    }
                                }
                        }
                        .font(.system(size: 20))
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(Color.primary)
                        .offset(y: -10)
                    }
                }
                .onChange(of: photosPickerItem) { item in
                    self.toastTask?.cancel()
                    self.copied = false

                    guard let item else {
                        self.toastTask = nil
                        self.data = nil
                        self.showToast = false
                        return
                    }
                    self.toastTask = Task {
                        do {
                            self.data = try await .init(item)
                            withAnimation {
                                self.showToast = true
                            }
                            try await Task.sleep(for: .seconds(3))
                            try Task.checkCancellation()
                            withAnimation {
                                self.showToast = false
                            }
                        } catch {
                            print(error)
                            throw error
                        }
                    }
                }

        }
        .frame(width: variableStates.interfaceSize.width)
    }
}
