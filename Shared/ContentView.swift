//
//  ContentView.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 01/06/2021.
//

import SwiftUI
import CoreSpotlight
import os
let userActivityType = "nl.wittopkoning.msgraph.view-launch"

struct ContentView: View {
    let logger = Logger(
        subsystem: "nl.wittopkoning.msgraph",
        category: "EventView"
    )
    @ObservedObject private var launchData: LaunchListData = LaunchListData()
    @SceneStorage("ContentView.selectedLaunch") var selectedLaunch: String?
    @State var textHidden = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                List {
                    ForEach((0..<(launchData.launches?.count ?? 0)), id: \.self) { i in
                        NavigationLink(destination: EventView(Launch: (launchData.launches?[i]), selectedLaunchID: $selectedLaunch), tag: ((launchData.launches?[i]?.id ?? "NOID") as String), selection: $selectedLaunch) {
                            Text(launchData.launches?[i]?.missionName ?? "Geen missionName")
                        }
                    }
                }
                Text(textHidden).hidden()
            }.navigationTitle("SpaceX API")
            .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
                if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    DispatchQueue.main.async {
                        self.selectedLaunch = id
                        // Dit is zodat de view moet reloaden en dan dus de nieuwe data binnen krijg
                        self.textHidden = " "
                        
                    }
                }
            }
            .onContinueUserActivity(userActivityType) { userActivity in
                let id = String(describing:(userActivity.userInfo?["msgraph.launch.id"] as! Array<Any>)[0])
                
                logger.log("Received a payload via handoff id: \(id, privacy: .public)")
                DispatchQueue.main.async {
                    self.selectedLaunch = id
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
