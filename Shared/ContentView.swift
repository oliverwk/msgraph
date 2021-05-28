//
//  ContentView.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 25/05/2021.
//

import SwiftUI

struct ContentView: View {
    // SpaceX api https://api.spacex.land/graphql

    @State private var text: String = "Nothing"
    @StateObject private var DataFetch: DataFetcher
    var body: some View {
        NavigationView {

            VStack {
                Button("Get the data") {
                    let threst = DataFetch.GetTheData()
                    print(threst)
                    text = "\(threst)"
                }
                Text($text)
            }
            List {
                ForEach(DataFetch.result) { event in
                    EventView(event)
                }
            }.navigationBarTitle(Text(title))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func GetDataGraph() -> Void {
    Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
        switch result {
        case .success(let graphQLResult):
            print("Success! Result: \(graphQLResult)")
        case .failure(let error):
            print("Failure! Error: \(error)")
        }
    }
}
