//
//  LogoutViewControllerRepresentable.swift
//  snap
//
//  Created by Olivier Wittop Koning on 04/06/2021.
//


import SwiftUI
import UIKit


struct LogoutViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding private var isPresented: Bool
    @StateObject private var authManger: MsAuthManger
    
    init(isPresented: Binding<Bool>, authManger: StateObject<MsAuthManger>) {
        _isPresented = isPresented
        _authManger = authManger
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let logoutView = LogoutViewController()
        logoutView.delegate = context.coordinator
        return logoutView
    }
    
    func updateUIViewController(_ UIView: UIViewController, context: Context) {
        // not used
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, LogoutViewControlDelegate {
        var authManger: MsAuthManger
        
        var parent: LogoutViewControllerRepresentable
        
        
        init(_ parent: LogoutViewControllerRepresentable) {
            self.parent = parent
            self.authManger = self.parent.authManger
        }
        
        func UserDoneLogedOut() {
            parent.$isPresented.wrappedValue.toggle()
        }
    }
}

protocol LogoutViewControlDelegate : NSObjectProtocol {
    var authManger: MsAuthManger { get set }
    func UserDoneLogedOut()
}
