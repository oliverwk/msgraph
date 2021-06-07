//
//  CalendarView.swift
//  snap
//
//  Created by Maarten Wittop Koning on 05/06/2021.
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
                    Text(verbatim: event.description)
                }
            }
        }
    }
}

/*struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(events: [Event(name: "O&O", description: "O&O Eigen planning", start: Date(timeIntervalSinceNow: 1)), Event(name: "Wiskunde", description: "Opdarcht 31, 34", start: Date(timeIntervalSinceNow: 1))])
    }
}*/

struct Event: Codable, Identifiable {
    public var id = UUID()
    public var name: String
    public var description: String
    public var start: Date
}
