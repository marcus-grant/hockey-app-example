# hockey-app-example


An example of how to use the HockeyApp platform to deploy users, authenticate them, track their app metrics, update their apps, and debug them.

# Environment setup
1.  Setup a HockeyApp account [here](https://rink.hockeyapp.net/users/sign_up)
2.  Download the Hockey companion [app](https://rink.hockeyapp.net/api/2/apps/67503a7926431872c4b6c1549f5bd6b1/app_versions/394?format=zip)
3.  Start the Hockey app
4.  Get your Hockey API token either from your team, or from your newly created account
5.  Sign in the Hockey app by going to `HockeyApp > Preferences...` and going into entering this information in the text fields like below
-   **Insert new-hockey-app-diagram**
6.  If you haven't yet, create the XCode project that will be used
7.  In the Hockey app, integrate Hockey into the XCode project by going to `Project > Integrate with Project` and select the XCode project to integrate the Hockey SDK into and verify the project folder location
8.  The hockey app will now ask to add a `run script` to the end of your XCode project's `build phase`. From the pictures below, *(1.)* select the project from the navigator view, *(2.)* select the project's `build phases` *(3.)* use the plus button to add a *(4.)* `run script` and finally paste the script below into the script text field like the image below. Then build the project, and if all went well the hockey companion app will have proceeded to the next step

```
FILE="${SRCROOT}/HockeySDK-iOS/BuildAgent"
if [ -f "$FILE" ]; then
    "$FILE"
fi
```
-  **Insert hockey-install-run-script image**
-  **Insert new-hockey-app-completed-run-script image**
9.  For the sake of organization, add a new group into your XCode project navigator for frameworks called `Frameworks`
10.  Drag & drop the framework file presented on the Hockey integration wizard into the newly create project group, with the applicable settings like the window below
-   **Insert add-hockey-framework-to-project image**
11.  The next hockey wizard screen will prompt you to either select a hockey app registered on the hockey service to integrate with this XCode project, select one or create a new one with the button to do so.
-   **Insert register-new-hockey-app image**
12.  If adding a new app, enter the name for the app as it will appear in the Hockey platform
13.  Next, the Hockey wizard will ask you to insert some code involved in authenticating the app with the Hockey platform in your app's `AppDelegate`
-  **Objective-C**

```objective-c
@import HockeySDK;
//...
-application:didFinishLaunchingWithOptions:
// Insert this code at the top of the method, but as the last 3rd party SDK code
[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"YOUR_APP_KEY"];
// Do some additional configuration if needed here
[[BITHockeyManager sharedHockeyManager] startManager];
[[BITHockeyManager sharedHockeyManager].authenticator
  authenticateInstallation];
```

```swift
import HockeySDK
//...
func application(application:didFinishLaunchingWithOptions launchOptions) -> Bool {
  // Insert this code at the top of the method, but as the last 3rd party SDK code
  BITHockeyManager.shared().configure(withIdentifier: "YOUR_APP_KEY")
// Do some additional configuration if needed here
BITHockeyManager.shared().start()
BITHockeyManager.shared().authenticator.authenticateInstallation()
return true
}
```
14.  This uses the default `HockeySDK` authentication method to perform the first app authentication of this XCode project to ensure that the app has integrated the SDK correctly. The wizard should show a confirmation that all is well a little while after running the app with the new code.

**You are now ready to work on an app with the HockeySDK integrated!**


### Setting up web authentication

[The HockeySDK for iOS](https://support.hockeyapp.net/kb/client-integration-ios-mac-os-x-tvos/authenticating-users-on-ios) has a few authentication methods that need to be configured in the configuration manager before it gets started with `manager.start()`. The documentation linked indicates 5 ways to authenticate users, for now we're only interested in authentication using a Safari Web View Controller created by the SDK to handle the authentication. To do this, before starting the shared
`BITAuthenticator` instance, set the authenticator member variable `identificationType` to the `BITAuthenticatorIdentificationType` `.webAuth`. This will now force the app to identify the user using the app by opening up a safari web view before anything else happens in the app to have the user log in. If this is done before configuring an app link call back in the XCode project the login will fail after authorization because the app won't know what to do with the link that gets sent
after. To deal with this add the function below:

**This code block has changed, update it**
```
// MARK - App link url callback needed by the HockeyApp Authenticator
    func application(_ application: UIApplication, open url: URL,
                    sourceApplication: String?, annotation: Any) -> Bool {
        //MARK - I create a constant reference to the shared manager's authenticator to keep deep instance references brief
        let authenticator = BITHockeyManager.shared().authenticator
        //MARK - If anything else needs to be done based on whether the web authentication completes do it before return
        return authenticator.handleOpen(url, sourceApplication: sourceApplication, annotation: annotation)
    }
```


Then make sure you have the right URL scheme applied to your `info.plist`. The default url scheme needed is going to have the letters "ha" then immediately after, the APPID you used to authenticate the app for the first time. Look at the image below to see what the plist should look like. **insert new-url-scheme-plist.png**

Now to complete the authentication of the user, the app binary will have to actually be present on the hockey servers. In XCode, ensure that the build target is set to `Generic iOS Device`. Then in the XCode menu bar go to `Product > Archive`. This will   bring up the Archiver view of XCode which is how you create iOS application binaries or archives. In this case, we're after a completed the IPA of the first version of the app.

Hockey integrated app. **insert app-archive-export.png**. Now you are presented with a few options on how you can export the app archive. If you are going to use the `Enterprise Deployment` then you are going to need permissions set for your Apple Developer account, or your teams developer account that allows you to do so. Otherwise, like this app example, you can always select the `Developer Deployment` as an option to get an ipa to upload to hockey. **insert app-export-options**.  You will then need to specify a development team or account that you can upload with. I haven't tried without a developer account yet, so it may be possible that without one it's impossible to export an app archive. Now finally a screen will be presented to select which devices app archives should be compiled and archived for. Select `Export one app for all compatible devices` as a safe default. Just be prepared to wait for all the app versions to be compiled at once. Then a final screen to verify app entitlements based on your user profile **include manifest for OTA installation option???**.  Now go into the **insert dashboard link** and go to your app's overview page. There will be an `Add version` button that gets used to add all new app versions as IPAs like were just created. Go there and drag & drop the newly create IPA and follow the instructions for adding it. It may be useful to add app users at this point, including any invites that may be needed to be sent out. This could be useful if the same account that was used to add the app may not be the best one to test the authentication or other HockeySDK features. And that's it! The XCode project should now be able to run, bring up a web view to login as a Hockey user using either the hockeyapp email address and password, or by using single sign on with either Google, Github, Facebook, or **insert 4th**.

**Add app screenshots of succesful web auths**

### De-authenticate Notes 
- Until I find out what it is that prevents a Hockey client from invalidating the previous hockey login on the local device it could be very useful to know how to completely clean iOS simulator instances and XCode caches. [This stackoverflow response](2) details a very thorough way to completely clean any lingering data on the iOS simulator and associated XCode caches.
-  Apparently automatic authentication strategies `BITAuthenticatorIdentificationTypeDevice` & `BITAuthenticatorIdentificationTypeWebAuth` use embedded data inside the iTunes Artwork PNG, the app icon basically as it is uploaded to the Hockey server as a means to authenticate. Make sure this is isn't the case anymore.
    -  From [this hockey article](3)
    -  There is a note that maybe this isn't the case anymore since iOS 8 `2014/09/17: Automatic authentication no longer works on iOS 8 as Apple has removed the iTunesArtwork file.` from [3](3)
- From the [KeychainSwift Library][KeychainSwift], there is a function that supposedly deletes all keychain entries:
```swift
i@discardableResult
  open func clear() -> Bool {
    var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
                          
    lastResultCode = SecItemDelete(query as CFDictionary)
                                  
    return lastResultCode == noErr
}
```


### References
[Hockey Integration App for OSX Documentation](https://support.hockeyapp.net/kb/client-integration-ios-mac-os-x-tvos/hockeyapp-for-mac-os-x#advancedsetup)
[2]: http://stackoverflow.com/questions/5714372/how-to-empty-caches-and-clean-all-targets-xcode-4 "StackOverflow solution to clearing XCode & Simulator Caches"
[3]: https://www.hockeyapp.net/blog/2014/01/31/automatic-authentication-ios.html "Hockey Auto Authentication through itunes artwork"
[KeychainSwift]: https://github.com/marketplacer/keychain-swift/blob/master/Sources/KeychainSwift.swift "KeychainSwift Source Code"
