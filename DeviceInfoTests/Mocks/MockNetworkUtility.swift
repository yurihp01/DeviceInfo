//
//  MockNetworkUtility.swift
//  DeviceInfo
//
//  Created by Yuri on 18/07/25.
//

import Combine

final class MockNetworkUtility: NetworkUtilityProtocol {
    func localIP() -> String? { "192.168.1.1" }
    func isUsingVPN() -> Bool { true }
    func appUserAgent() -> String { "TestAgent/1.0" }
    func webViewUserAgent() -> AnyPublisher<String, Never> {
        Just("WebViewAgent").eraseToAnyPublisher()
    }

    func fetchPublicIP() -> AnyPublisher<String, Error> {
        Just("8.8.8.8")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
