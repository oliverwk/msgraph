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
    @ObservedObject private var authManger: MsAuthManger
    
    
    init(isPresented: Binding<Bool>, authManger: ObservedObject<MsAuthManger>) {
        _isPresented = isPresented
        _authManger = authManger
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let logoutView = LogoutViewController()
        logoutView.delegate = context.coordinator
        return logoutView
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // not used
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, LogoutViewControlDelegate {
        let parent: LogoutViewControllerRepresentable
        var authManger: MsAuthManger
        
        init(_ parent: LogoutViewControllerRepresentable) {
            self.parent = parent
            self.authManger = parent.authManger
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
