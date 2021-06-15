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
    let useractivity = "nl.wittopkoning.msgraph.view-launch"
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                if ((Launch?.links?.flickrImages?.count ?? 0) <= 5) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(0..<(Launch?.links?.flickrImages?.count ?? 4), id: \.self) { i in
                            RemoteImage(url: Launch?.links?.flickrImages?[i] ?? "about:blank")
                                .cornerRadius(20)
                        }
                    }.padding(.horizontal, 10)
                } else if ((Launch?.links?.flickrImages?.count ?? 0) >= 4) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(0..<4, id: \.self) { i in
                            RemoteImage(url: Launch?.links?.flickrImages?[i] ?? "about:blank")
                                .cornerRadius(20)
                        }
                    }.padding(.horizontal, 10)
                } else if !(Launch?.links?.flickrImages?.isEmpty ?? true) {
                    RemoteImage(url: Launch?.links?.flickrImages?[0] ?? "about:blank")
                        .cornerRadius(20)
                        .padding(15)
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
            }
        }.userActivity(useractivity, { activity in
            let theId = ((Launch?.id ?? "0") as String)
            activity.isEligibleForHandoff = true
            activity.isEligibleForSearch = false
            activity.persistentIdentifier = theId
            activity.referrerURL = URL(string: Launch?.links?.videoLink ?? "about:blank")
            activity.userInfo = ["msgraph.launch.id": [theId]]
            activity.keywords = [theId, Launch?.missionName ?? "spacex"]
            activity.setValue(theId, forKey: "persistentIdentifier")
            activity.targetContentIdentifier = theId
            activity.title = NSLocalizedString("View launch \(Launch?.missionName ?? "")", comment: "View Launch activity")
            logger.notice("Adding useractivity with id: \(theId, privacy: .public) on launch \(Launch?.missionName ?? "Geen mission Naam", privacy: .public)")
            activity.needsSave = true
            activity.becomeCurrent()
        })
    }
}


struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                EventView(Launch: LaunchListQuery.Data.LaunchesPast(missionName: "Starlink-15 (v1.0)", id: "109", details: "None", launchDateLocal: "2020-10-24T11:31:00-04:00", launchSite: LaunchListQuery.Data.LaunchesPast.LaunchSite(siteNameLong: "Cape Canaveral Air Force Station Space Launch Complex 40"), links: LaunchListQuery.Data.LaunchesPast.Link(videoLink: "https://youtu.be/J442-ti-Dhg", flickrImages: ["https://live.staticflickr.com/65535/50630802488_8cc373728e_o.jpg",    "https://live.staticflickr.com/65535/50631642722_3af8131c6f_o.jpg",         "https://live.staticflickr.com/65535/50631544171_66bd43eaa9_o.jpg", "https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg"]), rocket: LaunchListQuery.Data.LaunchesPast.Rocket(rocketName: "Falcon 9")))
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
            .previewDisplayName("4 Photos")
            NavigationView {
                EventView(Launch: LaunchListQuery.Data.LaunchesPast(missionName: "Starlink-15 (v1.0)", id: "109", details: "None", launchDateLocal: "2020-10-24T11:31:00-04:00", launchSite: LaunchListQuery.Data.LaunchesPast.LaunchSite(siteNameLong: "Cape Canaveral Air Force Station Space Launch Complex 40"), links: LaunchListQuery.Data.LaunchesPast.Link(videoLink: "https://youtu.be/J442-ti-Dhg", flickrImages: ["https://live.staticflickr.com/65535/50630802488_8cc373728e_o.jpg",    "https://live.staticflickr.com/65535/50631642722_3af8131c6f_o.jpg",         "https://live.staticflickr.com/65535/50631544171_66bd43eaa9_o.jpg", "https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg",
                                                                                                                                                                                                                                                                                                                                                                                                                             "https://live.staticflickr.com/65535/50631544171_66bd43eaa9_o.jpg",
                                                                                                                                                                                                                                                                                                                                                                                                                             "https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg",
                                                                                                                                                                                                                                                                                                                                                                                                                             "https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg"]), rocket: LaunchListQuery.Data.LaunchesPast.Rocket(rocketName: "Falcon 9")))
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
            .previewDisplayName("8 Photos")
            
        }
    }
}
