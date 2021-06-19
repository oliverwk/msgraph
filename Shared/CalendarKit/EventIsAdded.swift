//
//  EventIsAdded.swift
//  snap
//
//  Created by Olivier Wittop Koning on 19/06/2021.
//

import EventKit

extension CalenderManger {
    
     func EventIsAdded(_ eventToAdd: EKEvent) -> Bool {
        let predicate = store.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: nil)
        let existingEvents = store.events(matching: predicate)
        
        let eventAlreadyExists = existingEvents.contains { (event) -> Bool in
            return eventToAdd.title == event.title && event.startDate == eventToAdd.startDate && event.endDate == eventToAdd.endDate
        }
        return eventAlreadyExists
    }
}
