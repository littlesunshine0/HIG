//
//  NotificationSystem.swift
//  HIG
//
//  Notification System - Local, push, in-app notifications
//

import SwiftUI

struct NotificationSystemView: View {
    @State private var selectedTab = "Inbox"
    @State private var notifications: [AppNotification] = AppNotification.samples
    
    let tabs = ["Inbox", "Push", "In-App", "Settings"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "bell.fill").font(.title2).foregroundStyle(.orange)
                Text("Notification System").font(.title2.bold())
                Spacer()
                
                if unreadCount > 0 {
                    Text("\(unreadCount) unread")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.orange.opacity(0.2)))
                }
            }
            .padding()
            .background(.regularMaterial)
            
            // Tabs
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        HStack(spacing: 4) {
                            Text(tab)
                            if tab == "Inbox" && unreadCount > 0 {
                                Text("\(unreadCount)").font(.caption2)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Circle().fill(Color.red))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(selectedTab == tab ? Color.orange.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            // Content
            Group {
                switch selectedTab {
                case "Inbox": NotificationInboxView(notifications: $notifications)
                case "Push": PushNotificationView()
                case "In-App": InAppNotificationView()
                case "Settings": NotificationSettingsView()
                default: EmptyView()
                }
            }
        }
    }
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
}

struct NotificationInboxView: View {
    @Binding var notifications: [AppNotification]
    @State private var filter = "All"
    
