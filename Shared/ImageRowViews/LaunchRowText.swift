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
            Text(Launch?.missionName ?? "No missionName")
                .padding()
            Text(Launch?.launchSite?.siteNameLong ?? "No launchSite")
                .padding()
        }
        Text(Launch?.rocket?.rocketName ?? "No rocketName")
            .padding()
        Text(Launch?.launchDateLocal ?? "No launchDate")
            .padding()
    }
}

struct LaunchRowText_Previews: PreviewProvider {
    static var previews: some View {
        LaunchRowText(Launch: PlaceholderLaunch)
    }
}
