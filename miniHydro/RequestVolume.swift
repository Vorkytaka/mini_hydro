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
                    .onChange(of: manager.inputValue) {
                        let filtered = manager.inputValue.filter { "0123456789,.".contains($0) }
                        if filtered != manager.inputValue {
                                        manager.inputValue = filtered
                                    }
                                }
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.trailing)
                    .focused($focused, equals: true)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.focused = true
                        }
                    }
                Text("\(manager.unit!.format())")
                    .pickerStyle(.menu)
                    .frame(width: 100)
            }
            if(manager.volumeInputError) {
                Text("Invalid input. Please enter a positive number for the bottle volume.")
                    .multilineTextAlignment(.trailing)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }
            
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
            }
            .padding(.horizontal)
            .padding([.top], 24)
            Spacer()
        }
        .padding(.horizontal)
    }
}
