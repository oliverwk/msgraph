//
//  LaunchImages.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 15/06/2021.
//

import SwiftUI

struct LaunchImages: View {
    let launch: LaunchListQuery.Data.LaunchesPast?
    let iterations: Int
    @Binding var selectedImage: String?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<iterations, id: \.self) { i in
                NavigationLink(destination:  RemoteImage(url: launch?.links?.flickrImages?[0] ?? "about:blank"), tag: ((launch?.links?.flickrImages?[0] ?? "LaunchId") as String), selection: $selectedImage) {
                RemoteImage(url: launch?.links?.flickrImages?[i] ?? "about:blank")
                    .cornerRadius(20)
                }
            }
        }.padding(.horizontal, 10)
    }
}

struct LaunchImages_Previews: PreviewProvider {
    static var previews: some View {
        LaunchImages(launch: PlaceholderLaunch, iterations: 4, selectedImage: .constant(""))
    }
}
