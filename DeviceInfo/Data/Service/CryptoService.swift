//
//  CryptoService.swift
//  DeviceInfo
//
//  Created by Yuri on 17/07/25.
//

import Foundation
import CryptoKit

protocol CryptoServiceProtocol {
    func encrypt(data: Data, key: String) -> Data?
}

final class CryptoService: CryptoServiceProtocol {
    func encrypt(data: Data, key: String) -> Data? {
        guard key.count == 16,
              let keyData = key.data(using: .utf8) else { return nil }

        let aesKey = SymmetricKey(data: keyData)
        return try? AES.GCM.seal(data, using: aesKey).combined
    }
}
