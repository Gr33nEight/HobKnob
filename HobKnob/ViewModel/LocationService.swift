//
//  LocationService.swift
//  Parked
//
//  Created by Natanael Jop on 20/09/2022.
//

import Foundation
import MapKit
import SwiftUI
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var lastLocation: CLLocation?
    
    var interval: Double = 20.0
    var timer: AnyCancellable?
    
    @Published var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = CLLocationDistanceMax
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func setUpTimer(action: @escaping (CLLocationCoordinate2D?) -> Void) {
        timer = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                action(self?.locationManager.location?.coordinate)
            })
    }
    
    func generateRandomCoordinates(min: UInt32, max: UInt32)-> CLLocationCoordinate2D {
        guard let currentLong = location?.coordinate.longitude else { return MKCoordinateRegion.goldenGateRegion().center }
        guard let currentLat = location?.coordinate.latitude else { return MKCoordinateRegion.goldenGateRegion().center }
        
        let meterCord = 0.00900900900901 / 1000
        let randomMeters = UInt(arc4random_uniform(max) + min)
        let randomPM = arc4random_uniform(6)
        let metersCordN = meterCord * Double(randomMeters)

        if randomPM == 0 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 1 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 2 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 3 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 4 {
            return CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong - metersCordN)
        }else {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong)
        }

    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
//        DispatchQueue.main.async {
            self.location = location
//        }
    }
    
}

extension MKCoordinateRegion {
    static func goldenGateRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.819527098978355, longitude:  -122.47854602016669), latitudinalMeters: 10, longitudinalMeters: 10)
    }
    func getBinding() -> Binding<MKCoordinateRegion>? {
        return Binding<MKCoordinateRegion>.constant(self)
    }
}
