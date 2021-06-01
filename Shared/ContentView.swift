//
//  ContentView.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 01/06/2021.
//

import SwiftUI

extension String: Identifiable {
    public var id: String { self }
}

struct ContentView: View {
    @ObservedObject private var launchData: LaunchListData = LaunchListData()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Spacer()
                List(launchData.missions) { site in
                    NavigationLink(destination: Text(site)) {
                        Text(site)
                    }
                }
            }
            .navigationTitle("SpaceX API")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class LaunchListData: ObservableObject {
    @Published var missions: [String]
    
    init() {
        print("running loadData")
        self.missions  = [String]()
        loadData()
    }
    
    func loadData() {
        Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                print(graphQLResult.data?.launchesPast! as Any)
                for launch in graphQLResult.data?.launchesPast ?? [] {
                    if launch != nil {
                        self.missions.append(launch?.missionName ?? "No Name")
                    }
                }
                
                print("Success! Result: \(String(describing: self.missions))")
            case .failure(let error):
                print("Failure! Error: \(error)")
            }
        }
    }
}
