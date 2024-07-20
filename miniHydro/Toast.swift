//
//  Toast.swift
//  miniHydro
//
//  Created by Konstantin Dovnar on 21.07.2024.
//

import Foundation
import SwiftUI

struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(8)
            .padding(.bottom, 50)
            .shadow(radius: 10)
    }
}

class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var message: String = ""
    @Published var showToast: Bool = false
    
    private init() {}
    
    func show(_ message: String, duration: Double = 2.0) {
        self.message = message
        self.showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.showToast = false
            }
        }
    }
}

struct ToastOverlay: View {
    @ObservedObject var toastManager = ToastManager.shared

    var body: some View {
        ZStack {
            if toastManager.showToast {
                VStack {
                    Spacer()
                    ToastView(message: toastManager.message)
                        .transition(AnyTransition.opacity.animation(.easeInOut))
                }
                .zIndex(1) // ensure the toast is on top
            }
        }
        .animation(.easeInOut, value: toastManager.showToast)
    }
}
