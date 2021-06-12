//
//  EventView.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 27/05/2021.
//

import SwiftUI

struct EventView: View {
    var event: LaunchListQuery.Data.LaunchesPast?
    @Binding var selectedLaunchID: String?
    
    var body: some View {
        VStack {
            HStack {
                Text(event?.missionName ?? "Geen missionName")
                    .padding()
                Text(event?.launchSite?.siteNameLong ?? "Geen launchSite")
                    .padding()
            }
            Text(event?.rocket?.rocketName ?? "Geen rocketName")
                .padding()
            Text(event?.launchDateLocal ?? "Geen launchDate")
                .padding()
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: LaunchListQuery.Data.LaunchesPast(missionName: "Starlink-15 (v1.0)", id: "109", details: "None", launchDateLocal: "2020-10-24T11:31:00-04:00", launchSite: LaunchListQuery.Data.LaunchesPast.LaunchSite(siteNameLong: "Cape Canaveral Air Force Station Space Launch Complex 40"), links: LaunchListQuery.Data.LaunchesPast.Link(videoLink: "https://youtu.be/J442-ti-Dhg", flickrImages: []), rocket: LaunchListQuery.Data.LaunchesPast.Rocket(rocketName: "Falcon 9")), selectedLaunchID: .constant("109"))
    }
}
