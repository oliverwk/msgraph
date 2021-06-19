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
    @StateObject private var authManger = MsAuthManger()
    @StateObject private var calenderManger = CalenderManger()
    
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
                .padding(.bottom, 15)
            Button("Add to Calendar") {
                let events = self.authManger.calendarFetcher?.wrappedValue.CalendarEvents
                print("Calling self.calenderManger.AddEvents(events ?? [])")
                self.calenderManger.AddEvents(events ?? [])
            }.disabled(!authManger.logedIn).opacity(authManger.logedIn ? 1 : 0)
            CalendarView(auhtmanger: _authManger, calenderManger: _calenderManger)
            Button("Microsoft Login Button") {
                self.$isPresentedSignIn.wrappedValue.toggle()
            }.disabled(authManger.logedIn).opacity(authManger.logedIn ? 0 : 1)
            .sheet(isPresented: $isPresentedSignIn) {
                LoginCVWrapper(isPresented: $isPresentedSignIn, authManger: _authManger)
            }
            Button("Microsoft LogOut Button") {
                self.authManger.signOut()
                print("logedIn:", authManger.logedIn)
            }.disabled(!authManger.logedIn).opacity(authManger.logedIn ? 1 : 0)
            Spacer(minLength: 20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
