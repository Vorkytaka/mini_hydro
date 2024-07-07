//
//  HydrateButton.swift
//  miniHydro
//
//  Created by Konstantin Dovnar on 07.07.2024.
//

import Foundation
import SwiftUI

struct HydrateButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            // Circle button design
            Circle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .overlay(
                    Text("Hydrate")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                )
        }
    }
}
