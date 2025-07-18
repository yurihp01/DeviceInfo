//
//  MockCryptoService.swift
//  DeviceInfo
//
//  Created by Yuri on 18/07/25.
//

import Foundation

final class MockCryptoService: CryptoServiceProtocol {
    var returnNil = false
    func encrypt(data: Data, key: String) -> Data? {
        return returnNil ? nil : data
    }
}
