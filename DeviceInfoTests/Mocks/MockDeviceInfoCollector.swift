//
//  MockDeviceInfoCollector.swift
//  DeviceInfo
//
//  Created by Yuri on 18/07/25.
//

import Combine
import Foundation

final class MockDeviceInfoCollector: DeviceInfoCollectorProtocol {
    var mockedInfo: DeviceInfo?

    func fetchDeviceInfo(with location: (coordinate: [Double], name: String?)) -> AnyPublisher<DeviceInfo, Error> {
        if let info = mockedInfo {
            return Just(info)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        }
    }
}
