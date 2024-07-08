//
//  RequestVolume.swift
//  miniHydro
//
//  Created by Konstantin Dovnar on 09.07.2024.
//

import Foundation
import SwiftUI
import HealthKit

struct RequestVolume : View {
    let volumeUnits: [HKUnit] = [.literUnit(with: .milli), .fluidOunceUS(), .fluidOunceImperial()]
    
    @EnvironmentObject var manager: UIManager
    @FocusState var focused: Bool?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("To help you track your water intake, we need to know the volume of the glass or bottle you typically use.")
                .padding([.top, .bottom], 24)
            HStack {
                Text("Volume")
                TextField("500", text: $manager.inputValue)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.trailing)
                    .focused($focused, equals: true)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.focused = true
                        }
                    }
                Picker("Select Unit", selection: $manager.selectedUnit) {
                    ForEach(volumeUnits, id: \.self) { unit in
                        Text("\(unit)").tag(unit)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)
            }
            .padding([.bottom], 24)
            
            Button(action: {
                manager.setVolume()
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(.blue))
                    .padding(.bottom)
            }.padding(.horizontal)
            Spacer()
        }
        .padding(.horizontal)
    }
}
