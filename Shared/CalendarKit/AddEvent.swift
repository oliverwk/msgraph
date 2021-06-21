//
//  AddEvent.swift
//  snap
//
//  Created by Olivier Wittop Koning on 19/06/2021.
//

import EventKit
import os

extension CalenderManger {
    func AddEvents(_ events: [TeamsEvent]) -> Bool {
        var result = true
        for event in events {
            if !AddEvent(event: event) {
                result = false
            }
        }
        return result
    }
    
    func AddEvent(event: TeamsEvent) -> Bool {
        
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
                    return true
                } else {
                    logger.log("Event: \(event.subject) is al toegevoegd")
                    return true
                }
            } catch {
                logger.error("Error while trying to create event in calendar: \(error.localizedDescription, privacy: .public)")
                return false
            }
        case .notDetermined:
            logger.log("De calender permission is notDetermined dus ik vraag er voor.")
            var result = Bool()
            store.requestAccess(to: .event) { granted, error in
                logger.log("permission: \(granted, format: .truth, privacy: .public)")
                DispatchQueue.main.async {
                    self.authStatus = self.getAuthorizationStatus()
                }
                if granted {
                    if !self.AddEvent(event: event) {
                        result =  false
                    }
                }
            }
            return result
        case .denied:
            logger.log("De calender permission is denied")
            return false
            
        case .restricted:
            logger.log("De calender permission is restricted")
            return false
            
        default:
            logger.fault("default bij AddEvent() permission help please")
            return false
        }
    }
}
