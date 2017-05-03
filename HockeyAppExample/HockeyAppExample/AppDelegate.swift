//
//  AppDelegate.swift
//  HockeyAppExample
//
//  Created by Marcus Grant on 5/2/17.
//  Copyright © 2017 Marcus Grant. All rights reserved.
//

import Foundation
import Security
import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var lastQueryParameters: [String: Any]?
    var lastResultCode: OSStatus = noErr
    var accessGroup: String?
    open var synchronizable: Bool = false

    var window: UIWindow?


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //FIXME: Check Restrict and Frequency flags of authenticator or manager
        let hockeyAppKey = "ceaeecd98ddc41c49319215c20370ca6"
        initHockey(with: hockeyAppKey, identificationType: .webAuth)
//        resetKeychain()

        return true
    }

    // MARK - App link url callback needed by the HockeyApp Authenticator
    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        //MARK I create a constant reference to the shared manager's authenticator to keep deep instance references brief
        //let authenticator = BITHockeyManager.shared().authenticator
        // If the web authentication was successful...
        if BITHockeyManager.shared().authenticator.handleOpen(url, sourceApplication: sourceApplication, annotation: annotation) {
            print("Authentification callback succesful!")
            return true
        } else { // If the web authentication fails...
            print("Authentification callback failed!")
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

    //MARK: - Hockey Helpers, use these for facade class later

    func initHockey(with appToken: String, identificationType: BITAuthenticatorIdentificationType) {
        // TODO: Facade class to handle all HockeyAuthentication stuff
        // TODO: Investigate why you can't use these below constant references to invoke the manager/auth funcs

        //MARK: - HockeyManager & HockeyAuthenticator setups/configs/initialization
        //let manager = BITHockeyManager.shared()
        //let authenticator = manager.authenticator
        BITHockeyManager.shared().configure(withIdentifier: appToken)
        // Do some additional configuration if needed here
        // TODO: Handle error cases for wrong authentication types and failed authentications
        // TODO: Investigate embeded UDID on Artwork from http://bit.ly/2pDvxug

        // MARK: Configure the web authentication method for the hockey manager
        BITHockeyManager.shared().authenticator.identificationType = .webAuth

        //TODO: 1. will this help us? 2. Is this ok with app workflow of GMA?
        BITHockeyManager.shared().authenticator.restrictApplicationUsage = true
        BITHockeyManager.shared().authenticator.restrictionEnforcementFrequency = .onAppActive //MARK: either .onAppActive .onFirstLaunch



        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        printAllAuthInfo()
    }


    func resetKeychain() {
        print("Resetting all keychain entries for app...")
        let isReset = clear()
        var output = "Keychain reset "
        if isReset { output += "succeeded" }
        else { output += "failed" }
        print(output)
    }

    func printAllAuthInfo() {
        let isIdentified = BITHockeyManager.shared().authenticator.isIdentified
        let isValidated = BITHockeyManager.shared().authenticator.isValidated
//        BITHockeyManager.shared().authenticator.identify(completion: 
        let userID = BITHockeyManager.shared().userID
        let username = BITHockeyManager.shared().userName
        let userEmail = BITHockeyManager.shared().userEmail
        print("Current Debug for manager & authenticator")
        print("isIdentified = \(isIdentified)")
        print("isValidated = \(isValidated)")
        print("username = \(String(describing: username))")
        print("userID = \(String(describing: userID))")
        print("userEmail = \(String(describing: userEmail))")
    }

    //MARK: - Keychain helpers
    @discardableResult
    open func clear() -> Bool {
        var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        lastQueryParameters = query

        lastResultCode = SecItemDelete(query as CFDictionary)

        return lastResultCode == noErr
    }

    func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
        guard let accessGroup = accessGroup else { return items }

        var result: [String: Any] = items
        result[KeychainSwiftConstants.accessGroup] = accessGroup
        return result
    }

    func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
        if !synchronizable { return items }
        var result: [String: Any] = items
        result[KeychainSwiftConstants.attrSynchronizable] = addingItems == true ? true : kSecAttrSynchronizableAny
        return result
    }



}


/// Constants used by the library
public struct KeychainSwiftConstants {
    /// Specifies a Keychain access group. Used for sharing Keychain items between apps.
    public static var accessGroup: String { return toString(kSecAttrAccessGroup) }

    /**

     A value that indicates when your app needs access to the data in a keychain item. The default value is AccessibleWhenUnlocked. For a list of possible values, see KeychainSwiftAccessOptions.

     */
    public static var accessible: String { return toString(kSecAttrAccessible) }

    /// Used for specifying a String key when setting/getting a Keychain value.
    public static var attrAccount: String { return toString(kSecAttrAccount) }

    /// Used for specifying synchronization of keychain items between devices.
    public static var attrSynchronizable: String { return toString(kSecAttrSynchronizable) }

    /// An item class key used to construct a Keychain search dictionary.
    public static var klass: String { return toString(kSecClass) }

    /// Specifies the number of values returned from the keychain. The library only supports single values.
    public static var matchLimit: String { return toString(kSecMatchLimit) }

    /// A return data type used to get the data from the Keychain.
    public static var returnData: String { return toString(kSecReturnData) }

    /// Used for specifying a value when setting a Keychain value.
    public static var valueData: String { return toString(kSecValueData) }

    static func toString(_ value: CFString) -> String {
        return value as String
    }
}
