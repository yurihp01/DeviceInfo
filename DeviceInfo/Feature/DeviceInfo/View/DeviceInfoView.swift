//
//  ContentView.swift
//  DeviceInfo
//
//  Created by Yuri on 17/07/25.
//

import SwiftUI

struct DeviceInfoView: View {
    @StateObject private var viewModel = DeviceInfoViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let info = viewModel.deviceInfo {
                        DeviceInfoCard(title: "Local IP", value: info.localIP, icon: "wifi")
                        DeviceInfoCard(title: "Public IP", value: info.ip, icon: "network")
                        DeviceInfoCard(title: "User Agent", value: info.userAgent, icon: "person.fill.questionmark")
                        DeviceInfoCard(title: "VPN Active", value: info.vpn ? "Yes" : "No", icon: "shield.lefthalf.fill")
                        DeviceInfoCard(title: "Language", value: info.language, icon: "globe")
                        DeviceInfoCard(title: "Timezone", value: info.timezone, icon: "clock")
                        
                        if let name = info.locationName {
                            DeviceInfoCard(title: "Location", value: name, icon: "location")
                        } else {
                            let coordinates = "\(info.location[0]), \(info.location[1])"
                            DeviceInfoCard(title: "Location", value: coordinates, icon: "location")
                        }

                        if let webkit = info.userAgentWebkit {
                            DeviceInfoCard(title: "WebView User Agent", value: webkit, icon: "safari")
                        }
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text("⚠️ \(error)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()

                            if error.contains("denied") {
                                Button(action: {
                                    viewModel.openAppSettings()
                                }) {
                                    Label("Open App Settings", systemImage: "gear")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.top)
                    } else {
                        VStack {
                            ProgressView()
                            Text("Collecting device info...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    }
                }
                .padding()
            }
            .navigationTitle("📱 Device Info")
        }
        .onAppear {
            viewModel.requestLocation()
        }
    }
}

#Preview {
    DeviceInfoView()
}
