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
            parent.$isPresented.wrappedValue.toggle()
            parent.ProfilePicture = ProfilePicture
            parent.$logedIn.wrappedValue.toggle()
            parent.token = token
        }
        
        func DisplayError(msg: String) {
            parent.displayName = msg
            parent.$isPresented.wrappedValue.toggle()
            parent.$logedIn.wrappedValue = false
        }
    }
}

public protocol LoginViewControlDelegate : NSObjectProtocol {
    func SnapUpdate(displayName: String, ProfilePicture: UIImage, token: String)
    func DisplayError(msg: String)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try self.initMSAL()
        } catch let error {
            print("Unable to create Application Context \(error)")
            self.delegate?.DisplayError(msg: "[ERORR at initMSAL] Unable to create Application Context: \(error)")
        }
        
        self.loadCurrentAccount()
        // platformViewDidLoadSetup
//        NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeGround(notification:)),name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.loadCurrentAccount()
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
                
                self.delegate?.DisplayError(msg: "Found a signed in account \(String(describing: currentAccount.username)). Updating data for that account...")
                return
            } else {
                self.accessToken = ""
                self.currentAccount = nil
                self.delegate?.SnapUpdate(displayName: "Account signed out", ProfilePicture: UIImage(), token: "")
                return
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
        self.initWebViewParams()
    }
    
    func initWebViewParams() {
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
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
