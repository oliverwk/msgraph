//
//  CalendarView.swift
//  snap
//
//  Created by Olivier Wittop Koning on 05/06/2021.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var calendarFetcher: CalendarFetcher
    
    init(auhtmanger: StateObject<MsAuthManger>) {
        _calendarFetcher = StateObject(wrappedValue: CalendarFetcher(authManger: auhtmanger))
    }
    
    var body: some View {
        NavigationView {
            List(calendarFetcher.CalendarEvents) { event in
                NavigationLink(destination: Text(verbatim: event.description)) {
                    HStack {
                        Text(verbatim: event.name)
                        Text(verbatim: event.location)
                            .font(.footnote)
                    }
                }
            }
        }
    }
}

struct Event: Codable, Identifiable {
    public var id = UUID()
    public var name: String
    public var description: String
    public var start: Date
    public var location: String
}
