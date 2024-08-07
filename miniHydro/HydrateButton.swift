//
//  HydrateButton.swift
//  miniHydro
//
//  Created by Konstantin Dovnar on 07.07.2024.
//

import Foundation
import SwiftUI

struct HydrateButton: View {
    let text: String
    let onTap: () -> Void
    
    @State private var isTapped = true
    @State private var animate = false
    
    @State private var isButtonEnabled = true
    
    var body: some View {
        ZStack {
            if isTapped {
                Circle()
                    .fill(.background)
                    .scaleEffect(animate ? 4 : 0.5)
                    .opacity(animate ? 0 : 0.5)
                    .animation(animate ? Animation.easeOut(duration: 0.6) : nil, value: animate)
            }
            
            Button(action: {
                if isButtonEnabled {
                    isButtonEnabled = !isButtonEnabled
                    onTap()
                    
                    withAnimation {
                        isTapped = true
                        animate = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        animate = false
                        isButtonEnabled = true
                    }
                }
            }) {
                Circle()
                    .fill(.background)
                    .frame(minWidth: 100, maxWidth: 200, minHeight: 100, maxHeight: 200)
                    .overlay(
                        Text(text)
                            .font(.title3)
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                            .padding()
                    )
            }
            .disabled(!isButtonEnabled)
        }
        .frame(width: 200, height: 200)
    }
}
