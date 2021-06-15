//
//  IntentHandler.swift
//  GetLaunches
//
//  Created by Olivier Wittop Koning on 13/06/2021.
//

import Intents
import Foundation

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        //        print(ViewLaunches)
        guard intent is ViewLaunchesIntent else {
            // Dit kan eigelijk niet gebeuren
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return ViewLaunchesIntentHandler()
    }
    
}

public class ViewLaunchesIntentHandler: NSObject, ViewLaunchesIntentHandling {
    
    public func handle(intent: ViewLaunchesIntent, completion: @escaping (ViewLaunchesIntentResponse) -> Void) {
        Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                let launch = graphQLResult.data?.launchesPast?[0]
                let launchDate = self.StringToDate(launch?.launchDateLocal ?? "")
                let theLaunch = Launch(identifier: launch?.id, display: "De \(launch?.missionName ?? "missie naam") was gelanceerd met de raket \(launch?.rocket?.rocketName ?? "raket naam") op \(self.DateToLocalString(launchDate)) vanaf \(launch?.launchSite?.siteNameLong ?? "Lanceer platform"))")
                theLaunch.launchSite = launch?.launchSite?.siteNameLong
                theLaunch.missionName = launch?.missionName
                theLaunch.launched = launchDate
                theLaunch.rocketName = launch?.rocket?.rocketName
                
                completion(.success(launch: theLaunch))
                print("Success! Result: \(String(describing: launch))")
            case .failure(let error):
                print("Failure! Error: \(error)")
                completion(.init(code: .failure, userActivity: NSUserActivity(activityType: "")))
            }
        }
    }
    
    func DateToLocalString(_ launchDate: DateComponents) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        //formatter.locale = Locale.current
        formatter.locale = Locale(identifier: "nl_NL")

        let dateTimeString = formatter.string(from: Calendar.current.date(from: launchDate)!)
        return dateTimeString
    }
    
    func StringToDate(_ date: String) -> DateComponents {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        //   From Spacex API    2020-10-24T11:31:00-04:00
        //   From Example       13-03-2020 13:37:00 +0100
        let TheDate = date.split(usingRegex: "-\\d\\d:\\d\\d")[0]
        print("current date: \(date) current dateComponetns: \(String(describing: formatter.date(from: TheDate)))")
        print("TheDate:", date.split(usingRegex: "-\\d\\d:\\d\\d")[0])
        let datetime = formatter.date(from: TheDate)
        return Calendar.current.dateComponents([.year, .month, .day], from: datetime ?? Date())
    }
}


extension String {
    func split(usingRegex pattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
        let ranges = [startIndex..<startIndex] + matches.map{Range($0.range, in: self)!} + [endIndex..<endIndex]
        return (0...matches.count).map {String(self[ranges[$0].upperBound..<ranges[$0+1].lowerBound])}
    }
}
