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
    @State var selectedLaunch: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                List {
                    ForEach((0..<(launchData.launches?.count ?? 0)), id: \.self) { i in
                        NavigationLink(destination: LaunchRowView(Launch: launchData.launches?[i]), tag: ((launchData.launches?[i]?.id ?? "LaunchId") as String), selection: $selectedLaunch) {
                            Text(launchData.launches?[i]?.missionName ?? "Geen missionName")
                        }
                    }
                }
            }.navigationTitle("SpaceX API")
            .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
                if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    logger.log("Received a payload via spotlight with id: \(id, privacy: .public)")
                    DispatchQueue.main.async {
                        self.selectedLaunch = id
                        // Dit is zodat de view moet reloaden en dan dus de nieuwe data binnen krijgt
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
            .onOpenURL(perform: { url in
                if url.scheme == "spacex" {
                    print("De url: \(url.absoluteString) with id: \(String(describing: url.valueOf("id")))")
                    DispatchQueue.main.async {
                        self.selectedLaunch = url.valueOf("id") ?? "109"
                    }
                } else {
                    print("De url: \(url.absoluteString) en was niet spacex://")
                }
            })
        }
    }
}

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
