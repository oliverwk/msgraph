//
//  ImageViewer.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 15/06/2021.
//

import SwiftUI

struct ImageViewer: View {
    @State var scale: CGFloat = 1.0
    let url: String
    
    var body: some View {
        VStack(alignment: .center) {
            RemoteImage(url: url)
                .scaleEffect(scale)
                .padding(.top, 155)
                .gesture(MagnificationGesture()
                            .onChanged { value in
                                self.scale = value.magnitude
                            }
                )
                .ignoresSafeArea(.container)
        }
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(url: "https://live.staticflickr.com/65535/50630802488_8cc373728e_o.jpg")
            .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
    }
}
