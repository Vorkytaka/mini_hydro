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
    
    func getVolumeString() -> String {
        return manager.getVolumeString()
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
                VStack {
                    Spacer()
                    HydrateButton(text: manager.getVolumeString(), onTap: manager.hydrate)
                    Spacer()
                    Button(action: manager.cleanVolume) {
                        VStack {
                            Image(systemName: "waterbottle")
                                .font(.largeTitle)
                                .accessibility(hidden: true)
                                .frame(width: 76)
                            Text(NSLocalizedString("MAIN__UPDATE_BOTTLE", comment: ""))
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
            Text(NSLocalizedString("REJECT__TITLE", comment: ""))
                .font(.title)
                .fontWeight(.bold)
                .padding([.bottom], 12)
            Text(NSLocalizedString("REJECT__EXPLANATION", comment: ""))
                .padding([.bottom], 32)
            
            Text(NSLocalizedString("REJECT__INSTRUCTION_TITLE", comment: ""))
                .font(.headline)
                .fontWeight(.bold)
                .padding([.bottom], 12)
            Text(NSLocalizedString("REJECT__INSTRUCTION_BODY", comment: ""))
            
            Spacer()
            Button(action: {
                openAppSettings()
            }) {
                Text(NSLocalizedString("REJECT__OPEN_SETTINGS", comment: ""))
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

