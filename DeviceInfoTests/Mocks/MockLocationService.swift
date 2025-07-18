//
//  MockLocationService.swift
//  DeviceInfo
//
//  Created by Yuri on 18/07/25.
//

import Foundation
import Combine

final class MockLocationService: LocationServiceProtocol {
    func requestLocation() {}
    
    let locationSubjectTest = PassthroughSubject<(coordinate: [Double], name: String?), Never>()
    let errorSubjectTest = PassthroughSubject<Error, Never>()

    var locationPublisher: AnyPublisher<(coordinate: [Double], name: String?), Never> {
        locationSubjectTest.eraseToAnyPublisher()
    }

    var locationErrorPublisher: AnyPublisher<Error, Never> {
        errorSubjectTest.eraseToAnyPublisher()
    }

    func sendLocation(_ location: (coordinate: [Double], name: String?)) {
        locationSubjectTest.send(location)
    }

    func sendError(_ error: Error) {
        errorSubjectTest.send(error)
    }
}
