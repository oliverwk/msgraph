//
//  LaunchRowView.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 27/05/2021.
//

import SwiftUI
import os

struct LaunchRowView: View {

    @State var selectedImage: String? = ""

    let logger = Logger(
        subsystem: "nl.wittopkoning.msgraph",
        category: "EventView"
    )
    
    var Launch: LaunchListQuery.Data.LaunchesPast?
    let useractivity = "nl.wittopkoning.msgraph.view-launch"

    
    var body: some View {
        VStack {
            ScrollView {
                if ((Launch?.links?.flickrImages?.count ?? 0) <= 5) {
                    LaunchImages(launch: Launch, iterations: (Launch?.links?.flickrImages?.count ?? 4), selectedImage: $selectedImage)
                } else /*if ((Launch?.links?.flickrImages?.count ?? 0) >= 4) {
                    LaunchImages(launch: Launch, iterations: 4)
                } else*/ if !(Launch?.links?.flickrImages?.isEmpty ?? true) {
                    LaunchImage(selectedImage: $selectedImage, launch: Launch)
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
        }.userActivity(useractivity) { activity in
            let theId = ((self.Launch?.id ?? "0") as String)
            activity.isEligibleForHandoff = true
            activity.isEligibleForSearch = false
            activity.persistentIdentifier = theId
            activity.referrerURL = URL(string: self.Launch?.links?.videoLink ?? "about:blank")
            activity.userInfo = ["msgraph.launch.id": [theId]]
            activity.keywords = [theId, self.Launch?.missionName ?? "spacex"]
            activity.setValue(theId, forKey: "persistentIdentifier")
            activity.targetContentIdentifier = theId
            activity.title = NSLocalizedString("View launch \(self.Launch?.missionName ?? "")", comment: "View Launch activity")
            logger.notice("Adding useractivity with id: \(theId, privacy: .public) on launch \(self.Launch?.missionName ?? "Geen mission Naam", privacy: .public)")
            activity.needsSave = true
            activity.becomeCurrent()
        }
    }
}


let PlaceholderLaunch = LaunchListQuery.Data.LaunchesPast(missionName: "Starlink-15 (v1.0)", id: "109", details: "None", launchDateLocal: "2020-10-24T11:31:00-04:00", launchSite: LaunchListQuery.Data.LaunchesPast.LaunchSite(siteNameLong: "Cape Canaveral Air Force Station Space Launch Complex 40"), links: LaunchListQuery.Data.LaunchesPast.Link(videoLink: "https://youtu.be/J442-ti-Dhg", flickrImages: ["https://live.staticflickr.com/65535/50630802488_8cc373728e_o.jpg",    "https://live.staticflickr.com/65535/50631642722_3af8131c6f_o.jpg",         "https://live.staticflickr.com/65535/50631544171_66bd43eaa9_o.jpg", "https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg"]), rocket: LaunchListQuery.Data.LaunchesPast.Rocket(rocketName: "Falcon 9"))

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                LaunchRowView(Launch: PlaceholderLaunch)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
            .previewDisplayName("4 Photos")
            NavigationView {
                LaunchRowView(Launch: LaunchListQuery.Data.LaunchesPast(missionName: "Starlink-15 (v1.0)", id: "109", details: "None", launchDateLocal: "2020-10-24T11:31:00-04:00", launchSite: LaunchListQuery.Data.LaunchesPast.LaunchSite(siteNameLong: "Cape Canaveral Air Force Station Space Launch Complex 40"), links: LaunchListQuery.Data.LaunchesPast.Link(videoLink: "https://youtu.be/J442-ti-Dhg", flickrImages: ["https://live.staticflickr.com/65535/50630802488_8cc373728e_o.jpg",    "https://live.staticflickr.com/65535/50631642722_3af8131c6f_o.jpg",         "https://live.staticflickr.com/65535/50631544171_66bd43eaa9_o.jpg", "https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg",
                                                                                                                                                                                                                                                                                                                                                                                                                             "https://live.staticflickr.com/65535/50631544171_66bd43eaa9_o.jpg",
                                                                                                                                                                                                                                                                                                                                                                                                                             "https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg",
                                                                                                                                                                                                                                                                                                                                                                                                                             "https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg"]), rocket: LaunchListQuery.Data.LaunchesPast.Rocket(rocketName: "Falcon 9")))
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
            .previewDisplayName("8 Photos")
            
        }
    }
}
