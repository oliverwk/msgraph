//
//  snapApp.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 14/03/2021.
//

import SwiftUI
import MSAL

@main
struct snapApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL(perform: { url in
                    if MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil) {
                        print("We can handle the url")
                    } else {
                        print("We can't handle the url: \(url)")
                    }
                })
                .onAppear(perform: {
                    MSALGlobalConfig.loggerConfig.setLogCallback { (logLevel, message, containsPII) in
                        if let displayableMessage = message {
                            if (!containsPII) {
                                #if DEBUG
                                print(displayableMessage)
                                #endif
                            }
                        }
                    }
                })
        }
    }
}
