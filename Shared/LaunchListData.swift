//
//  LaunchListData.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 12/06/2021.
//

import CoreSpotlight
import MobileCoreServices
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
                self.index()
//                for launch in graphQLResult.data?.launchesPast ?? [] {
//                    if launch != nil {
//                        self.missions.append(launch?.missionName ?? "No Name")
//                        //print(launch?.jsonObject as Any)
//                    }
//                }
               
                print("Success! Result: \(String(describing: self.missions))")
            case .failure(let error):
                print("Failure! Error: \(error)")
            }
        }
    }
    
    func index() -> Void {
        let testing = false
        var idsToUserDefaults = [String]()
        let idsFromUserDefaults = UserDefaults.standard.object(forKey: "IdsIndexInSpotlight") as? [String] ?? [String]()
        idsToUserDefaults = idsFromUserDefaults
        print("idsFromUserDefaults:", idsFromUserDefaults)
        for i in (0..<(self.launches?.count ?? 0)) {
            let launch = self.launches?[i]
            let theId = ((launch?.id ?? UUID().uuidString) as String)
            if !idsFromUserDefaults.contains(theId) || testing {
                print("Indexing in spotlight:", launch?.missionName ?? "missionName")
                let attributeSet = MakeAttributeSet(launch)
                let item = CSSearchableItem(uniqueIdentifier: theId, domainIdentifier: "nl.wittopkoning.msgraph", attributeSet: attributeSet)
                CSSearchableIndex.default().indexSearchableItems([item]) { error in
                    if let error = error {
                        print("[SPOTLIGHT] [ERROR] Er was indexing error: \(error.localizedDescription)")
                    } else {
                        print("[SPOTLIGHT] Search item successfully indexed! \(launch.debugDescription)")
                        idsToUserDefaults.insert(theId, at: idsToUserDefaults.count)
                        UserDefaults.standard.set(idsToUserDefaults, forKey: "IdsIndexInSpotlight")
                        idsToUserDefaults = UserDefaults.standard.object(forKey: "IdsIndexInSpotlight") as? [String] ?? [String]()
                    }
                }
            } else {
                print("\(launch?.id ?? "No ID") is already indexed")
            }
        }
        print("idsToUserDefaults:",  UserDefaults.standard.object(forKey: "IdsIndexInSpotlight") as? [String] ?? [String]())
 
    }
    
    func MakeAttributeSet(_ launch: LaunchListQuery.Data.LaunchesPast?) -> CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = launch?.missionName
        attributeSet.contentDescription = launch?.details
        if !(launch?.links?.flickrImages?.isEmpty ?? true) {
            attributeSet.thumbnailURL = URL(string: launch?.links?.flickrImages?[0] ?? "about:blank")!
        }
        return attributeSet
    }
}
