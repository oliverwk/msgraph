//
//  RemoteImage.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

import SwiftUI
import ImageIO


struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }
    
    func resizedImage(size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
        ]
        
        guard let imageSource = CGImageSourceCreateWithData(loader.data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else {
            return nil
        }
        
        return UIImage(cgImage: image)
    }
    
    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading
        
        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                print("[Fatal] Invalid URL: \(url)")
                
                self.state = .loading
                return
            }
            
            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    if let response = response as? HTTPURLResponse {
                        print("[ERROR] Er was geen data bij het laden een afbeelding url: \(url) en met response: \(response) Met de error: \(error.debugDescription)")
                    } else {
                        print("[ERROR] Er was geen data bij het laden een afbeelding url: \(url) Met de error: \(error.debugDescription)")
                    }
                    self.state = .failure
                }
                
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }
    
    @StateObject private var loader: Loader
    var loading: Image
    var failure: Image
    var IsWiget: Bool
    
    var body: some View {
        ScrollView {
            selectImage()
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    init(url: String, loading: Image = Image(systemName: "photo.fill"), failure: Image = Image(systemName: "xmark.octagon.fill"), widget: Bool = false) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
        self.IsWiget = widget
    }
    
    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if self.IsWiget {
                if let img = resizedImage(size: CGSize(width: 10, height: 10)) {
                    return Image(uiImage: img)
                } else {
                    return failure
                }
            } else {
                if let img = UIImage(data: loader.data) {
                    return Image(uiImage: img)
                } else {
                    return failure
                }
            }
        }
    }
}
