//
//  MsAuthManger.swift
//  snap
//
//  Created by Olivier Wittop Koning on 03/06/2021.
//

import MSAL
import Combine

class MsAuthManger: ObservableObject {
    
    public var AccessTokenCahnged = PassthroughSubject<Void, Never>()
    @Published var displayName: String = ""
    @Published var ErrorMsg: String = ""
    @Published var applicationContext: MSALPublicClientApplication?
    @Published var logedIn: Bool = false
    @Published var accessToken: String = ""  { didSet { AccessTokenCahnged.send() } }
    @Published var ProfilePicture: UIImage = UIImage()
    @Published var currentAccount: MSALAccount?
    @Published var CalendarTokenCallback: ((Date) -> Void)?
    @Published var GetTokenWithUICallback: (() -> Void)?
    @Published var webViewParamaters: MSALWebviewParameters?
    @Published var calendarFetcher: CalendarFetcher?
    
    let MsScopes: [String] = ["user.read", "calendars.read"]
    
    
    init() {
        print("Initing MsAuthManger")
        
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
        self.CalendarTokenCallback = CalendarTokenCallbackPlaceholder
        self.GetTokenWithUICallback = GetTokenWithUICallbackPlacerholder
        self.loadCurrentAccount()
    }
    
    func CalendarTokenCallbackPlaceholder(_ datum: Date) { print("hi, from TokenCallback") }
    func GetTokenWithUICallbackPlacerholder() { print("hi, from GetTokenWithUICallback") }
    
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
                self.acquireTokenSilently(account: currentAccount) {
                    self.getUserInfoWithToken()
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
    
    
    func acquireTokenSilently(account : MSALAccount!, complete: (() -> Void)?) {
        
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
                //self.ErrorMsg = "Refreshed Access token is \(self.accessToken)"
                complete!()
            }
        }
    }
    
    
    func getCalender() {
        
        // Specify the Graph API endpoint
//        let volgendeweek = Date().addingTimeInterval(604800)
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/calendarview?startdatetime=2021-06-07T15:26:05Z&enddatetime=2021-06-14T15:26:05Z")
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        print("Making request to /me with token: \(self.accessToken)")
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
                    self.logedIn = false
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

    func getUserInfoWithToken() {
        
        // Specify the Graph API endpoint
        let url = URL(string: "https://graph.microsoft.com/v1.0/me")
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        print("Making request to /me with token: \(self.accessToken)")
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
                    self.logedIn = false
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
                var image = UIImage(data: d)
                if let img = image {
                    
                    let targetSize = CGSize(width: 100, height: 100)
                    
                    // Compute the scaling ratio for the width and height separately
                    let widthScaleRatio = targetSize.width / (img.size.width)
                    let heightScaleRatio = targetSize.height / (img.size.height)
                    
                    // To keep the aspect ratio, scale by the smaller scaling ratio
                    let scaleFactor = min(widthScaleRatio, heightScaleRatio)
                    
                    // Multiply the original image’s dimensions by the scale factor
                    // to determine the scaled image size that preserves aspect ratio
                    let scaledImageSize = CGSize(
                        width: (img.size.width) * scaleFactor,
                        height: (img.size.height) * scaleFactor
                    )
                    let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
                    image = renderer.image { _ in
                        img.draw(in: CGRect(origin: .zero, size: scaledImageSize))
                    }
                } else {
                    image = UIImage(systemName: "person.fill")!
                }
                
                
                DispatchQueue.main.async {
                    self.ProfilePicture = image!
                }
            } else {
                print("No data with profile picture")
            }
        }.resume()
    }
}
