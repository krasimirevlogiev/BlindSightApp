import UIKit
import Flutter
import GoogleMaps
import flutter_config

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let googleMapsApiKey = flutter_config.FlutterConfigPlugin.env(for: "GOOGLE_MAPS_API_KEY") {
        GMSServices.provideAPIKey(googleMapsApiKey)
    } else {
        // Handle the case where the API key is not found.
        print("Error: Google Maps API key not found.")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}