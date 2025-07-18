//
//  LocationServiceTests.swift
//  DeviceInfo
//
//  Created by Yuri on 18/07/25.
//

import XCTest
import Combine
import CoreLocation
@testable import DeviceInfo

final class LocationServiceTests: XCTestCase {
    private var service: LocationService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        service = LocationService()
        cancellables = []
    }

    func testErrorPublisherReceivesDenied() {
        let expectation = XCTestExpectation(description: "Denied error should be published")

        service.locationErrorPublisher
            .sink { error in
                XCTAssertTrue((error as? CLError)?.code == .denied)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        service.locationManager(CLLocationManager(), didFailWithError: CLError(.denied))
        wait(for: [expectation], timeout: 1)
    }

    func testLocationPublisherReceivesValue() {
        let expectation = XCTestExpectation(description: "Should emit valid location")
        let coords: [Double] = [40.0, -3.0]
        let name = "Madrid, Spain"

        service.locationPublisher
            .sink { value in
                XCTAssertEqual(value.coordinate, coords)
                XCTAssertEqual(value.name, name)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        service.locationSubject.send((coords, name))
        wait(for: [expectation], timeout: 1)
    }
}
