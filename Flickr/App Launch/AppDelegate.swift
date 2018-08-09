//
//  AppDelegate.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 24/05/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupDependencies()
        
        return true
    }
    
    private func setupDependencies() {
        guard let nafigationController = window?.rootViewController as? UINavigationController,
            let photosViewController = nafigationController.topViewController as? PhotosViewController else {
            return
        }
        
        photosViewController.presenter = PhotosPresenter(network: Network.shared)
    }
}
