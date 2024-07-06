//
//  ContentView.swift
//  miniHydro
//
//  Created by Konstantin Dovnar on 04.07.2024.
//

import SwiftUI
import SwiftData
import HealthKit

class Manager: ObservableObject {
    @Published var permissionStatus: HKAuthorizationStatus = .notDetermined
    
    @AppStorage("storedNumber") private var storedNumber: Double?
    @Published var inputValue: String = ""
    
    var isNumberStored: Bool {
        return storedNumber != nil
    }
    
    var storedNumberValue: Double? {
        return storedNumber
    }
    
    func saveNumber() {
        if let value = Double(inputValue) {
            storedNumber = value
        }
    }
    
    
    private var healthStore = HKHealthStore()
    
    init() {
        checkHealthKitPermission()
    }
    
    func requestPermission() {
        healthStore.requestAuthorization(toShare: [waterType], read: []) { success, error in
            DispatchQueue.main.async {
                self.permissionStatus = self.checkWaterPermission()
            }
        }
    }
    
    func checkHealthKitPermission() {
        self.permissionStatus = self.checkWaterPermission()
    }
    
    private func checkWaterPermission() -> HKAuthorizationStatus {
        return healthStore.authorizationStatus(for: waterType)
    }
    
    private let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
    
    func hydrate() {
        let quantity = HKQuantity(unit: HKUnit.literUnit(with: .milli), doubleValue: storedNumberValue!)
        let x = HKQuantitySample(type: waterType, quantity: quantity, start: .now, end: .now)
        healthStore.save(x) { success, error in }
    }
}

struct ContentView: View {
    @StateObject var manager = Manager()
    
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
            } else if (manager.storedNumberValue == nil) {
                TextField("Enter a number", text: $manager.inputValue)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    manager.saveNumber()
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
