//
//  DeviceInfoViewModel.swift
//  DeviceInfo
//
//  Created by Yuri on 17/07/25.
//

import Combine
import UIKit
import CoreLocation

// MARK: - ViewModel
@MainActor
final class DeviceInfoViewModel: ObservableObject {
    @Published var deviceInfo: DeviceInfo?
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    private let collector: DeviceInfoCollectorProtocol
    private let locationService: LocationServiceProtocol
    private let network: NetworkServiceProtocol
    private let crypto: CryptoServiceProtocol
    
    init(
        collector: DeviceInfoCollectorProtocol = DeviceInfoCollector(),
        locationService: LocationServiceProtocol = LocationService(),
        network: NetworkServiceProtocol = NetworkService(),
        crypto: CryptoServiceProtocol = CryptoService()
    ) {
        self.collector = collector
        self.locationService = locationService
        self.network = network
        self.crypto = crypto
        
        bindToLocationUpdates()
    }
    
    func requestLocation() {
        locationService.requestLocation()
    }

    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Private Methods
private extension DeviceInfoViewModel {
    func bindToLocationUpdates() {
        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.loadInfo(with: location)
            }
            .store(in: &cancellables)
        
        locationService.locationErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                self.errorMessage = self.isLocationDenied(error)
                ? Constants.locationDenied : error.localizedDescription
            }
            .store(in: &cancellables)
    }
    
    func isLocationDenied(_ error: Error) -> Bool {
        (error as? CLError)?.code == .denied
    }
    
    func loadInfo(with location: (coordinate: [Double], name: String?)) {
        errorMessage = nil

        collector.fetchDeviceInfo(with: location)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] info in
                self?.deviceInfo = info
            })
            .flatMap { [weak self] info -> AnyPublisher<Bool, Error> in
                guard let self = self,
                      let data = try? JSONEncoder().encode(info) else {
                    return Fail(error: URLError(.cannotDecodeContentData)).eraseToAnyPublisher()
                }

                let encrypted = self.crypto.encrypt(data: data, key: Constants.encryptionKey)
                return self.network.send(data: encrypted)
            }
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
