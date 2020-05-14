//
//  AppDelegate.swift
//  Continuum
//
//  Created by DevMountain on 2/11/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkSignInStatus { (success) in
            let fetchedUserStatment = success ? "Successfully retrieved a logged in user" : "Failed to retrieve a logged in user"
            print(fetchedUserStatment)
        }
        return true
    }
    
    func checkSignInStatus(completion: @escaping (Bool) -> Void){
        CKContainer.default().accountStatus { (status, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            } else {
                DispatchQueue.main.async {
                    switch status {
                    case .couldNotDetermine:
                        self.window?.rootViewController?.presentErrorToUser(localizedError: .unexpectedError)
                        completion(false)
                    case .available:
                        completion(true)
                    case .restricted:
                        self.window?.rootViewController?.presentErrorToUser(localizedError: .restrictedError)
                        completion(false)
                    case .noAccount:
                        self.window?.rootViewController?.presentErrorToUser(localizedError: .noAccount)
                        completion(false)
                    @unknown default:
                        self.window?.rootViewController?.presentErrorToUser(localizedError: .newError)
                        completion(false)
                    }
                }
            }
        }
    }
}

