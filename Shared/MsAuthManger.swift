//
//  MsAuthManger.swift
//  snap
//
//  Created by Olivier Wittop Koning on 03/06/2021.
//

import MSAL

class MsAuthManger: ObservableObject {
    
    @Published var displayName: String = ""
    @Published var ErrorMsg: String = ""
    @Published var applicationContext: MSALPublicClientApplication?
    @Published var logedIn: Bool = false
    @Published var accessToken: String = ""
    @Published var ProfilePicture: UIImage = UIImage()
    var currentAccount: MSALAccount?
    let MsScopes: [String] = ["user.read"]
    
    
    init() {
        print("init")
        let authorityURL = URL(string: "https://login.microsoftonline.com/common")!
        let ClientID = "9936360b-c0c5-4563-9c76-2ff4a6ed96fc"
        let RedirectUri = "msauth.nl.wittopkoning.authgraph://auth"
        do {
            let authority = try MSALAADAuthority(url: authorityURL)
            let msalConfiguration = MSALPublicClientApplicationConfig(clientId: ClientID, redirectUri: RedirectUri, authority: authority)
            self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
            
        } catch {
            self.ErrorMsg = "Error At init \(error)"
        }
        self.loadCurrentAccount()
    }
    
    func loadCurrentAccount() {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
        
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.ErrorMsg = "Couldn't query current account with error: \(error)"
                return
            }
            
            if let currentAccount = currentAccount {
                self.ErrorMsg = "Found a signed in account \(currentAccount.username ?? "No user name"). Updating data for that account..."
                print("currentAccount", currentAccount.accountClaims?["name"] ?? "user name")
                self.acquireTokenSilently(currentAccount)
                // Hier completion doen
                self.getUserInfoWithToken()
                return
            } else {
                self.accessToken = ""
                self.currentAccount = nil
                self.ErrorMsg = "Account is signed out"
            }
        })
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
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
                            //self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.ErrorMsg = "Could not acquire token silently: \(error)"
                return
            }
            
            guard let result = result else {
                self.ErrorMsg = "Could not acquire token: No result returned"
                return
            }
            
            DispatchQueue.main.async {
                self.accessToken = result.accessToken
                self.ErrorMsg = "Refreshed Access token is \(self.accessToken)"
            }
            
            self.getUserInfoWithToken()
        }
    }
    
    func getUserInfoWithToken() {
        
        // Specify the Graph API endpoint
        let url = URL(string: "https://graph.microsoft.com/v1.0/me")
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        print("Making reqeust to /me with token: \(self.accessToken)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                var output = ""
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 403 {
                        output = "Acces token isn't good"
                        // Hier Dan get token callen
                    } else {
                        output = "Couldn't get graph result: \(error)"
                    }
                }
                DispatchQueue.main.async {
                    self.ErrorMsg = output
                }
                return

            } else {
                var result: Any
                do {
                    result = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("Result from Graph: \(result)")
                    self.GetPhoto()
                    
                    //self.delegate?.DisplayError(msg: "Result from Graph: \(result))")
                    if let displayName = (result as AnyObject)["displayName"] as? String {
                        print(displayName)
                        DispatchQueue.main.async {
                            self.logedIn = true
                            self.displayName = displayName // ProfilePicture: UIImage()
                        }
                    } else {
                        print("No displayName")
                    }
                } catch {
                    print("Response:", response ?? "no response")
                    print("Couldn't deserialize result JSON with data \(String(decoding: data!, as: UTF8.self)):", error)
                    self.ErrorMsg = "Couldn't deserialize result JSON"
                }
            }
        }.resume()
        
    }
    
    func GetPhoto() {
        // Specify the Graph API endpoint
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/photo/$value")
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.ErrorMsg = "Couldn't get graph result: \(error)"
                return
            }
            
            if let d = data {
                DispatchQueue.main.async {
                    self.ProfilePicture = UIImage(data: d) ?? UIImage(systemName: "person.fill")!
                }
            } else {
                print("No data with profile picture")
            }
        }.resume()
    }
}
