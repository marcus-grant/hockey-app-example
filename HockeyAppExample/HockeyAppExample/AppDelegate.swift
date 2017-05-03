//
//  AppDelegate.swift
//  HockeyAppExample
//
//  Created by Marcus Grant on 5/2/17.
//  Copyright © 2017 Marcus Grant. All rights reserved.
//

import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // TODO: Facade class to handle all HockeyAuthentication stuff
        // TODO: Investigate why you can't use these below constant references to invoke the manager/auth funcs
        let hockeyAppKey = "ceaeecd98ddc41c49319215c20370ca6"
        let manager = BITHockeyManager.shared()
        let authenticator = manager.authenticator
        BITHockeyManager.shared().configure(withIdentifier: hockeyAppKey)
        // Do some additional configuration if needed here
        // TODO: Handle error cases for wrong authentication types and failed authentications
        // TODO: Investigate embeded UDID on Artwork from http://bit.ly/2pDvxug

        // MARK: Configure the web authentication method for the hockey manager
        BITHockeyManager.shared().authenticator.identificationType = .webAuth


        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()


        return true
    }

    // MARK - App link url callback needed by the HockeyApp Authenticator
    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        //MARK - I create a constant reference to the shared manager's authenticator to keep deep instance references brief
        let authenticator = BITHockeyManager.shared().authenticator
        // If the web authentication was successful...
        if BITHockeyManager.shared().authenticator.handleOpen(url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        } else { // If the web authentication fails...
            return false
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

