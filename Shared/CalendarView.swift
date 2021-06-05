//
//  CalendarView.swift
//  snap
//
//  Created by Maarten Wittop Koning on 05/06/2021.
//

import SwiftUI

struct CalendarView: View {
    let events: [Event]
    
    var body: some View {
        NavigationView {
            List(events) { site in
                NavigationLink(destination: Text(site.description)) {
                    Text(site.name)
                }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(events: [Event(name: "O&O", description: "O&O Eigen planning", start: Date(timeIntervalSinceNow: 1)), Event(name: "Wiskunde", description: "Opdarcht 31, 34", start: Date(timeIntervalSinceNow: 1))])
    }
}

struct Event: Codable, Identifiable {
    public var id = UUID()
    public var name: String
    public var description: String
    public var start: Date
}
