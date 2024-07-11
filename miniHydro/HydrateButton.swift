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
    
    var body: some View {
        Button(action: onTap) {
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
}
