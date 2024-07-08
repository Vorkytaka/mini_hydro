//
//  RequestPermission.swift
//  miniHydro
//
//  Created by Konstantin Dovnar on 08.07.2024.
//

import Foundation
import SwiftUI

struct RequestPermission : View {
    @EnvironmentObject var manager: UIManager
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            TitleView()
            InformationContainerView()
            Spacer()
            Button(action: {
                manager.requestPermission()
            }) {
                Text("Grant permission")
                    .foregroundColor(.primary)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(.background))
                    .padding(.bottom)
            }.padding(.horizontal)
        }
        }
}

struct InformationDetailView: View {
    let title: String
    let subTitle: String
    let imageName: String
    let imageColor: Color?

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(imageColor ?? .primary)
                .padding()
                .accessibility(hidden: true)
                .frame(width: 76)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)

                Text(subTitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}

struct InformationContainerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            InformationDetailView(title: "Stay Hydrated", subTitle: "Quickly log your water intake with just one tap.", imageName: "drop.fill", imageColor: Color.blue)

            InformationDetailView(title: "Permission Needed", subTitle: "We only need permission to save your water intake to Apple Health.", imageName: "square.and.arrow.down", imageColor: nil)

            InformationDetailView(title: "Your Privacy Matters", subTitle: "We don't read or access any other data.", imageName: "person.badge.key.fill", imageColor: nil)
        }
        .padding(.horizontal)
    }
}

struct TitleView: View {
    var body: some View {
        VStack {
            Text("Welcome to")
                .fontWeight(.black)
                .font(.system(size: 36))
                .foregroundColor(.primary)

            Text("miniHydro")
                .fontWeight(.black)
                .font(.system(size: 36))
                .foregroundColor(.blue)
        }
    }
}
