//
//  DeviceInfoCollector.swift
//  DeviceInfo
//
//  Created by Yuri on 17/07/25.
//

import Foundation
import Combine

// MARK: - Protocol
protocol DeviceInfoCollectorProtocol {
    func fetchDeviceInfo(with location: (coordinate: [Double], name: String?)) -> AnyPublisher<DeviceInfo, Error>
}

// MARK: - DeviceInfoCollector
final class DeviceInfoCollector {
    private let networkUtility: NetworkUtilityProtocol

    init(networkUtility: NetworkUtilityProtocol = NetworkUtility()) {
        self.networkUtility = networkUtility
    }
}

// MARK: - Protocol Implementation
extension DeviceInfoCollector: DeviceInfoCollectorProtocol {
    func fetchDeviceInfo(with location: (coordinate: [Double], name: String?)) -> AnyPublisher<DeviceInfo, Error> {
        let localIP = networkUtility.localIP() ?? "0.0.0.0"
        let language = Locale.preferredLanguages.first ?? "unknown"
        let timezone = TimeZone.current.identifier
        let userAgent = networkUtility.appUserAgent()
        let isVPN = networkUtility.isUsingVPN()
        
        return fetchPublicIP()
            .map { publicIP in
                DeviceInfo(
                    localIP: localIP,
                    ip: publicIP,
                    userAgent: userAgent,
                    vpn: isVPN,
                    language: language,
                    timezone: timezone,
                    location: location.coordinate,
                    locationName: location.name,
                    userAgentWebkit: nil
                )
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Private Extension
private extension DeviceInfoCollector {
    func fetchPublicIP() -> AnyPublisher<String, Error> {
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [String: String].self, decoder: JSONDecoder())
            .tryMap { dict in
                guard let ip = dict["ip"] else {
                    throw URLError(.cannotParseResponse)
                }
                return ip
            }
            .eraseToAnyPublisher()
    }
}
