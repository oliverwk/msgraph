//
//  EventView.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 27/05/2021.
//

import SwiftUI
import os

struct EventView: View {
    let logger = Logger(
        subsystem: "nl.wittopkoning.msgraph",
        category: "EventView"
    )
    
    var Launch: LaunchListQuery.Data.LaunchesPast?
    @Binding var selectedLaunchID: String?
    @State var i: Int = 0
    let useractivity = "nl.wittopkoning.msgraph.view-launch"
    
    var body: some View {
        VStack {
            if !(Launch?.links?.flickrImages?.isEmpty ?? true) {
                RemoteImage(url: Launch?.links?.flickrImages?[i] ?? "about:blank")
                    .cornerRadius(5)
                    .padding(15)
                    .onTapGesture {
                        logger.log("Tapped image")
                        let imgs = Launch?.links?.flickrImages
                        self.i += 1
                        if self.i >= imgs?.count ?? 0 {
                            self.i = 0
                        } else if self.i <= -1 {
                            self.i = imgs?.count ?? 0 - 1
                        }
                    }
            }
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
        }.userActivity(useractivity, { activity in
            let theId = ((Launch?.id ?? "0") as String)
            activity.isEligibleForHandoff = true
            activity.isEligibleForSearch = false
            activity.persistentIdentifier = theId
            activity.referrerURL = URL(string: Launch?.links?.videoLink ?? "about:blank")
            activity.requiredUserInfoKeys = [theId]
            activity.title = NSLocalizedString("View launch \(Launch?.missionName ?? "")", comment: "View Launch activity")
            logger.log("Adding useractivity with id: \(theId, privacy: .public) on launch \(Launch?.missionName ?? "Geen mission Naam", privacy: .public)")
//            activity.becomeCurrent()
        })
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(Launch: LaunchListQuery.Data.LaunchesPast(missionName: "Starlink-15 (v1.0)", id: "109", details: "None", launchDateLocal: "2020-10-24T11:31:00-04:00", launchSite: LaunchListQuery.Data.LaunchesPast.LaunchSite(siteNameLong: "Cape Canaveral Air Force Station Space Launch Complex 40"), links: LaunchListQuery.Data.LaunchesPast.Link(videoLink: "https://youtu.be/J442-ti-Dhg", flickrImages: []), rocket: LaunchListQuery.Data.LaunchesPast.Rocket(rocketName: "Falcon 9")), selectedLaunchID: .constant("109"))
    }
}
