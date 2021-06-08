//
//  LogOutView.swift
//  snap
//
//  Created by Olivier Wittop Koning on 03/06/2021.
//

import MSAL
import UIKit
import Combine
import SwiftUI


class LogoutViewController: UIViewController {
    weak open var delegate: LogoutViewControlDelegate?
    open var isPresented: Binding<Bool>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.delegate?.authManger.displayName != "" {
            signOut()
        } else {
            self.delegate?.authManger.ErrorMsg = "Singed out please restart the app"
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func signOut() {
        print("Singing Out")
        
        guard let applicationContext = self.delegate?.authManger.applicationContext else { print("No applicationContext"); return }
        guard let account = self.delegate?.authManger.currentAccount else { print("No currentAccount"); return }
        
        do {
            let signoutParameters = MSALSignoutParameters()
            signoutParameters.signoutFromBrowser = false
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    print("Couldn't sign out account with error: \(error)")
                    self.delegate?.authManger.ErrorMsg = "Couldn't sign out account: \(error)"
                    self.delegate?.UserDoneLogedOut()
                } else {
                    print("Sign out completed successfully")
                    self.delegate?.authManger.ErrorMsg = "Sign out completed successfully"
                    self.delegate?.authManger.accessToken = ""
                    self.delegate?.authManger.logedIn = false
                    self.delegate?.authManger.currentAccount = nil
                    self.delegate?.authManger.displayName = ""
                    self.delegate?.authManger.ProfilePicture = UIImage()
                    DispatchQueue.main.async {
                        self.delegate?.authManger.calendarFetcher?.CalendarEvents = []
                    }
                    self.delegate?.UserDoneLogedOut()
                }
            })
        }
    }
}
