//
//  MockNetworkService.swift
//  DeviceInfo
//
//  Created by Yuri on 18/07/25.
//

import Combine
import Foundation

final class MockNetworkService: NetworkServiceProtocol {
    func send(data: Data?) -> AnyPublisher<Bool, Error> {
        Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
