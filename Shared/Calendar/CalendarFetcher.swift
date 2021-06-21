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
    }
}
