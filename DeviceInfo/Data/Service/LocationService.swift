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
    let locationSubject = PassthroughSubject<(coordinate: [Double], name: String?), Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()
    private let geocoder = CLGeocoder()

    var locationPublisher: AnyPublisher<(coordinate: [Double], name: String?), Never> {
        locationSubject.eraseToAnyPublisher()
    }

    var locationErrorPublisher: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        locationManager.delegate = self
    }
}

// MARK: - LocationServiceProtocol Implementation
extension LocationService: LocationServiceProtocol {
    func requestLocation() {
        locationManagerDidChangeAuthorization(locationManager)
    }
}
    
// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            errorSubject.send(CLError(.denied))
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              location.horizontalAccuracy >= 0 else {
            return
        }
        
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
