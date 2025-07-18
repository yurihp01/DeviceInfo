# 📱 DeviceInfo

An iOS application that gathers real-time information about the device it's running on and securely sends it to a remote server using AES encryption.

---

## ✅ Features

- Collects:
  - ✅ Local IP address
  - ✅ Public IP address
  - ✅ App User Agent
  - ✅ WebKit User Agent (optional)
  - ✅ VPN detection
  - ✅ Device language
  - ✅ Timezone
  - ✅ Device location (coordinates and readable place name)

- Sends information in JSON via HTTP POST
- AES-encrypted payload using CryptoKit
- Combine-based reactive architecture
- Works with real-time location permission updates
- Minimal SwiftUI interface

---

## 📦 Requirements

- **iOS**: 15.0+
- **Xcode**: 14.0+
- **Language**: Swift 5.7+
- **Dependencies**: No external libraries

---

## 🧑‍💻 How to Run

1. Download or clone this repository
2. Open `DeviceInfo.xcodeproj` in Xcode
3. Go to project settings → Signing & Capabilities → Select your team
4. Run the app on a **real device** (recommended for testing location permission)
5. Allow location permission when prompted

---

## 🔐 Encryption

AES encryption is implemented using `CryptoKit` (`AES.GCM`). The payload is encrypted before being sent to the backend.

Edit the `Constants.swift` file to change the key and endpoint:

```swift
struct Constants {
    static let endpointURL = "https://yourserver.com/submit"
    static let encryptionKey = "1234567890abcdef" // Must be 16 characters
}
```

---

## 📤 JSON Payload Format

```json
{
  "local_ip": "192.168.1.45",
  "ip": "54.45.23.22",
  "user_agent": "ChallengeApp/13232 CFNetwork/3826.500.131 Darwin/24.5.0",
  "vpn": true,
  "language": "en-US",
  "timezone": "Europe/Lisbon",
  "location": [40.3, -3.23],
  "location_name": "Madrid, Spain",
  "user_agent_webkit": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)..."
}
```

---

## 🧱 Architecture

The app follows a clean and modular **MVVM architecture** with protocol-based service injection and reactive Combine flows.

### Structure:

```
Feature/
 └── DeviceInfo/
      ├── View/
        │    ├── DeviceInfoView
        │    └── DeviceInfoCard
      └── ViewModel/
              └── DeviceInfoViewModel

Data/
 ├── Model/
    ├── DeviceInfo
 ├── Service/
 │    ├── LocationService
 │    ├── NetworkService
 │    ├── CryptoService
 │    └── NetworkUtility
 └── Collector/
      └── DeviceInfoCollector

Utils/
 └── Constants
```

### Key principles:

- ✅ Protocol-Oriented Services
- ✅ Reactive flow with Combine
- ✅ Single-responsibility per layer
- ✅ Encapsulation of side effects
- ✅ Error handling via separate publishers
- ✅ Async permission tracking

---

## 📸 Recording
https://github.com/user-attachments/assets/8b937cfe-3bc6-49bd-94e4-e7712b8c9903


