//
//  CalendarView.swift
//  snap
//
//  Created by Olivier Wittop Koning on 05/06/2021.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var calendarFetcher: CalendarFetcher
    let formatter = DateFormatter()
    let dateFormatter = DateFormatter()
    
    init(auhtmanger: StateObject<MsAuthManger>) {
        _calendarFetcher = StateObject(wrappedValue: CalendarFetcher(authManger: auhtmanger))
        formatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssssss"
    }
    
    var body: some View {
        NavigationView {
            List(calendarFetcher.CalendarEvents) { event in
                NavigationLink(destination: CalendarDetailView(event: event)) {
                    HStack {
                        Text(verbatim: event.subject)
                        Text(verbatim: event.location.displayName ?? "Geen Location")
                            .font(.footnote)
                        Spacer()
                        Text("\(self.formatter.string(from: dateFormatter.date(from: event.start.dateTime)!))-\(self.formatter.string(from: dateFormatter.date(from: event.end.dateTime)!))")
                            .font(.footnote)
                    }
                }
            }
        }
    }
}


