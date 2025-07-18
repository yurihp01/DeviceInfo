//
//  NetworkUtility.swift
//  DeviceInfo
//
//  Created by Yuri on 17/07/25.
//

import Foundation
import Combine
import WebKit

// MARK: - Protocol
protocol NetworkUtilityProtocol {
    func localIP() -> String?
    func isUsingVPN() -> Bool
    func appUserAgent() -> String
    func webViewUserAgent() -> AnyPublisher<String, Never>
}

// MARK: - NetworkUtility
final class NetworkUtility: NetworkUtilityProtocol {
    func localIP() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { continue }
                let family = interface.ifa_addr.pointee.sa_family
                
                if family == UInt8(AF_INET) || family == UInt8(AF_INET6) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr,
                                    socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname,
                                    socklen_t(hostname.count),
                                    nil,
                                    0,
                                    NI_NUMERICHOST)
                        address = String(cString: hostname)
                        break
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    func isUsingVPN() -> Bool {
        guard let dict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let scoped = dict["__SCOPED__"] as? [String: Any] else {
            return false
        }
        
        for key in scoped.keys {
            if key.contains("tap") || key.contains("tun") ||
                key.contains("ppp") || key.contains("ipsec") || key.contains("utun") {
                return true
            }
        }
        
        return false
    }
    
    func appUserAgent() -> String {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "UnknownApp"
        let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1.0"
        let os = ProcessInfo.processInfo.operatingSystemVersion

        let cfVersion = Bundle(identifier: "com.apple.CFNetwork")?
            .infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

        return "\(appName)/\(appVersion) CFNetwork/\(cfVersion) Darwin/\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
    }

    func webViewUserAgent() -> AnyPublisher<String, Never> {
        let subject = PassthroughSubject<String, Never>()
        DispatchQueue.main.async {
            let webView = WKWebView(frame: .zero)
            webView.evaluateJavaScript("navigator.userAgent") { result, _ in
                subject.send((result as? String) ?? "Unavailable")
            }
        }
        return subject.eraseToAnyPublisher()
    }
}
