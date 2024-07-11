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
                Text(NSLocalizedString("WELCOME__BUTTON", comment: ""))
                    .foregroundColor(.primary)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(.background))
                    .padding(.bottom)
            }.padding(.horizontal)
        }
        .padding(.horizontal)
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
            InformationDetailView(title: NSLocalizedString("WELCOME__HINT_1_TITLE", comment: ""), subTitle: NSLocalizedString("WELCOME__HINT_1_DESCRIPTION", comment: ""), imageName: "drop.fill", imageColor: Color.blue)

            InformationDetailView(title: NSLocalizedString("WELCOME__HINT_2_TITLE", comment: ""), subTitle: NSLocalizedString("WELCOME__HINT_2_DESCRIPTION", comment: ""), imageName: "square.and.arrow.down", imageColor: nil)

            InformationDetailView(title: NSLocalizedString("WELCOME__HINT_3_TITLE", comment: ""), subTitle: NSLocalizedString("WELCOME__HINT_3_DESCRIPTION", comment: ""), imageName: "person.badge.key.fill", imageColor: nil)
        }
        .padding(.horizontal)
    }
}

struct TitleView: View {
    var body: some View {
        VStack {
            Text(NSLocalizedString("WELCOME__WELCOME_TO", comment: ""))
                .fontWeight(.black)
                .font(.system(size: 36))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text(NSLocalizedString("APP_NAME", comment: ""))
                .fontWeight(.black)
                .font(.system(size: 36))
                .foregroundColor(.blue)
        }
    }
}
