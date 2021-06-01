//
//  EventView.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 27/05/2021.
//

import SwiftUI

struct EventView: View {
    var event: LaunchListQuery.Data.LaunchesPast
    
    var body: some View {
        HStack {
            Text("Hello, world!")
                .padding()
            Text(event.missionName ?? "Geen naam")
                .padding()
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: LaunchListQuery.Data.LaunchesPast(missionName: "StarLink", launchDateLocal: "2020-10-24T11:31:00-04:00", launchSite: LaunchListQuery.Data.LaunchesPast.LaunchSite(siteNameLong: "Cape Canaveral Air Force Station Space Launch Complex 40"), links: LaunchListQuery.Data.LaunchesPast.Link(videoLink: "about:blank"), rocket: LaunchListQuery.Data.LaunchesPast.Rocket(rocketName: "Falcon 9", secondStage: LaunchListQuery.Data.LaunchesPast.Rocket.SecondStage(payloads: [LaunchListQuery.Data.LaunchesPast.Rocket.SecondStage.Payload(payloadType: "Satellite", payloadMassKg: 1440.0)]))))
    }
}
