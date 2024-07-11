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
    private var unit: HKUnit? = nil
    
    private init() {
        getPrefferedUnit()
    }
    
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
    
    func getUnit() -> HKUnit {
        return unit ?? HKUnit.literUnit(with: .milli)
    }
    
    func requestHealthKitPermission(completion: @escaping (Bool, (any Error)?) -> Void) {
        healthKit.requestAuthorization(toShare: [waterType], read: []) { success, error in
            self.getPrefferedUnit()
            completion(success, error)
        }
    }
    
    func checkHealthKitPermission() -> HKAuthorizationStatus {
        getPrefferedUnit()
        return healthKit.authorizationStatus(for: waterType)
    }
    
    func hydrate() {
        let quantity = getVolume()
        if(quantity == nil) {
            return
        }
        
        let date: Date = .now
        let sample = HKQuantitySample(type: waterType, quantity: quantity!, start: date, end: date)
        healthKit.save(sample) { success, error in}
    }
    
    func cleanVolume() {
        userDefaults.removeObject(forKey: Manager.volumeKey)
    }
    
    private func getPrefferedUnit() {
        healthKit.preferredUnits(for: [waterType], completion: { units, error in
            self.unit = units[self.waterType] ?? HKUnit.literUnit(with: .milli)
        })
    }
    
    func getVolumeString() -> String {
        let unit = self.unit
        let volume = self.getVolume()
        
        if(unit == nil || volume == nil) {
            return ""
        }
        
        let volumeByUnit = String(format:"%.2f", volume!.doubleValue(for: unit!))
        return "+ \(volumeByUnit) \(unit!.format())"
    }
}

extension HKUnit {
    func format() -> String {
        switch(self) {
        case HKUnit.literUnit(with: .milli):
            return "mL"
        case HKUnit.fluidOunceUS():
            return "oz"
        case HKUnit.fluidOunceImperial():
            return "oz"
        default:
            return self.unitString
        }
    }
}
