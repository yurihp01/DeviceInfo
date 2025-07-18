//
//  NetworkService.swift
//  DeviceInfo
//
//  Created by Yuri on 17/07/25.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func send(data: Data?) -> AnyPublisher<Bool, Error>
}

final class NetworkService: NetworkServiceProtocol {
    func send(data: Data?) -> AnyPublisher<Bool, Error> {
        guard let data = try? JSONEncoder().encode(data) else {
            return Fail(error: URLError(.cannotWriteToFile))
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: Constants.postURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in true }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
