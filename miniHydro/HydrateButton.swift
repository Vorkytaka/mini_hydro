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
                onTap()
                
                withAnimation {
                    isTapped = true
                    animate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    animate = false
                }
            }) {
                Circle()
                    .fill(.background)
                    .frame(width: 150, height: 150)
                    .overlay(
                        Text(text)
                            .font(.title3)
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                    )
            }
        }
        .frame(width: 200, height: 200)
    }
}
