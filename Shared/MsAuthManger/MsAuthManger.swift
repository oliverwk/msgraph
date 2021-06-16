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
    
}
