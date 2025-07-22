//
//  ImageViewUpload.swift
//  week6_HetShah
//
//  Created by Het Shah on 2025-07-22.
//

import SwiftUI
import FirebaseStorage
import PhotosUI

struct ImageUploadView: View {
    @State private var selectedImage: UIImage?
    @State private var imageURL: URL?
    @State private var imageSelection: PhotosPickerItem?
    
    let fileName = "test_image"

    var body: some View {
        VStack(spacing: 20) {
            if let url = imageURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 250, height: 250)
            } else {
                Text("No image uploaded")
            }

            PhotosPicker("Select Image", selection: $imageSelection, matching: .images)
                .onChange(of: imageSelection) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }

            if let img = selectedImage {
                Button("Upload Image") {
                    uploadImage(img)
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Delete Image") {
                deleteImage()
            }
            .foregroundColor(.red)
        }
        .padding()
    }

    // MARK: - Firebase Upload
    func uploadImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = Storage.storage().reference().child("images/\(fileName).jpg")

        storageRef.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("Upload error: \(error)")
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Download URL error: \(error)")
                    return
                }
                imageURL = url
            }
        }
    }

    // MARK: - Firebase Delete
    func deleteImage() {
        let ref = Storage.storage().reference().child("images/\(fileName).jpg")
        ref.delete { error in
            if let error = error {
                print("Delete error: \(error)")
            } else {
                print("Image deleted")
                imageURL = nil
                selectedImage = nil
            }
        }
    }
}
