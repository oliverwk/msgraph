//
//  ContentView.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 14/03/2021.
//

import SwiftUI


struct ContentView: View {
    @State private var displayName: String = ""
    @State private var isPresented: Bool = false
    @State private var ProfilePicture: UIImage = UIImage()
    @State private var logedIn: Bool = false
    @State private var token: String = ""
    
    var body: some View {
        Image(uiImage: ProfilePicture)
            .padding(10)
        Text(displayName)
            .fontWeight(.heavy)
            .multilineTextAlignment(.center)
            .padding(10)
            .font(.largeTitle)
        Spacer()
        Text(token)
            .fontWeight(.heavy)
            .multilineTextAlignment(.center)
            .padding(10)
        Button("Snapchat Login Button") {
            self.isPresented = true
        }.disabled(logedIn).opacity(logedIn ? 0 : 1)
        .sheet(isPresented: $isPresented) {
            LoginCVWrapper(displayName: $displayName, isPresented: $isPresented, ProfilePicture: $ProfilePicture, logedIn: $logedIn, token: $token)
        }
    }
}
