//
//  msgraphApp.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 25/05/2021.
//

import SwiftUI
import CoreSpotlight
import SwiftUI
import os

@main
struct msgraphApp: App {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.msgraph",
        category: "msgraphApp"
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlight)
        }
    }
    func handleSpotlight(_ userActivity: NSUserActivity) {
        self.logger.log("[SPOTLIGHT] Opend a spotlight link")
        let defaults = UserDefaults.standard
        if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            self.logger.notice("[SPOTLIGHT] Found identifier \(id, privacy: .public)")
            if let savedLaunches = defaults.object(forKey: "Launches") as? Data {
                if let loadedLaunches = try? JSONDecoder().decode([Lingerie].self, from: savedLaunches) {
                    self.logger.log("[SPOTLIGHT] Is loadedLaunches an array: \(loadedLaunches[0], privacy: .public), hopelijk is dit een id: \(loadedLaunches[0].id, privacy: .public)")
                    for launch in loadedLaunches {
                        if launch.id == id {
                            self.logger.log("[SPOTLIGHT] Found \(id, privacy: .public) with name \(loadedLaunches[i].naam, privacy: .public)")
			    // Set state hier
                            break
                        }
                    }
                }
            }
        }
    }
}
