//
//  PhotoPicker.swift
//  MainApp
//
//  Created by ensan on 2021/02/08.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import PhotosUI
import SwiftUI
import SwiftUtils

struct PhotoPicker: UIViewControllerRepresentable {
    internal init(configuration: PHPickerConfiguration, pickerResult: Binding<UIImage?>, isPresented: Binding<Bool>) {
        self.configuration = configuration
        self._pickerResult = pickerResult
        self._isPresented = isPresented
    }

    private let configuration: PHPickerConfiguration
    @Binding private var pickerResult: UIImage?
    @Binding private var isPresented: Bool

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// PHPickerViewControllerDelegate => Coordinator
    final class Coordinator: PHPickerViewControllerDelegate {
        private let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        // PHPickerViewControllerDelegateの設定
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for image in results {
                if image.itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
                    image.itemProvider.loadObject(ofClass: PHLivePhoto.self) { (livePhotoObject, error) in
                        // PHLivePhotoとして取得
                        if let livePhoto = livePhotoObject as? PHLivePhoto,
                           let imageUrl = livePhoto.value(forKey: "imageURL") as? URL {
                            do {
                                // Dataで取得
                                let imageData: Data = try Data(contentsOf: imageUrl)
                                if let uiImage = UIImage(data: imageData), let cgImage = uiImage.cgImage {
                                    self.parent.pickerResult = UIImage(cgImage: cgImage, scale: 1, orientation: uiImage.imageOrientation)
                                }
                            } catch {
                                debug(error)
                            }
                        }
                    }
                } else if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    image.itemProvider.loadObject(ofClass: UIImage.self) { (selectedImage, error) in
                        if let error {
                            debug("error: \(error.localizedDescription)")
                            return
                        }
                        guard let wrapImage = selectedImage as? UIImage else {
                            debug("wrap error")
                            return
                        }
                        // 選択したImageをpickerResultに格納
                        self.parent.pickerResult = wrapImage
                    }
                }
            }
            // 閉じる
            parent.isPresented = false
        }
    }
}
