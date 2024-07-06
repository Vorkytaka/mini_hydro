//
//  ContentView.swift
//  miniHydro
//
//  Created by Konstantin Dovnar on 04.07.2024.
//

import SwiftUI
import SwiftData
import HealthKit

class Manager {
    private static let volumeKey = "volume"
    private static let volumeValueKey = "volumeValue"
    private static let volumeUnitKey = "volumeUnit"
    
    static let shared = Manager()
    
    private let healthKit = HKHealthStore()
    private let userDefaults = UserDefaults()
    
    private let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
    
    private init() {}
    
    func saveVolume(quantity: Double, unit: HKUnit) {
        let dictionaryToSave = [
            Manager.volumeValueKey: quantity,
            Manager.volumeUnitKey: unit.unitString
        ] as [String : Any]
        
        userDefaults.set(dictionaryToSave, forKey: Manager.volumeKey)
    }

    func getVolume() -> HKQuantity? {
        if let savedDictionary = userDefaults.dictionary(forKey: Manager.volumeKey),
           let value = savedDictionary[Manager.volumeValueKey] as? Double,
           let unitString = savedDictionary[Manager.volumeUnitKey] as? String {
            let unit = HKUnit(from: unitString)
            return HKQuantity(unit: unit, doubleValue: value)
        }
        return nil
    }
    
    func requestHealthKitPermission(completion: @escaping (Bool, (any Error)?) -> Void) {
        healthKit.requestAuthorization(toShare: [waterType], read: []) { success, error in
            completion(success, error)
        }
    }
    
    func checkHealthKitPermission() -> HKAuthorizationStatus {
        return healthKit.authorizationStatus(for: waterType)
    }
    
    func hydrate() {
        let quantity = getVolume()
        if(quantity == nil) {
            return
        }
        let sample = HKQuantitySample(type: waterType, quantity: quantity!, start: .now, end: .now)
        healthKit.save(sample) { success, error in }
    }
}

class UIManager: ObservableObject {
    private let manager = Manager.shared

    @Published var volume: HKQuantity? = nil
    @Published var permissionStatus: HKAuthorizationStatus = .notDetermined
    @Published var inputValue: String = ""
    
    init() {
        checkHealthKitPermission()
        checkVolume()
    }
    
    func requestPermission() {
        manager.requestHealthKitPermission(completion: { success, error in
            DispatchQueue.main.async {
                self.checkHealthKitPermission()
            }
        })
    }
    
    func checkHealthKitPermission() {
        self.permissionStatus = manager.checkHealthKitPermission()
    }
    
    func checkVolume() {
        volume = manager.getVolume()
    }
    
    func hydrate() {
        manager.hydrate()
    }
    
    func setVolume() {
        if let quantity = Double(inputValue) {
            manager.saveVolume(quantity: quantity, unit: HKUnit.literUnit(with: .milli))
            checkVolume()
        }
    }
    
    func hasVolume() -> Bool {
        return manager.getVolume() != nil
    }
}

struct ContentView: View {
    @StateObject var manager = UIManager()
    
    var body: some View {
        VStack {
            let status = manager.permissionStatus
            if(status == .sharingDenied) {
                Text("You reject permission")
            } else if (status == .notDetermined) {
                Button(action: {
                    manager.requestPermission()
                }) {
                    Text("Request Permission")
                }
            } else if (!manager.hasVolume()) {
                TextField("Enter a number", text: $manager.inputValue)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    manager.setVolume()
                }) {
                    Text("Submit")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Button(action: {
                    manager.hydrate()
                }) {
                    Text("HYDRATE")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .onAppear {
            manager.checkHealthKitPermission()
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



#Preview {
    ContentView()
}
