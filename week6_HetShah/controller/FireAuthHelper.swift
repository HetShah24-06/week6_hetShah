//
//  FireAuthHelper.swift
//  week6_HetShah
//
//  Created by Het Shah on 2025-07-22.
//

import Foundation
import FirebaseAuth

class FireAuthHelper: ObservableObject {
    
    @Published var user : User? {
        didSet {
            objectWillChange.send()
        }
    }
    
    private static var shared : FireAuthHelper?
    
    static func getInstance() -> FireAuthHelper {
        if (shared == nil) {
            shared = FireAuthHelper()
        }
        return shared!
    }
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.user = user
            print(#function, "Auth changed: \(user?.uid ?? "nil")")
        }
    }

    func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                print(#function, "Error during anonymous sign-in: \(error.localizedDescription)")
            } else {
                self?.user = result?.user
                print(#function, "Anonymous user signed in: \(self?.user?.uid ?? "Unknown UID")")
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let result = authResult else {
                print(#function, "Error while creating account: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self?.user = result.user
            UserDefaults.standard.set(self?.user?.email, forKey: "KEY_EMAIL")
            print(#function, "User signed up: \(result.user.uid)")
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let result = authResult else {
                print(#function, "Error while signing in: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self?.user = result.user
            UserDefaults.standard.set(email, forKey: "KEY_EMAIL")
            print(#function, "User signed in: \(result.user.uid)")
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            print(#function, "User signed out")
        } catch let error {
            print(#function, "Sign out error: \(error.localizedDescription)")
        }
    }
}
