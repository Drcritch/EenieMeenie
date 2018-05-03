
import UIKit
import GoogleMaps

// A constant to hold Google API key
let googleApiKey = "AIzaSyD86RHjO4NWXQPNApmwj5ppXG9IFrnvHM8"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    //instantiate Google Maps services with the API key using GMSServices class method provideAPIKey()
    GMSServices.provideAPIKey(googleApiKey)
    return true
  }
}

