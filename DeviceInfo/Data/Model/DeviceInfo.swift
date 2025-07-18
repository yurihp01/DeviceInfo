//
//  DeviceInfo.swift
//  DeviceInfo
//
//  Created by Yuri on 17/07/25.
//

import Foundation

struct DeviceInfo: Codable {
    let localIP: String
    let ip: String
    let userAgent: String
    let vpn: Bool
    let language: String
    let timezone: String
    let location: [Double]
    let locationName: String?
    let userAgentWebkit: String?

    enum CodingKeys: String, CodingKey {
        case ip, vpn, language, timezone, location
        case localIP = "local_ip"
        case userAgent = "user_agent"
        case locationName = "location_name"
        case userAgentWebkit = "user_agent_webkit"
    }
}
