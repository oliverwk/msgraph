//
//  LogOutView.swift
//  Pods
//
//  Created by Maarten Wittop Koning on 03/06/2021.
//

import MSAL
import UIKit
import Combine
import SwiftUI

class LogoutViewController: UIViewController {
    @StateObject private var authManger: MsAuthManger
    @Binding private var isPresented: Bool
    private var webViewParamaters: MSALWebviewParameters
    
    init(authManger: StateObject<MsAuthManger>, isPresented: Binding<Bool>) {
        self._authManger = authManger
        self._isPresented = isPresented
        self._webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signOut()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func signOut() {
        print("Singing Out")
        guard let applicationContext = self.authManger.applicationContext else { return }
        
        guard let account = self.authManger.currentAccount else { return }
        
        do {
            
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters)
            signoutParameters.signoutFromBrowser = false
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    self.authManger.ErrorMsg = "Couldn't sign out account with error: \(error)"
                    return
                } else {
                    self.authManger.ErrorMsg = "Sign out completed successfully"
                    self.authManger.accessToken = ""
                    self.authManger.currentAccount = nil
                }
                self.$isPresented.wrappedValue.toggle()
            })
        }
    }
}
