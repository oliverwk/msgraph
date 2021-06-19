//
//  CalendarFetcher.swift
//  snap
//
//  Created by Olivier Wittop Koning on 06/06/2021.
//

import Combine
import Foundation
import SwiftUI

public class CalendarFetcher: ObservableObject {
    public var CalendarEventsChanged = PassthroughSubject<Void, Never>()
    @StateObject internal var authManger: MsAuthManger
    @StateObject internal var calenderManger: CalenderManger
    @Published var CalendarEvents = [TeamsEvent]() { didSet { CalendarEventsChanged.send() } }
    
    init(authManger: StateObject<MsAuthManger>, calenderManger: StateObject<CalenderManger>) {
        _authManger = authManger
        _calenderManger = calenderManger
        self.authManger.CalendarTokenCallback = GetCalendar
        let volgendeweek = Date().addingTimeInterval(604800)
        let _ = self.authManger.AccessTokenCahnged.sink { _ in
            print("AccessToken is now \(self.$authManger.accessToken)")
            self.GetCalendar(volgendeweek)
        }
        
        if self.authManger.accessToken != "" {
            GetCalendar(volgendeweek)
        } else {
            print("AccessToken isn't there yet")
        }

        /*let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssssss"
        let _ = self.$CalendarEvents.sink { _ in
            print("Called sink on $CalendarEvents")
            self.calenderManger.AddEvents(self.CalendarEvents)
        }*/
    }
}
