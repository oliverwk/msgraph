//
//  loadCurrentAccount.swift
//  snap
//
//  Created by Olivier Wittop Koning on 16/06/2021.
//

import MSAL

extension MsAuthManger {
    
    func loadCurrentAccount(CalledFromLoginModal: Bool? = false) {
        print("CalledFromLoginModal: \(String(describing: CalledFromLoginModal))")
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
        
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.ErrorMsg = "Couldn't query current account with error: \(error)"
                return
            }
            
            if let currentAccount = currentAccount {
                self.ErrorMsg = "Found a signed in account \(currentAccount.username ?? "No user name")."
                print("currentAccount", currentAccount.accountClaims?["name"] ?? "user name")
                self.currentAccount = currentAccount
                self.logedIn = true
                self.GetTokenSilently(account: currentAccount) {
                    self.GetMe()
                    if let calendarTokenCallback = self.CalendarTokenCallback {
                        print("calling CalendarTokenCallback")
                        calendarTokenCallback(Date().addingTimeInterval(604800))
                    }
                }
                return
            } else {
                self.displayName = ""
                self.ProfilePicture = UIImage()
                self.accessToken = ""
                self.currentAccount = nil
                self.logedIn = false
                self.ErrorMsg = "Account is signed out"
                if let calledFromLoginModal = CalledFromLoginModal {
                    if calledFromLoginModal {
                        if let getTokenWithUICallback = self.GetTokenWithUICallback {
                            print("Calling GetTokenWithUICallback()")
                            getTokenWithUICallback()
                        }
                    }
                }
            }
        })
    }
}
