//
//  LaunchImage.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 15/06/2021.
//

import SwiftUI

struct LaunchImage: View {
    let launch: LaunchListQuery.Data.LaunchesPast?
    
    var body: some View {
        NavigationLink(destination: ImageViewer(url: launch?.links?.flickrImages?[0] ?? "about:blank")) {
        RemoteImage(url: launch?.links?.flickrImages?[0] ?? "about:blank")
            .cornerRadius(20)
            .padding(.horizontal, 15)
        }
    }
}

struct LaunchImage_Previews: PreviewProvider {
    static var previews: some View {
        LaunchImage(launch: PlaceholderLaunch)
    }
}
