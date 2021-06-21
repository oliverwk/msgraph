//
//  LogOut.swift
//  snap
//
//  Created by Olivier Wittop Koning on 16/06/2021.
//

import MSAL

extension MsAuthManger {
    
    func signOut() {
        print("Singing Out")
        
        guard let applicationContext = self.applicationContext else { print("No applicationContext"); return }
        guard let account = self.currentAccount else { print("No currentAccount"); return }
        
        do {
            let signoutParameters = MSALSignoutParameters()
            signoutParameters.signoutFromBrowser = false
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    print("Couldn't sign out account with error: \(error)")
                    self.ErrorMsg = NSLocalizedString("Couldn't sign out account: \(error)", comment: "modal")
                } else {
                    print("Sign out completed successfully")
                    self.ErrorMsg = NSLocalizedString("Sign out completed successfully", comment: "modal")
                    self.accessToken = ""
                    self.logedIn = false
                    self.currentAccount = nil
                    self.displayName = ""
                    self.ProfilePicture = UIImage()
                    DispatchQueue.main.async {
                        self.calendarFetcher?.wrappedValue.CalendarEvents = []
                    }
                }
            })
        }
    }
}
