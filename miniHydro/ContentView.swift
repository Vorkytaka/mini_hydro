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
    @Published var unit: HKUnit? = nil
    @Published var permissionStatus: HKAuthorizationStatus = .notDetermined
    @Published var inputValue: String = ""
    @Published var volumeInputError = false
    
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
        unit = manager.getUnit()
    }
    
    func hydrate() {
        manager.hydrate()
    }
    
    func setVolume() {
        let withDot = inputValue.replacing(",", with: ".")
        if let quantity = Double(withDot) {
            manager.saveVolume(quantity: quantity, unit: manager.getUnit())
            checkVolume()
        } else {
            volumeInputError = true
        }
    }
    
    func hasVolume() -> Bool {
        return manager.getVolume() != nil
    }
    
    func cleanVolume() {
        inputValue = "\(volume!.doubleValue(for: manager.getUnit()))"
        manager.cleanVolume()
        checkVolume()
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    private let screenSize = UIScreen.main.bounds.size
    
    @StateObject var manager = UIManager()
    @State private var percent: Double = 0.7
    @State private var waveOffset = Angle(degrees: 0)
    
    var body: some View {
        let status = manager.permissionStatus
        
        ZStack {
            Wave(offSet: Angle(degrees: waveOffset.degrees))
                .fill(Color.blue)
                .ignoresSafeArea(.all)
                .offset(y: screenSize.height * percent)
            
            if(status == .sharingDenied) {
                RejectPermission()
            } else if (status == .notDetermined) {
                RequestPermission()
                    .environmentObject(manager)
            } else if (!manager.hasVolume()) {
                RequestVolume()
                    .environmentObject(manager)
            } else {
                let unit = manager.unit!
                let volume = manager.volume!
                
                let volumeByUnit = String(format:"%.2f", volume.doubleValue(for: unit))
                let volumeStr = "+ \(volumeByUnit) \(unit.format())"
                
                VStack {
                    Spacer()
                    HydrateButton(text: volumeStr, onTap: manager.hydrate)
                    Spacer()
                    Button(action: manager.cleanVolume) {
                        VStack {
                            Image(systemName: "waterbottle")
                                .font(.largeTitle)
                                .accessibility(hidden: true)
                                .frame(width: 76)
                            Text("Update\nbottle")
                                .font(.caption)
                        }
                        .padding()
                    }
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .onAppear {
            manager.checkHealthKitPermission()
            updateWaveSize()
        }
        .onChange(of: scenePhase) {
            if(scenePhase == .active) {
                manager.checkHealthKitPermission()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                self.waveOffset = Angle(degrees: 360)
            }
        }
        .onChange(of: manager.permissionStatus) {
            updateWaveSize()
        }
        .onChange(of: manager.volume) {
            updateWaveSize()
        }
    }
    
    private func updateWaveSize() {
        withAnimation {
            if(manager.permissionStatus != .sharingAuthorized) {
                percent = 0.7
            }
            else if(!manager.hasVolume()) {
                percent = 0.5
            }
            else {
                percent = 0.05
            }
        }
    }
}

struct RejectPermission : View {
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("We Need Your Permission")
                .font(.title)
                .fontWeight(.bold)
                .padding([.bottom], 12)
            Text("""
To help you stay on top of your hydration goals, we need permission to update your water intake in the Apple Health app. This allows us to keep all your health data in one convenient place.
""")
            Spacer()
            Text("How to Grant Permission:")
                .font(.headline)
                .fontWeight(.bold)
                .padding([.bottom], 12)
            Text("""
1. Open the Settings app on your iPhone.
2. Tap on Health settings.
3. Open Data Access & Devices.
4. Find and select miniHydro from the list.
5. Toggle on the permission to update your Water Intake.
""")
            
            Spacer()
            Button(action: {
                openAppSettings()
            }) {
                Text("Open settings")
                    .foregroundColor(.primary)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(.background))
                    .padding(.bottom)
            }
        }
        .padding(.horizontal)
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { success in
                print("Settings opened: \(success)")
            })
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

struct Wave: Shape {
    
    var offSet: Angle
    
    var animatableData: Double {
        get { offSet.degrees }
        set { offSet = Angle(degrees: newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        let lowestWave = 0.02
        let highestWave = 1.00
        
        let newPercent = lowestWave + (highestWave - lowestWave)
        let waveHeight = 0.015 * rect.height
        let yOffSet = CGFloat(1 - newPercent) * (rect.height - 4 * waveHeight) + 2 * waveHeight
        let startAngle = offSet
        let endAngle = offSet + Angle(degrees: 360 + 10)
        
        p.move(to: CGPoint(x: 0, y: yOffSet + waveHeight * CGFloat(sin(offSet.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 5) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            p.addLine(to: CGPoint(x: x, y: yOffSet + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
        }
        
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        
        return p
    }
}

#Preview {
    ContentView()
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
