//
//  DataFetcher.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 27/05/2021.
//

import Foundation

class DataFetcher: ObservableObject {
    
    @Published var result: [LaunchListQuery.Data.LaunchesPast]
    
    private func GetTheData() {
      Network.shared.apollo.fetch(query: LaunchListQuery()) { [weak self] result in

          switch result {
          case .success(let graphQLResult): break
            DispatchQueue.main.async {
                self?.result = graphQLResult.data?.launchesPast as! [LaunchListQuery.Data.LaunchesPast]
            }
          case .failure(let error):
            print("Network Error", error.localizedDescription)
          }
      }
    }
    /*
    func LoadLaunches(Query: String) -> LaunchListQuery.Data.LaunchesPast {
        Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                print("Success! Result: \(graphQLResult)")
                return graphQLResult
            case .failure(let error):
                print("Failure! Error: \(error)")
                return error
            }
        }
    }*/
    
    init() {
        result = [LaunchListQuery.Data.LaunchesPast(missionName: "StarLink", launchDateLocal: "2020-10-24T11:31:00-04:00", launchSite: LaunchListQuery.Data.LaunchesPast.LaunchSite(siteNameLong: "Cape Canaveral Air Force Station Space Launch Complex 40"), links: LaunchListQuery.Data.LaunchesPast.Link(videoLink: "about:blank"), rocket: LaunchListQuery.Data.LaunchesPast.Rocket(rocketName: "Falcon 9", secondStage: LaunchListQuery.Data.LaunchesPast.Rocket.SecondStage(payloads: [LaunchListQuery.Data.LaunchesPast.Rocket.SecondStage.Payload(payloadType: "Satellite", payloadMassKg: 1440.0)])))]
    }
}
