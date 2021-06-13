//
//  RemoteImage.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

import SwiftUI

struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }
    
    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading
        
        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                print("[Fatal] Invalid URL: \(url)")
                self.state = .failure
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
    
    var body: some View {
        selectImage()
            .resizable()
            // iOS 15 .symbolRendingMode(.mulitcolor)
    }
    
    init(url: String, loading: Image = Image(systemName: "photo.fill"), failure: Image = Image(systemName: "xmark.octagon.fill")) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }
    
    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = UIImage(data: loader.data) {
                return Image(uiImage: image)
            } else {
                return failure
            }
        }
    }
}
