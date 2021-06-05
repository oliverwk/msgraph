//
//  ContentView.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 14/03/2021.
//

import SwiftUI


struct ContentView: View {
    @State private var displayName: String = ""
    @State private var isPresentedSignIn: Bool = false
    @State private var isPresentedLogOut: Bool = false
    @StateObject private var authManger = MsAuthManger()
    let events = [Event(name: "O&O", description: "O&O Eigen planning", start: Date(timeIntervalSinceNow: 1)), Event(name: "Wiskunde", description: "Opdarcht 31,34", start: Date(timeIntervalSinceNow: 1))]
    var body: some View {
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
            CalendarView(events: events)
            Button("Microsoft Login Button") {
                self.$isPresentedSignIn.wrappedValue.toggle()
            }.disabled(authManger.logedIn).opacity(authManger.logedIn ? 0 : 1)
            .sheet(isPresented: $isPresentedSignIn) {
                LoginCVWrapper(isPresented: $isPresentedSignIn, authManger: _authManger)
            }
            Button("Microsoft LogOut Button") {
                self.isPresentedLogOut = true
                print("logedIn:", authManger.logedIn)
            }.disabled(!authManger.logedIn).opacity(authManger.logedIn ? 1 : 0)
            .sheet(isPresented: $isPresentedLogOut) {
                LogoutViewControllerRepresentable(isPresented: $isPresentedLogOut, authManger: _authManger)
            }
            Spacer(minLength: 20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
