//
//  CalendarView.swift
//  snap
//
//  Created by Olivier Wittop Koning on 05/06/2021.
//

import SwiftUI

struct CalendarView: View {
    @StateObject internal var calendarFetcher: CalendarFetcher
    @StateObject internal var calenderManger: CalenderManger
    @StateObject internal var auhtmanger: MsAuthManger
    let formatter = DateFormatter()
    let dateFormatter = DateFormatter()
    
    init(auhtmanger: StateObject<MsAuthManger>, calenderManger: StateObject<CalenderManger>) {
        _calendarFetcher = StateObject(wrappedValue: CalendarFetcher(authManger: auhtmanger, calenderManger: calenderManger))
        _calenderManger = calenderManger
        _auhtmanger = auhtmanger
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
                        Text(event.location.displayName ?? NSLocalizedString("No Location", comment: "Geen location CalendarView"))
                            .font(.footnote)
                        Spacer()
                        Text(verbatim: "\(self.formatter.string(from: dateFormatter.date(from: event.start.dateTime)!))-\(self.formatter.string(from: dateFormatter.date(from: event.end.dateTime)!))")
                            .font(.footnote)
                    }
                }
            }
        }.onAppear {
            self.auhtmanger.calendarFetcher = _calendarFetcher
        }
    }
}


