import Foundation
import Capacitor
import CoreLocation
import MapKit
import UserNotifications

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(GeofenceTracker)
public class GeofenceTracker: CAPPlugin {
    @objc func setup(_ call: CAPPluginCall) {
        guard let notifyOnEntry = call.getBool("notifyOnEntry", nil) else {
            call.error("Must provide notifyOnEntry.")
            return
        }
        guard let notifyOnExit = call.getBool("notifyOnExit", nil) else {
            call.error("Must provide notifyOnExit.")
            return
        }
        
        GeofenceManager.shared.notifyOnEntry = notifyOnEntry
        GeofenceManager.shared.notifyOnExit = notifyOnExit
        GeofenceManager.shared.requestAlwaysAuthorization { (success) in
            if success {
                call.success()
            } else {
                call.error("User did not give 'alwaysAuthorization' permission.")
            }
        }
    }
    
    @objc func addRegion(_ call: CAPPluginCall) {
        // Check if all properties are present
        guard let lat = call.get("latitude", Double.self) else {
            call.error("Must provide latitude.")
            return
        }
        guard let lng = call.get("longitude", Double.self) else {
            call.error("Must provide longitude.")
            return
        }
        guard let identifer = call.getString("identifier") else {
            call.error("Must provide identifier.")
            return
        }
        let radius = call.get("radius", Double.self) ?? 50
        
        let region = GeofenceManager.shared.geofenceRegion(lat: lat, lng: lng, radius: radius, identifier: identifer, plugin: self)
        GeofenceManager.shared.startMonitoring(region: region)
            ? call.success()
            : call.error("Could not start monitoring the region.")
    }
    
    @objc func stopMonitoring(_ call: CAPPluginCall) {
        guard let identifier = call.getString("identifier") else {
            call.error("Must provide identifier.")
            return
        }
        GeofenceManager.shared.stopMonitoring(identifier: identifier)
            ? call.success()
            : call.error("Could not find a region with that identifer.")
    }
    
    @objc func monitoredRegions(_ call: CAPPluginCall) {
        call.success([
            "regions": GeofenceManager.shared.monitoredRegions()
            ])
    }
    
    @objc func registerForPushNotifications(_ call: CAPPluginCall) {
        call.success([
            "notifications": GeofenceManager.shared.registerForPushNotifications()
        ])
    }
}
