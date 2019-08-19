//
//  GeofenceManager.swift
//  Plugin
//
//  Created by Jasiel Izaguirre on 8/17/19.
//  Copyright © 2019 Max Lynch. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

class GeofenceManager: NSObject, UNUserNotificationCenterDelegate {
    
    // Singleton instance
    static let shared = GeofenceManager()
    
    private var locationManager: CLLocationManager!
    
    var notifyOnEntry = true
    
    var notifyOnExit = true
    
    var setupCallback: ((_ success: Bool) -> Void)?
    
    override init() {
        super.init()
        DispatchQueue.main.sync {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    /**
     Request access to location data, in the background and while using the app.
     */
    func requestAlwaysAuthorization(completion: @escaping ((_ success: Bool) -> Void)) {
        setupCallback = completion
        locationManager.requestAlwaysAuthorization()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "y = mx + b" {
            NSLog("That's the correct answer!")
        } else if response.actionIdentifier == "Ax + By = C" {
            NSLog("Sorry, that's the standard form equation.")
        } else {
            NSLog("Keep trying!")
        }
    }
    
    
    /**
     Check whether the app has the ability to monitor a geofence region.
     - returns:
     A Boolean indicating availability of geofencing and authorizationstatus.
     */
    private func geofenceAvailable() -> Bool {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            return false
        }
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    /**
     Creates a CLCircularRegion.
     - returns:
     A CLCircularRegion created from the given parameters.
     - parameters:
     - lat: The latitude of the center of the circle.
     - lng: The longitude of the center of the circle.
     - radius: The radius of the circle.
     - identifier: A string to identify the circle.
     */
    func geofenceRegion(lat: Double, lng: Double, radius: Double = 50, identifier: String) -> CLCircularRegion {
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = notifyOnExit
        return region
    }
    
    /**
     Starts monitoring the given region.
     - returns:
     A Boolean indicating whether geofencing is available or not.
     - parameters:
     - region: The CLCircularRegion to monitor.
     */
    func startMonitoring(region: CLCircularRegion) -> Bool {
        if geofenceAvailable() {
            locationManager.startMonitoring(for: region)
            return true
        }
        return false
    }
    
    /**
     Stops monitoring the region for the given identifier.
     - returns:
     A Boolean indicating whether removing the geofence for the given string was successful or not.
     - parameters:
     - identifier: The String identifier that was used to create the region.
     */
    func stopMonitoring(identifier: String) -> Bool {
        for region in locationManager.monitoredRegions {
            guard let cr = region as? CLCircularRegion, cr.identifier == identifier else { continue }
            locationManager.stopMonitoring(for: cr)
            return true
        }
        return false
    }
    
    /**
     Returns the amount of regions you're currently monitoring.
     - returns:
     The amount of monitored regions.
     */
    func monitoredRegionsCount() -> Int {
        return locationManager.monitoredRegions.count
    }
    
    /**
     Returns the identifiers of all monitored regions.
     - returns:
     An array that contains the identifiers of all currently monitored regions.
     */
    func monitoredRegions() -> [String] {
        return locationManager.monitoredRegions.map({ $0.identifier })
    }
    
    /**
     Sends the given data to the backend.
     - parameters:
     - region: The region for which the event happened.
     - enter: A Boolean value indicating whether the user entered(true) or left(false) the region.
     */
    
    private func handleEvent(forRegion region: CLRegion, enter: Bool) -> String {
        let identifer = region.identifier
        
        return identifer
    }
    
    func notification(forRegion region: CLRegion, enter: Bool) {
        let mathContent = UNMutableNotificationContent()
        mathContent.title = "Math Quiz!"
        mathContent.subtitle = "Do you remember high school algebra?"
        mathContent.body = "What is the equation for slope-intercept form?"
        mathContent.badge = 1
        mathContent.categoryIdentifier = "mathQuizCategory"
        
        let quizTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let quizRequestIdentifier = "mathQuiz"
        let request = UNNotificationRequest(identifier: quizRequestIdentifier, content: mathContent, trigger: quizTrigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error as Any)
        }
    }
    
    func registerForPushNotifications() -> Bool {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                guard granted else{return}
        }
        return true
    }
}

extension GeofenceManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("Location authorization changed to 'authorizedAlways'.")
            setupCallback?(true)
        case .notDetermined:
            print("Location authorization not determined yet.")
            break
        default:
            setupCallback?(false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Did start monitoring for region: \(region.identifier)")
        locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier).")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error).")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region, enter: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case CLRegionState.inside:
            handleEvent(forRegion: region, enter: true)
        default:
            break
        }
    }
}
