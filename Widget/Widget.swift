//
//  Widget.swift
//  Widget
//
//  Created by Konstantin Dovnar on 07.07.2024.
//

import WidgetKit
import SwiftUI
import AppIntents

struct HydrateIntent : AppIntent {
    static var title: LocalizedStringResource = "Complete Task"
    static var description: IntentDescription = IntentDescription("Complete selected task")
    
    func perform() async throws -> some IntentResult {
        Manager.shared.hydrate()
        return .result()
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), state: .success)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), state: .success)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, state: getState())
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getState() -> WidgetState {
        let healthKitPermission = Manager.shared.checkHealthKitPermission()
        if(healthKitPermission != .sharingAuthorized) {
            return .noPermissions
        }
        
        let volume = Manager.shared.getVolume()
        if(volume == nil) {
            return .noVolume
        }
        
        return .success
    }
}

enum WidgetState {
    case noPermissions
    case noVolume
    case success
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let state: WidgetState
}

struct WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        switch(entry.state) {
        case .noPermissions:
            Text("Give permissions")
        case .noVolume:
            Text("Set volume")
        case .success:
            Button(intent: HydrateIntent()) {
                Circle()
                    .fill(Color.blue)
                    .frame(minWidth: 100, minHeight: 100)
                    .overlay(
                        Text(Manager.shared.getVolumeString())
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding()
                    )
            }
        }
    }
}

struct MyWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName(NSLocalizedString("WIDGET__TITLE", comment: ""))
        .description(NSLocalizedString("WIDGET__DESCRIPTION", comment: ""))
    }
}

#Preview(as: .systemSmall) {
    MyWidget()
} timeline: {
    SimpleEntry(date: .now, state: .success)
    SimpleEntry(date: .now, state: .noPermissions)
    SimpleEntry(date: .now, state: .noVolume)
}
