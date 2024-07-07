//
//  ContentView.swift
//  miniHydro
//
//  Created by Konstantin Dovnar on 04.07.2024.
//

import SwiftUI
import SwiftData
import HealthKit

class UIManager: ObservableObject {
    private let manager = Manager.shared

    @Published var volume: HKQuantity? = nil
    @Published var permissionStatus: HKAuthorizationStatus = .notDetermined
    @Published var inputValue: String = ""
    @Published var selectedUnit: HKUnit = HKUnit.literUnit(with: .milli)

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
            manager.saveVolume(quantity: quantity, unit: selectedUnit)
            checkVolume()
        }
    }
    
    func hasVolume() -> Bool {
        return manager.getVolume() != nil
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var manager = UIManager()
    
    let volumeUnits: [HKUnit] = [.literUnit(with: .milli), .fluidOunceUS(), .fluidOunceImperial()]
    
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
                
                Picker("Select Unit", selection: $manager.selectedUnit) {
                    ForEach(volumeUnits, id: \.self) { unit in
                        Text("\(unit)").tag(unit)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)

                
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
                HydrateButton(onTap: manager.hydrate)
            }
        }
        .onAppear {
            manager.checkHealthKitPermission()
        }
        .onChange(of: scenePhase) {
            if(scenePhase == .active) {
                manager.checkHealthKitPermission()
            }
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
