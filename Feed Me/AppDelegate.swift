
import UIKit
import GoogleMaps

let googleApiKey = "AIzaSyD86RHjO4NWXQPNApmwj5ppXG9IFrnvHM8"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GMSServices.provideAPIKey(googleApiKey)
    return true
  }
}