    var body: some View {
        HSplitView {
            // List
            VStack(spacing: 0) {
                HStack {
                    Picker("Filter", selection: $filter) {
                        Text("All").tag("All")
                        Text("Unread").tag("Unread")
                        Text("Important").tag("Important")
                    }
                    .pickerStyle(.segmented)
                    
                    Spacer()
                    
                    Button("Mark All Read") {
                        for i in notifications.indices {
                            notifications[i].isRead = true
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                Divider()
                
                List {
                    ForEach(filteredNotifications) { notification in
                        NotificationRow(notification: notification)
                            .onTapGesture {
                                if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                                    notifications[index].isRead = true
                                }
                            }
                    }
                    .onDelete { indexSet in
                        notifications.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
            }
            
            // Preview
            VStack(spacing: 20) {
                Image(systemName: "bell.badge").font(.system(size: 60)).foregroundStyle(.secondary)
                Text("Select a notification").foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var filteredNotifications: [AppNotification] {
        switch filter {
        case "Unread": return notifications.filter { !$0.isRead }
        case "Important": return notifications.filter { $0.priority == .high }
        default: return notifications
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle().fill(notification.type.color.opacity(0.2)).frame(width: 40, height: 40)
                Image(systemName: notification.type.icon).foregroundStyle(notification.type.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title).font(.subheadline.bold())
                    if !notification.isRead {
                        Circle().fill(.blue).frame(width: 8, height: 8)
                    }
                }
                Text(notification.message).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                Text(notification.timeAgo).font(.caption2).foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Priority
            if notification.priority == .high {
                Image(systemName: "exclamationmark.circle.fill").foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
        .opacity(notification.isRead ? 0.7 : 1)
    }
}

struct PushNotificationView: View {
    @State private var title = ""
    @State private var notificationBody = ""
    @State private var targetAudience = "All Users"
    @State private var scheduledTime = Date()
    @State private var isScheduled = false
    
    var body: some View {
        HSplitView {
            // Composer
            VStack(alignment: .leading, spacing: 20) {
                Text("Compose Push Notification").font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title").font(.subheadline)
                    TextField("Notification title", text: $title).textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Body").font(.subheadline)
                    TextEditor(text: $notificationBody)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Audience").font(.subheadline)
                    Picker("", selection: $targetAudience) {
                        Text("All Users").tag("All Users")
                        Text("Active Users").tag("Active Users")
                        Text("New Users").tag("New Users")
                        Text("Premium Users").tag("Premium Users")
                    }
                }
                
                Toggle("Schedule for later", isOn: $isScheduled)
                
                if isScheduled {
                    DatePicker("Send at", selection: $scheduledTime)
                }
                
                Spacer()
                
                HStack {
                    Button("Save Draft") {}.buttonStyle(.bordered)
                    Button("Send Now") {}.buttonStyle(.borderedProminent).tint(.orange)
                }
            }
            .padding()
            .frame(minWidth: 350)
            
            // Preview
            VStack(spacing: 20) {
                Text("Preview").font(.headline)
                
                // iOS Preview
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "app.fill").foregroundStyle(.orange)
                        Text("Your App").font(.caption.bold())
                        Spacer()
                        Text("now").font(.caption).foregroundStyle(.secondary)
                    }
                    
                    Text(title.isEmpty ? "Notification Title" : title).font(.subheadline.bold())
                    Text(notificationBody.isEmpty ? "Notification body text goes here..." : notificationBody).font(.caption).foregroundStyle(.secondary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.controlBackgroundColor)))
                .frame(width: 320)
                
                Text("iOS Notification").font(.caption).foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct InAppNotificationView: View {
    @State private var notificationType = "Banner"
    @State private var position = "Top"
    @State private var duration = 5.0
    @State private var showPreview = false
    
    var body: some View {
        HSplitView {
            // Settings
            VStack(alignment: .leading, spacing: 20) {
                Text("In-App Notification Settings").font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type").font(.subheadline)
                    Picker("", selection: $notificationType) {
                        Text("Banner").tag("Banner")
                        Text("Toast").tag("Toast")
                        Text("Modal").tag("Modal")
                        Text("Snackbar").tag("Snackbar")
                    }
                    .pickerStyle(.segmented)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Position").font(.subheadline)
                    Picker("", selection: $position) {
                        Text("Top").tag("Top")
                        Text("Bottom").tag("Bottom")
                        Text("Center").tag("Center")
                    }
                    .pickerStyle(.segmented)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration: \(Int(duration))s").font(.subheadline)
                    Slider(value: $duration, in: 1...15, step: 1)
                }
                
                Divider()
                
                Text("Styles").font(.headline)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    NotificationStyleButton(name: "Success", color: .green, icon: "checkmark.circle.fill")
                    NotificationStyleButton(name: "Error", color: .red, icon: "xmark.circle.fill")
                    NotificationStyleButton(name: "Warning", color: .orange, icon: "exclamationmark.triangle.fill")
                    NotificationStyleButton(name: "Info", color: .blue, icon: "info.circle.fill")
                }
                
                Spacer()
                
                Button("Preview Notification") {
                    showPreview = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding()
            .frame(minWidth: 350)
            
            // Preview Area
            ZStack {
                Color(.controlBackgroundColor)
                
                VStack {
                    if showPreview && position == "Top" {
                        InAppBannerPreview()
                            .transition(.move(edge: .top))
                    }
                    
                    Spacer()
                    
                    Text("App Content").foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if showPreview && position == "Bottom" {
                        InAppBannerPreview()
                            .transition(.move(edge: .bottom))
                    }
                }
                .padding()
            }
            .animation(.spring(), value: showPreview)
            .onTapGesture { showPreview = false }
        }
    }
}

struct NotificationStyleButton: View {
    let name: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(name).font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
    }
}

struct InAppBannerPreview: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            VStack(alignment: .leading) {
                Text("Success!").font(.subheadline.bold())
                Text("Your changes have been saved.").font(.caption)
            }
            Spacer()
            Image(systemName: "xmark").foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
        .shadow(radius: 5)
    }
}

struct NotificationSettingsView: View {
    @State private var pushEnabled = true
    @State private var soundEnabled = true
    @State private var badgeEnabled = true
    @State private var quietHoursEnabled = false
    @State private var quietStart = Date()
    @State private var quietEnd = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Notification Settings").font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Push Notifications", isOn: $pushEnabled)
                Toggle("Sound", isOn: $soundEnabled)
                Toggle("Badge Count", isOn: $badgeEnabled)
                
                Divider()
                
                Toggle("Quiet Hours", isOn: $quietHoursEnabled)
                
                if quietHoursEnabled {
                    HStack {
                        DatePicker("From", selection: $quietStart, displayedComponents: .hourAndMinute)
                        DatePicker("To", selection: $quietEnd, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Text("Notification Categories").font(.headline)
            
            VStack(spacing: 12) {
                NotificationCategoryRow(name: "Marketing", enabled: true)
                NotificationCategoryRow(name: "Updates", enabled: true)
                NotificationCategoryRow(name: "Social", enabled: true)
                NotificationCategoryRow(name: "Reminders", enabled: true)
                NotificationCategoryRow(name: "Promotions", enabled: false)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

struct NotificationCategoryRow: View {
    let name: String
    @State var enabled: Bool
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Toggle("", isOn: $enabled).labelsHidden()
        }
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    let priority: Priority
    var isRead: Bool
    let timestamp: Date
    
    enum NotificationType {
        case system, social, update, marketing
        
        var icon: String {
            switch self {
            case .system: return "gear"
            case .social: return "person.2"
            case .update: return "arrow.down.circle"
            case .marketing: return "megaphone"
            }
        }
        
        var color: Color {
            switch self {
            case .system: return .blue
            case .social: return .purple
            case .update: return .green
            case .marketing: return .orange
            }
        }
    }
    
    enum Priority { case low, normal, high }
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
    
    static var samples: [AppNotification] {
        [
            AppNotification(title: "New Update Available", message: "Version 2.0 is now available with exciting new features!", type: .update, priority: .high, isRead: false, timestamp: Date().addingTimeInterval(-300)),
            AppNotification(title: "John liked your post", message: "Your recent post received a new like", type: .social, priority: .normal, isRead: false, timestamp: Date().addingTimeInterval(-1800)),
            AppNotification(title: "Security Alert", message: "New login detected from a new device", type: .system, priority: .high, isRead: false, timestamp: Date().addingTimeInterval(-3600)),
            AppNotification(title: "Special Offer", message: "Get 50% off on premium subscription!", type: .marketing, priority: .low, isRead: true, timestamp: Date().addingTimeInterval(-86400)),
            AppNotification(title: "Backup Complete", message: "Your data has been successfully backed up", type: .system, priority: .normal, isRead: true, timestamp: Date().addingTimeInterval(-172800)),
        ]
    }
}

#Preview {
    NotificationSystemView()
        .frame(width: 1000, height: 700)
}
