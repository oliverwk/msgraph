//
//  ContentView.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 25/05/2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var text: String = "Nothing"
    @StateObject var DataFetch: DataFetcher = DataFetcher()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(DataFetch.result) { event in
                    EventView(event: event)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
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


 VStack {
 Button("Get the data") {
 let threst = DataFetch.GetTheData()
 print(threst)
 text = "\(threst)"
 }
 Text($text)
 }
 */
