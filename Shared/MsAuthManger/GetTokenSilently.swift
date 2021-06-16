//
//  GetTokenSilently.swift
//  snap
//
//  Created by Olivier Wittop Koning on 16/06/2021.
//

import MSAL

extension MsAuthManger {
    
    func GetTokenSilently(account : MSALAccount!, complete: (() -> Void)?) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: MsScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain) {
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        DispatchQueue.main.async {
                            print("Needs action")
                            DispatchQueue.main.async {
                                self.logedIn = false
                            }
                            if let getTokenWithUICallback = self.GetTokenWithUICallback {
                                print("Calling GetTokenWithUICallback()")
                                getTokenWithUICallback()
                            }
                            //self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.ErrorMsg = "Could not acquire token silently: \(error)"
                DispatchQueue.main.async {
                    self.logedIn = false
                }
                return
            }
            
            guard let result = result else {
                DispatchQueue.main.async {
                    self.ErrorMsg = "Could not acquire token: No result returned"
                    self.logedIn = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.accessToken = result.accessToken
                DispatchQueue.main.async {
                    self.logedIn = true
                }
                // Dit laat ik niet zien want dat maakt het heel rommelig
                //self.ErrorMsg = "Refreshed Access token is \(self.accessToken)"
                complete!()
            }
        }
    }
}
