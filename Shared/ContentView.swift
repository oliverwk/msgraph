//
//  ContentView.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 14/03/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var displayName: String = ""
    @State private var CalendarText: String = NSLocalizedString("Add to Calendar", comment: "contentview state Add to Calendar")
    @State private var isPresentedSignIn: Bool = false
    @StateObject private var authManger = MsAuthManger()
    @StateObject private var calenderManger = CalenderManger()
    
    var body: some View {
        VStack {
            Image(uiImage: authManger.ProfilePicture)
                .padding(10)
            Text(verbatim: authManger.displayName)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .padding(10)
                .font(.largeTitle)
            Text(authManger.ErrorMsg)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.bottom, 15)
            Button(CalendarText) {
                let events = self.authManger.calendarFetcher?.wrappedValue.CalendarEvents
                print("Calling self.calenderManger.AddEvents(events ?? [])")
                let addedToCalender = self.calenderManger.AddEvents(events ?? [])
                if addedToCalender {
                    self.CalendarText = NSLocalizedString("Added to Calendar", comment: "contentview Added to Calendar")
                } else {
                    self.CalendarText = NSLocalizedString("Failed to add to Calendar", comment: "contentview Failed to add to Calendar")
                }
            }.disabled(!authManger.logedIn).padding(.horizontal, 5).padding().foregroundColor(Color.white).background(Color.blue).cornerRadius(8).opacity(authManger.logedIn ? 1 : 0)
            CalendarView(auhtmanger: _authManger, calenderManger: _calenderManger)
            Button(NSLocalizedString("Microsoft Login Button", comment: "knop")) {
                self.$isPresentedSignIn.wrappedValue.toggle()
            }.disabled(authManger.logedIn).opacity(authManger.logedIn ? 0 : 1)
            .sheet(isPresented: $isPresentedSignIn) {
                LoginCVWrapper(isPresented: $isPresentedSignIn, authManger: _authManger)
            }
            Button(NSLocalizedString("Microsoft LogOut Button", comment: "knop")) {
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
