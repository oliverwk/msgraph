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
//    @StateObject private var authManger = MsAuthManger()
    
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
//                .environmentObject(authManger)
                .onAppear(perform: {
                    MSALGlobalConfig.loggerConfig.setLogCallback { (logLevel, message, containsPII) in
                        
                        // If PiiLoggingEnabled is set YES, this block will potentially contain sensitive information (Personally Identifiable Information), but not all messages will contain it.
                        // containsPII == YES indicates if a particular message contains PII.
                        // You might want to capture PII only in debug builds, or only if you take necessary actions to handle PII properly according to legal requirements of the region
                        if let displayableMessage = message {
                            if (!containsPII) {
                                #if DEBUG
                                // NB! This sample uses print just for testing purposes
                                // You should only ever log to NSLog in debug mode to prevent leaking potentially sensitive information
                                print(displayableMessage)
                                #endif
                            }
                        }
                    }
                })
        }
    }
}
