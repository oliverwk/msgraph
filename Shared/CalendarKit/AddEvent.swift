//
//  AddEvent.swift
//  snap
//
//  Created by Olivier Wittop Koning on 19/06/2021.
//

import EventKit
import os

extension CalenderManger {
    func AddEvents(_ events: [TeamsEvent]) {
        for event in events {
            AddEvent(event: event)
        }
    }
    
    func AddEvent(event: TeamsEvent) {
        
        switch self.authStatus {
        case .authorized:
            //logger.log("datetime: \(event.start.dateTime) and date: \(String(describing: event.start.date))")
            let newEvent = EKEvent(eventStore: store)
            newEvent.calendar = store.defaultCalendarForNewEvents
            newEvent.title = event.subject
            newEvent.availability = .busy
            newEvent.notes = event.bodyPreview
            newEvent.timeZone = event.start.NativeTimeZone
            newEvent.startDate = event.start.date
            newEvent.endDate = event.end.date
            do {
                logger.log("Adding event with title: \(event.subject)")
                if !EventIsAdded(newEvent) {
                    try store.save(newEvent, span: .thisEvent)
                } else {
                    logger.log("Event: \(event.subject) is al toegevoegd")
                }
            } catch {
                logger.error("Error while trying to create event in calendar: \(error.localizedDescription, privacy: .public)")
            }
        case .notDetermined:
            logger.log("De calender permission is notDetermined dus ik vraag er voor.")
            store.requestAccess(to: .event) { granted, error in
                logger.log("permission: \(granted, format: .truth, privacy: .public)")
                DispatchQueue.main.async {
                    self.authStatus = self.getAuthorizationStatus()
                }
                if granted {
                    self.AddEvent(event: event)
                }
            }
        case .denied:
            logger.log("De calender permission is denied")
            
        case .restricted:
            logger.log("De calender permission is restricted")
            
        default:
            logger.fault("default bij AddEvent() permission help please")
        }
    }
}
