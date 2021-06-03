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
    @StateObject private var authManger = MsAuthManger()
    
    var body: some View {
        ScrollView {
            VStack {
                Image(uiImage: authManger.ProfilePicture)
                    .padding(10)
                Text(authManger.displayName)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .font(.largeTitle)
                Text(authManger.ErrorMsg)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Button("Microsoft Login Button") {
                    self.isPresented = true
                }.disabled(authManger.logedIn).opacity(authManger.logedIn ? 0 : 1)
                .sheet(isPresented: $isPresented) {
                    LoginCVWrapper(isPresented: $isPresented)
                }
            }
        }
    }
}
