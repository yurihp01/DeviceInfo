//
//  LocationService.swift
//  DeviceInfo
//
//  Created by Yuri on 17/07/25.
//

import Combine
import CoreLocation

// MARK: - LocationServiceProtocol
protocol LocationServiceProtocol {
    func requestLocation()
    var locationPublisher: AnyPublisher<(coordinate: [Double], name: String?), Never> { get }
    var locationErrorPublisher: AnyPublisher<Error, Never> { get }
}

// MARK: - LocationService
final class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private let locationSubject = CurrentValueSubject<(coordinate: [Double], name: String?)?, Never>(nil)
    private let errorSubject = PassthroughSubject<Error, Never>()
    private let geocoder = CLGeocoder()
    private var hasSentLocation = false

    var locationPublisher: AnyPublisher<(coordinate: [Double], name: String?), Never> {
        locationSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    var locationErrorPublisher: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
}

// MARK: - LocationServiceProtocol Implementation
extension LocationService: LocationServiceProtocol {
    func requestLocation() {
        hasSentLocation = false
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            errorSubject.send(CLError(.denied))
        }
    }
}
    
// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            hasSentLocation = false
            locationManager.startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            errorSubject.send(CLError(.denied))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !hasSentLocation,
              let location = locations.last,
              location.horizontalAccuracy >= 0 else {
            return
        }
        
        hasSentLocation = true
        manager.stopUpdatingLocation()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorSubject.send(error)
                return
            }
            
            let placemark = placemarks?.first
            let name = [placemark?.locality, placemark?.country]
                .compactMap { $0 }
                .joined(separator: ", ")
            
            let coords = [location.coordinate.latitude, location.coordinate.longitude]
            self.locationSubject.send((coordinate: coords, name: name.isEmpty ? nil : name))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let clError = error as? CLError
        
        switch clError?.code {
        case .denied:
            errorSubject.send(CLError(.denied))
        case .locationUnknown:
            return
        default:
            errorSubject.send(error)
        }        
    }
}
