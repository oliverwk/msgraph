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
    
    init(auhtmanger: StateObject<MsAuthManger>) {
        _calendarFetcher = StateObject(wrappedValue: CalendarFetcher(authManger: auhtmanger))
        formatter.dateFormat = "HH:mm"
    }
    
    var body: some View {
        NavigationView {
            List(calendarFetcher.CalendarEvents) { event in
                NavigationLink(destination: CalendarDetailView(event: event)) {
                    HStack {
                        Text(verbatim: event.name)
                        Text(verbatim: event.location)
                            .font(.footnote)
                        Spacer()
                        Text(self.formatter.string(from: event.start))
                            .font(.footnote)
                    }
                }
            }
        }
    }
}


