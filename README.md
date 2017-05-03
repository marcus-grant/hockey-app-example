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

```
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

**Swift**
```
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



```

### References
[]
