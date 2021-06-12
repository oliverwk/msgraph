//
//  LaunchListData.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 12/06/2021.
//

import Foundation
import Combine

class LaunchListData: ObservableObject {
    @Published var missions: [String]
    @Published var launches: [LaunchListQuery.Data.LaunchesPast?]?
    
    init() {
        print("running loadData")
        self.missions  = [String]()
        loadData()
    }
    
    func loadData() {
        Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                self.launches = graphQLResult.data?.launchesPast ?? []
                for launch in graphQLResult.data?.launchesPast ?? [] {
                    if launch != nil {
                        self.missions.append(launch?.missionName ?? "No Name")
                        //print(launch?.jsonObject as Any)
                    }
                }
                print("Success! Result: \(String(describing: self.missions))")
            case .failure(let error):
                print("Failure! Error: \(error)")
            }
        }
    }
}
