//
//  NotificationManager.swift
//  HIG
//
//  Local notifications manager that listens to TaskEventBus and schedules notifications.
//

import Foundation
import UserNotifications
import SwiftUI
import Combine

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func schedule(for event: TaskEvent) {
        let content = UNMutableNotificationContent()
        content.title = "Task Update"
        content.body = body(for: event)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func body(for event: TaskEvent) -> String {
        switch event {
        case .created(let t): return "Created: \(t.title)"
        case .updated(let t): return "Updated: \(t.title)"
        case .statusChanged(_, _, let to): return "Status: \(to.rawValue.capitalized)"
        case .checklistUpdated(_, let p): return "Checklist: \(Int(p * 100))%"
        case .deleted: return "Deleted"
        }
    }
}

// Hook up notifications to TaskEventBus
final class TaskEventNotificationBridge {
    static let shared = TaskEventNotificationBridge()
    private var observer: AnyCancellable?

    private init() {
        let bus = TaskEventBus.shared
        observer = bus.$lastEvent.sink { event in
            guard let event else { return }
            Task { await NotificationManager.shared.requestAuthorization() }
            NotificationManager.shared.schedule(for: event)
        }
    }
}
