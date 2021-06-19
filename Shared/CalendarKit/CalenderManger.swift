//
//  CalenderManger.swift
//  snap
//
//  Created by Olivier Wittop Koning on 18/06/2021.
//

import EventKit
import os

internal let logger = Logger(subsystem: "nl.wittopkoning.snap", category: "CalenderManger")

class CalenderManger: ObservableObject {
    var store = EKEventStore()
    @Published var authStatus: EKAuthorizationStatus
    
    init() {
        self.authStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
}
