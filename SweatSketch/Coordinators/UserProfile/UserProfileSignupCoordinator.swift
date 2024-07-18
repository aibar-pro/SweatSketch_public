//
//  UserProfileSignupCoordinator.swift
//  SweatSketch
//
//  Created by aibaranchikov on 27.06.2024.
//

import Foundation
import UIKit
import SwiftUI

class UserProfileSignupCoordinator: Coordinator {
    var rootViewController = UIViewController()
    weak var delegate: UserProfileCoordinatorDelegate?

    func start() {
        let signupView = UserProfileSignupView(
            onSignup: { [weak self] user in
                self?.handleSignup(user: user)
            },
            onDismiss: { [weak self] in
                
            },
            onLogin: { [weak self] in
                self?.rootViewController.dismiss(animated: true)
            }
        )
        rootViewController = UIHostingController(rootView: signupView)
    }

    private func handleSignup(user: UserCredentialModel) {
        Task {
            do {
                let success = try await NetworkService.shared.createUser(user: user)
                
                do {
                    let loginSuccess = try await NetworkService.shared.login(user: user)
                    
                    self.delegate?.didLoginSuccessfully()
                    print("COORDINATOR: Login after signup SUCCESS")
                } catch {
                    print("Login failed after signup: \(error.localizedDescription)")
                }
            } catch {
                print("Signup failed with error: \(error.localizedDescription)")
            }
        }
        rootViewController.dismiss(animated: true)
    }
}
