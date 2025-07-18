//
//  DeviceInfoViewModelTests.swift
//  DeviceInfoTests
//
//  Created by Yuri on 17/07/25.
//

import XCTest
import Combine
@testable import DeviceInfo
import CoreLocation

@MainActor
final class DeviceInfoViewModelTests: XCTestCase {
    private var viewModel: DeviceInfoViewModel!
    private var mockCollector: MockDeviceInfoCollector!
    private var mockLocationService: MockLocationService!
    private var mockNetwork: MockNetworkService!
    private var mockCrypto: MockCryptoService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockCollector = MockDeviceInfoCollector()
        mockLocationService = MockLocationService()
        mockNetwork = MockNetworkService()
        mockCrypto = MockCryptoService()
        viewModel = DeviceInfoViewModel(
            collector: mockCollector,
            locationService: mockLocationService,
            network: mockNetwork,
            crypto: mockCrypto
        )
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    func testLoadInfoSuccessfullyPublishesDeviceInfo() {
        let expectation = XCTestExpectation(description: "DeviceInfo should be published")

        let expectedInfo = DeviceInfo(
            localIP: "192.168.0.1",
            ip: "8.8.8.8",
            userAgent: "TestAgent",
            vpn: false,
            language: "en-US",
            timezone: "Europe/Lisbon",
            location: [38.7, -9.1],
            locationName: "Lisbon",
            userAgentWebkit: nil
        )

        mockCollector.mockedInfo = expectedInfo

        viewModel.$deviceInfo
            .dropFirst()
            .compactMap { $0 }
            .sink { info in
                XCTAssertEqual(info?.ip, expectedInfo.ip)
                XCTAssertEqual(info?.locationName, expectedInfo.locationName)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.requestLocation()
        mockLocationService.sendLocation(([38.7, -9.1], "Lisbon"))

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadInfoEncryptionFailsShowsError() {
        let expectation = XCTestExpectation(description: "Should receive encryption error")
        mockCrypto.returnNil = true

        viewModel.$errorMessage
            .dropFirst()
            .compactMap { $0 }
            .sink { error in
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.requestLocation()
        mockLocationService.sendLocation(([38.7, -9.1], "Lisbon"))

        wait(for: [expectation], timeout: 1.0)
    }

    func testLocationErrorPermissionDeniedShowsMessage() {
        let expectation = XCTestExpectation(description: "Should show denied message")

        viewModel.$errorMessage
            .dropFirst()
            .sink { msg in
                XCTAssertEqual(msg, "Location permission denied. Please enable it in Settings ➜ Location Services.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockLocationService.sendError(CLError(.denied))
        wait(for: [expectation], timeout: 1.0)
    }
}
