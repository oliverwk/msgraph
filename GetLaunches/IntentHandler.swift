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
                let launchDate = Date(string: launch?.launchDateLocal ?? NSLocalizedString("no date", comment: "geen datum"))
                let mNaam = NSLocalizedString("No mission", comment: "Geen missie naam")
                let rNaam = NSLocalizedString("No rocket name", comment: "Geen raket naam")
                let pNaam = NSLocalizedString("No launch platform", comment: "Geen launch")
                let displayName = NSLocalizedString("The \(launch?.missionName ?? mNaam) was launched with the rocket \(launch?.rocket?.rocketName ?? rNaam) at \(launchDate.toString()) from \(launch?.launchSite?.siteNameLong ?? pNaam)", comment: "ViewLaunchesIntentHandler Display Name")
                let theLaunch = Launch(identifier: launch?.id, display: displayName)
                theLaunch.launchSite = launch?.launchSite?.siteNameLong
                theLaunch.missionName = launch?.missionName
                theLaunch.launched = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: launchDate)
                theLaunch.rocketName = launch?.rocket?.rocketName
                
                completion(.success(launch: theLaunch))
                print("Success! Result: \(String(describing: launch))")
            case .failure(let error):
                print("Failure! Error: \(error)")
                completion(.init(code: .failure, userActivity: NSUserActivity(activityType: "")))
            }
        }
    }
}
