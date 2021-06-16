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
        var isPresented: Bool
        
        init(_ parent: LoginCVWrapper) {
            self.parent = parent
            self.authManger = parent.authManger
            self.isPresented = parent.isPresented
        }
        
        func UserDoneLogedin() {
            parent.$isPresented.wrappedValue.toggle()
            self.authManger.webViewParamaters = nil
        }
    }
}

protocol LoginViewControlDelegate : NSObjectProtocol {
    var authManger: MsAuthManger { get set }
    var isPresented: Bool { get set }
    func UserDoneLogedin()
}

class LoginViewController: UIViewController {
    
    weak open var delegate: LoginViewControlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate?.authManger.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
        self.delegate?.authManger.GetTokenWithUICallback = acquireTokenInteractively
        self.delegate?.authManger.loadCurrentAccount(CalledFromLoginModal: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func acquireTokenInteractively() {
        print("acquiring Token Interactively")
        if let del = self.delegate {
            if !del.isPresented {
                del.isPresented = true
            }
        } else {
            print("No delegate")
        }
        
        guard let applicationContext = self.delegate?.authManger.applicationContext else { return }
        guard let webViewParameters = self.delegate?.authManger.webViewParamaters else { return }
        
        let parameters = MSALInteractiveTokenParameters(scopes: self.delegate?.authManger.MsScopes ?? ["user.read", "calendars.read"], webviewParameters: webViewParameters)
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
            
            self.delegate?.authManger.accessToken = result.accessToken
            print("We have the item: \(result)")
            DispatchQueue.main.async {
                self.delegate?.authManger.accessToken = result.accessToken
                self.delegate?.authManger.currentAccount = result.account
                self.delegate?.authManger.ErrorMsg = "Signed in an account \(result.account.username ?? "No username")."
                self.delegate?.authManger.GetMe()
                if let calendarTokenCallback = self.delegate?.authManger.CalendarTokenCallback {
                    print("calling CalendarTokenCallback")
                    calendarTokenCallback(Date().addingTimeInterval(604800))
                }
                self.delegate?.UserDoneLogedin()
            }
        }
    }
}
