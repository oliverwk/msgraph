//
//  ContentView.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 01/06/2021.
//

import SwiftUI
import CoreSpotlight

struct ContentView: View {
    @ObservedObject private var launchData: LaunchListData = LaunchListData()
    @SceneStorage("ContentView.selectedLaunch") private var selectedLaunch: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                List {
                    ForEach((0..<(launchData.launches?.count ?? 0)), id: \.self) { i in
                        NavigationLink(destination: EventView(event: (launchData.launches?[i]), selectedLaunchID: $selectedLaunch), tag: ((launchData.launches?[i]?.id ?? UUID().uuidString) as String), selection: $selectedLaunch) {
                            Text(launchData.launches?[i]?.missionName ?? "Geen missionName")
                        }
                    }
                }
            }.navigationTitle("SpaceX API")
            .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
                if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
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
