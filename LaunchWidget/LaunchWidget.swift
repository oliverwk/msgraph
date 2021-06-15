//
//  LaunchWidget.swift
//  LaunchWidget
//
//  Created by Olivier Wittop Koning on 15/06/2021.
//

import WidgetKit
import SwiftUI
import os

let logger = Logger(
    subsystem: "nl.wittopkoning.msgraph.LaunchWidget",
    category: "LaunchWidget"
)

let placeHolderLaunch = LaunchListQuery.Data.LaunchesPast(missionName: "Starlink-15 (v1.0) Placeholder", id: "109", details: "None", launchDateLocal: "2020-10-24T11:31:00-04:00", launchSite: LaunchListQuery.Data.LaunchesPast.LaunchSite(siteNameLong: "Cape Canaveral Air Force Station Space Launch Complex 40"), links: LaunchListQuery.Data.LaunchesPast.Link(videoLink: "https://youtu.be/J442-ti-Dhg", flickrImages: ["https://live.staticflickr.com/65535/50630802488_8cc373728e_o.jpg",
"https://live.staticflickr.com/65535/50631642722_3af8131c6f_o.jpg",
"https://live.staticflickr.com/65535/50631544171_66bd43eaa9_o.jpg",
"https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg",
"https://live.staticflickr.com/65535/50631544171_66bd43eaa9_o.jpg",
"https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg",
"https://live.staticflickr.com/65535/50631543966_e8035d5cca_o.jpg"]), rocket: LaunchListQuery.Data.LaunchesPast.Rocket(rocketName: "Falcon 9"))

struct Provider: TimelineProvider {
    func getTheData(completion: ((LaunchListQuery.Data.LaunchesPast) -> Void)?) {
        Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                let launch = graphQLResult.data?.launchesPast?[0]
                completion?(launch ?? placeHolderLaunch)
                print("Success! Result: \(String(describing: launch))")
            case .failure(let error):
                print("Failure! Error: \(error)")
                var errorLaunch = placeHolderLaunch
                errorLaunch.missionName = "Er was met GraphQL: \(error.localizedDescription)"
                completion?(errorLaunch)
            }
        }
    }
    
    func placeholder(in context: Context) -> LaunchEntry {
        LaunchEntry(date: Date(), Launch: placeHolderLaunch)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LaunchEntry) -> ()) {
        let entry = LaunchEntry(date: Date(), Launch: placeHolderLaunch)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        logger.info("[LOG] Making the timeline")
        var entries: [LaunchEntry] = []
        self.getTheData() { launch in
            logger.info("[LOG] Got the Data: \(launch.jsonObject.debugDescription, privacy: .public)")
            var entry: LaunchEntry
            let entryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            entry = LaunchEntry(date: entryDate, Launch: launch)
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
        /*// Generate a timeline consisting of five entries an hour apart, starting from the current date.
         let currentDate = Date()
         for hourOffset in 0 ..< 5 {
         let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
         let entry = LaunchEntry(date: entryDate, Launch: placeHolderLaunch)
         entries.append(entry)
         }
         
         let timeline = Timeline(entries: entries, policy: .atEnd)
         completion(timeline)*/
    }
}



struct LaunchEntry: TimelineEntry {
    let date: Date
    let Launch: LaunchListQuery.Data.LaunchesPast?
}

struct LaunchWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .center) {
            Text(entry.Launch?.missionName ?? "Geen missie naam")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(radius: 5)
                .padding(.vertical, 2.0)
                .multilineTextAlignment(.center)
            Text(Date(string: entry.Launch?.launchDateLocal ?? ""), style: .date)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(Color.secondary)
                .shadow(radius: 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(
            
            RemoteImage(url: (entry.Launch?.links?.flickrImages?.count ?? 0) > 0 ? entry.Launch?.links?.flickrImages?[0] ?? "" : "" , loading: Image("Falcon9"), failure: Image(systemName: "wifi.slash"), widget: true)
                .scaledToFill()
        )
    }
}

@main
struct LaunchWidget: Widget {
    let kind: String = "LaunchWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LaunchWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("SpaceX Launch Widget")
        .description("Met deze wiget kan de de recent spaceX launches zien.")
    }
}

struct LaunchWidget_Previews: PreviewProvider {
    static var previews: some View {
        LaunchWidgetEntryView(entry: LaunchEntry(date: Date(), Launch: placeHolderLaunch))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
        LaunchWidgetEntryView(entry: LaunchEntry(date: Date(), Launch: placeHolderLaunch))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
