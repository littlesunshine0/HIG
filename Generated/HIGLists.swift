//
//  HIGLists.swift
//  Generated from Apple Human Interface Guidelines
//
//  HIG-compliant list and table components
//
//  Generated: 2025-11-25
//

import SwiftUI

// MARK: - HIG List Components

/// Standard list row with disclosure
struct HIGListRow<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            content
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}

/// List row with icon, title, and subtitle
struct HIGDetailRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconColor: Color = .accentColor

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }
}

/// Swipe actions container
struct HIGSwipeActions<Content: View>: View {
    let content: Content
    var deleteAction: (() -> Void)? = nil
    var editAction: (() -> Void)? = nil

    init(
        deleteAction: (() -> Void)? = nil,
        editAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.deleteAction = deleteAction
        self.editAction = editAction
        self.content = content()
    }

    var body: some View {
        content
            .swipeActions(edge: .trailing) {
                if let deleteAction {
                    Button(role: .destructive, action: deleteAction) {
                        Label("Delete", systemImage: "trash")
                    }
                }

                if let editAction {
                    Button(action: editAction) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
            }
    }
}

/// Section header following HIG styling
struct HIGSectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionTitle: String = "See All"

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)

            Spacer()

            if let action {
                Button(actionTitle, action: action)
                    .font(.subheadline)
            }
        }
    }
}

// MARK: - Preview

#Preview("HIG Lists") {
    List {
        Section {
            HIGDetailRow(icon: "person.fill", title: "Profile", subtitle: "View and edit")
            HIGDetailRow(icon: "gear", title: "Settings")
            HIGDetailRow(icon: "bell.fill", title: "Notifications", iconColor: .red)
        } header: {
            HIGSectionHeader(title: "Account")
        }
    }
}
