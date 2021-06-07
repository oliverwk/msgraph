//
//  LoginCVWrapper.swift
//  snap
//
//  Created by Olivier Wittop Koning on 14/03/2021.
//

import MSAL
import Combine
import SwiftUI

struct LoginCVWrapper: UIViewControllerRepresentable {
    @Binding private var isPresented: Bool
    @StateObject private var authManger: MsAuthManger
    
    
    init(isPresented: Binding<Bool>, authManger: StateObject<MsAuthManger>) {
        _isPresented = isPresented
        _authManger = authManger
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let loginView = LoginViewController()
        loginView.delegate = context.coordinator
        return loginView
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // not used
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, LoginViewControlDelegate {
        let parent: LoginCVWrapper
        var authManger: MsAuthManger
        
        init(_ parent: LoginCVWrapper) {
            self.parent = parent
            self.authManger = parent.authManger
        }
        
        func UserDoneLogedin() {
            parent.$isPresented.wrappedValue.toggle()
        }
    }
}

protocol LoginViewControlDelegate : NSObjectProtocol {
    var authManger: MsAuthManger { get set }
    func UserDoneLogedin()
}

class LoginViewController: UIViewController {
    
    weak open var delegate: LoginViewControlDelegate?
    
    let kClientID = "9936360b-c0c5-4563-9c76-2ff4a6ed96fc"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kAuthority = "https://login.microsoftonline.com/common"
    let kRedirectUri = "msauth.nl.wittopkoning.authgraph://auth"
    
    let kScopes: [String] = ["user.read"]
    
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    
    var currentAccount: MSALAccount?
    var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try self.initMSAL()
            self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
        } catch let error {
            print("Unable to create Application Context \(error)")
            self.delegate?.authManger.ErrorMsg =  "[ERORR at initMSAL] Unable to create Application Context: \(error)"
        }
        
        self.loadCurrentAccount()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain) {
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.delegate?.authManger.ErrorMsg =  "Could not acquire token silently: \(error)"
                return
            }
            
            guard let result = result else {
                
                self.delegate?.authManger.ErrorMsg =  "Could not acquire token: No result returned"
                return
            }
            
            self.accessToken = result.accessToken
            DispatchQueue.main.async {
                self.delegate?.authManger.ErrorMsg =  "Refreshed Access token is \(self.accessToken)"
                self.delegate?.authManger.accessToken = result.accessToken
                self.delegate?.authManger.logedIn = true
                self.delegate?.authManger.getUserInfoWithToken()
                self.delegate?.UserDoneLogedin()
            }
        }
    }
    
    func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        
        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.delegate?.authManger.ErrorMsg =  "Could not acquire token: \(error)"
                return
            }
            
            guard let result = result else {
                
                self.delegate?.authManger.ErrorMsg =  "Could not acquire token: No result returned"
                return
            }
            
            self.accessToken = result.accessToken
            print("We have the item \(result)")
            DispatchQueue.main.async {
                self.delegate?.authManger.accessToken = result.accessToken
                self.currentAccount = result.account
                self.delegate?.authManger.getUserInfoWithToken()
                self.delegate?.UserDoneLogedin()
            }
        }
    }
    
    
    
    func loadCurrentAccount() {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
        
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.delegate?.authManger.ErrorMsg =  "Couldn't query current account with error: \(error)"
                return
            }
            
            if let currentAccount = currentAccount {
                self.delegate?.authManger.ErrorMsg =  "Found a signed in account \(currentAccount.username ?? "No user name"). Updating data for that account..."
                print("currentAccount", currentAccount.accountClaims?["name"] ?? "user name")
                self.acquireTokenSilently(currentAccount)
                // get token silently // zonder user input
                DispatchQueue.main.async {
                    self.delegate?.authManger.getUserInfoWithToken()
                    // Doe hier iets met graph api en ui updaten
                    self.delegate?.UserDoneLogedin()
                }
                return
            } else {
                self.accessToken = ""
                self.currentAccount = nil
                DispatchQueue.main.async {
                    self.delegate?.authManger.displayName = "Account is signed out"
                    self.delegate?.authManger.accessToken = ""
                }
                self.acquireTokenInteractively()
            }
        })
    }
    
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
            self.delegate?.authManger.ErrorMsg =  "Unable to create authority URL"
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID,
                                                                  redirectUri: kRedirectUri,
                                                                  authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        
    }
    
    func signOut() {
        
        guard let applicationContext = self.applicationContext else { return }
        
        guard let account = self.currentAccount else { return }
        
        do {
            
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters!)
            signoutParameters.signoutFromBrowser = false
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    self.delegate?.authManger.ErrorMsg = "Couldn't sign out account with error: \(error)"
                    return
                }
                DispatchQueue.main.async {
                    self.delegate?.authManger.ErrorMsg = "Sign out completed successfully"
                    self.accessToken = ""
                    self.delegate?.authManger.accessToken = ""
                    self.delegate?.authManger.currentAccount = nil
                }
            })
            
        }
    }
}

/*
 Update code
 DispatchQueue.main.async {
 print("Fetching User Data was Sucessful: { \"displayName\" \"\(me["displayName"] ?? "No name")\", \"url\":  \"\(bitmojiAvatarUrl ?? "No bitmojiAvatarUrl" )\" }")
 if let data = try? Data(contentsOf: URL(string: bitmojiAvatarUrl!)!) {
 if let image = UIImage(data: data) {
 self.delegate?.SnapUpdate(displayName: me["displayName"] as? String ?? "No Name", bitmojiAvatar: image)
 }
 }
 }
 */
