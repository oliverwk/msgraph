//
//  Network.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 27/05/2021.
//
// SpaceX api https://api.spacex.land/graphql

import Apollo
class Network {
  static let shared = Network()
    
  private(set) lazy var apollo = ApolloClient(url: URL(string: "https://api.spacex.land/graphql")!)
}

