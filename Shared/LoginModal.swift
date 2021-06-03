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
    @Binding private var displayName: String
    @Binding private var isPresented: Bool
    @Binding private var ProfilePicture: UIImage
    @Binding private var logedIn: Bool
    @Binding private var token: String
    
    
    init(displayName: Binding<String>, isPresented: Binding<Bool>, ProfilePicture: Binding<UIImage>, logedIn: Binding<Bool>, token: Binding<String>) {
        _displayName = displayName
        _isPresented = isPresented
        _ProfilePicture = ProfilePicture
        _logedIn = logedIn
        _token = token
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let loginView = LoginViewController()
        loginView.delegate = context.coordinator
        return loginView
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //not used
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, LoginViewControlDelegate {
        let parent: LoginCVWrapper
        
        init(_ parent: LoginCVWrapper) {
            self.parent = parent
        }
        
        func SnapUpdate(displayName: String, ProfilePicture: UIImage, token: String) {
            parent.displayName = displayName
            parent.ProfilePicture = ProfilePicture
            parent.token = token
        }
        
        func UserDoneLogedin() {
            parent.$isPresented.wrappedValue.toggle()
            parent.$logedIn.wrappedValue.toggle()
        }
        
        func UserLogedin() {
            parent.$logedIn.wrappedValue.toggle()
        }
        
        func DisplayError(msg: String) {
            parent.displayName = msg
            parent.$logedIn.wrappedValue = false
        }
    }
}

public protocol LoginViewControlDelegate : NSObjectProtocol {
    func SnapUpdate(displayName: String, ProfilePicture: UIImage, token: String)
    func DisplayError(msg: String)
    func UserDoneLogedin()
    func UserLogedin()
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
            // self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
        } catch let error {
            print("Unable to create Application Context \(error)")
            self.delegate?.DisplayError(msg: "[ERORR at initMSAL] Unable to create Application Context: \(error)")
        }
        
        self.loadCurrentAccount()
        
        // func platformViewDidLoadSetup()
        // NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeGround(notification:)),name: UIApplication.willEnterForegroundNotification, object: nil)

        signOutButton = UIButton()
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.setTitle("SignIn", for: .normal)
        signOutButton.setTitleColor(.blue, for: .normal)
        signOutButton.setTitleColor(.gray, for: .disabled)
        signOutButton.addTarget(self, action: #selector(signIn(_:)), for: .touchUpInside)
        self.view.addSubview(signOutButton)
        
        //signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.center = self.view.center
        //signOutButton.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        //signOutButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
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
                
                self.delegate?.DisplayError(msg: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.delegate?.DisplayError(msg: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            self.delegate?.DisplayError(msg: "Refreshed Access token is \(self.accessToken)")
            self.delegate?.UserLogedin()
            self.getUserInfoWithToken()
        }
    }
    
    func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        
        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.delegate?.DisplayError(msg: "Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.delegate?.DisplayError(msg: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            print("We have the item \(result)")
            self.delegate?.SnapUpdate(displayName: "", ProfilePicture: UIImage(), token: result.accessToken)
            self.currentAccount = result.account
            self.getUserInfoWithToken()
            print("Exiting now")
            
        }
    }
    
    func getUserInfoWithToken() {
        
        // Specify the Graph API endpoint
        let url = URL(string: "\(kGraphEndpoint)v1.0/me")
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.delegate?.DisplayError(msg: "Couldn't get graph result: \(error)")
                return
            }
            var result: Any
            do {
                result = try JSONSerialization.jsonObject(with: data!, options: [])
                print("Result from Graph: \(result)")
                //self.delegate?.DisplayError(msg: "Result from Graph: \(result))")
                if let displayName = (result as AnyObject)["displayName"] as? String {
                    print(displayName)
                    self.delegate?.SnapUpdate(displayName: displayName, ProfilePicture: UIImage(), token: self.accessToken)
                    self.delegate?.UserDoneLogedin()
                } else {
                    print("No displayName")
                }
            } catch {
                print("Response:", response ?? "no response")
                print("Couldn't deserialize result JSON with data \(String(decoding: data!, as: UTF8.self)):", error)
                self.delegate?.DisplayError(msg: "Couldn't deserialize result JSON")
                self.delegate?.UserDoneLogedin()
            }
        }.resume()
    }
    
    func loadCurrentAccount() {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
        
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.delegate?.DisplayError(msg: "Couldn't query current account with error: \(error)")
                return
            }
            
            if let currentAccount = currentAccount {
                self.delegate?.DisplayError(msg: "Found a signed in account \(currentAccount.username ?? "No user name"). Updating data for that account...")
                print("currentAccount", currentAccount.accountClaims?["name"] ?? "user name")
                self.acquireTokenSilently(currentAccount)
                // get token silently // zonder user input

                self.getUserInfoWithToken()
                // Doe hier iets met graph api en ui updaten
                self.delegate?.UserDoneLogedin()
                return
            } else {
                self.accessToken = ""
                self.currentAccount = nil
                self.delegate?.SnapUpdate(displayName: "Account is signed out", ProfilePicture: UIImage(), token: "")
                //UserDoneLogedin()
            }
        })
    }
    
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
            self.delegate?.DisplayError(msg: "Unable to create authority URL")
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID,
                                                                  redirectUri: kRedirectUri,
                                                                  authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        
    }
    @objc func signIn(_ sender: UIButton) {
        self.acquireTokenInteractively()
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
