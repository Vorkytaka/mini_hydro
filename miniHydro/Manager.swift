//
//  Manager.swift
//  miniHydro
//
//  Created by Konstantin Dovnar on 07.07.2024.
//

import Foundation
import HealthKit

class Manager {
    private static let volumeKey = "volume"
    private static let volumeValueKey = "volumeValue"
    private static let volumeUnitKey = "volumeUnit"
    
    static let shared = Manager()
    
    private let healthKit = HKHealthStore()
    private let userDefaults = UserDefaults(suiteName: "group.tk.vrk.miniHydro")!
    
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
