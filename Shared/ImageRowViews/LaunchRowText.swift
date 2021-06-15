//
//  LaunchRowText.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 15/06/2021.
//

import SwiftUI

struct LaunchRowText: View {
    
    let Launch: LaunchListQuery.Data.LaunchesPast?
    
    var body: some View {
        HStack {
            Text(Launch?.missionName ?? "Geen missionName")
                .padding()
            Text(Launch?.launchSite?.siteNameLong ?? "Geen launchSite")
                .padding()
        }
        Text(Launch?.rocket?.rocketName ?? "Geen rocketName")
            .padding()
        Text(Launch?.launchDateLocal ?? "Geen launchDate")
            .padding()
    }
}

struct LaunchRowText_Previews: PreviewProvider {
    static var previews: some View {
        LaunchRowText(Launch: PlaceholderLaunch)
    }
}
