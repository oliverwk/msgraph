//
//  msgraphApp.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 25/05/2021.
//

import SwiftUI

@main
struct msgraphApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}
