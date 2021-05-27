//
//  DataFetcher.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 27/05/2021.
//

import Foundation
public class DataFetcher: ObservableObject {
    
    @Published var result: LaunchesPast
    
    func GetTheData(Query: GraphQLQuery) -> LaunchesPast {
        Network.shared.apollo.fetch(query: Query) { result in
            switch result {
            case .success(let graphQLResult):
                print("Success! Result: \(graphQLResult)")
                return graphQLResult
            case .failure(let error):
                print("Failure! Error: \(error)")
                return error
            }
        }
    }
    init() {
        var res = GetTheData(LaunchListQuery())
        if type(of: res) ==  LaunchesPast {
            DispatchQueue.main.async {
                self.result = res
            }
        }
    }
}
