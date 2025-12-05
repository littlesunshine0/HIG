//
//  AboutView.swift
//  HIG
//
//  About view with community links and app information
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                // App Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "book.fill")
                        .font(.largeTitle)
                        .imageScale(.large)
                        .foregroundStyle(.white)
                }
                
                // App Name
                Text("DocuChat")
                    .font(.title.bold())
                
                // Tagline
                Text("Your AI Documentation Assistant")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Version
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("Version \(version) (\(build))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 32)
            
            Divider()
            
            // Community Links
            VStack(alignment: .leading, spacing: 16) {
                Text("Resources")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                CommunityLinkRow(
                    icon: "apple.logo",
                    title: "Apple Human Interface Guidelines",
                    description: "Official design documentation for Apple platforms",
                    url: "https://developer.apple.com/design/human-interface-guidelines/"
                )
                
                CommunityLinkRow(
                    icon: "cpu",
                    title: "Ollama Documentation",
                    description: "Run large language models locally",
                    url: "https://ollama.ai/"
                )
                
                CommunityLinkRow(
                    icon: "swift",
                    title: "SwiftUI Documentation",
                    description: "Build apps with SwiftUI",
                    url: "https://developer.apple.com/documentation/swiftui/"
                )
            }
            .padding(24)
            
            Divider()
            
            // Footer
            VStack(spacing: 8) {
                Text("Built with ❤️ for the Apple developer community")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("© 2025 DocuChat. All rights reserved.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 16)
            
            Spacer()
        }
        .frame(width: 500, height: 600)
        .background(.background)
    }
}

// MARK: - Community Link Row

struct CommunityLinkRow: View {
    let icon: String
    let title: String
    let description: String
    let url: String
    
    @Environment(\.openURL) private var openURL
    @State private var isHovered = false
    
    var body: some View {
        Button {
            if let url = URL(string: url) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
                .accessibilityHidden(true)
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovered ? Color(.controlBackgroundColor) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(.separatorColor), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .help("Open \(title)")
        .accessibilityLabel("\(title). \(description)")
        .accessibilityHint("Opens in your web browser")
        .accessibilityAddTraits(.isLink)
    }
}

// MARK: - Preview

#Preview {
    AboutView()
}
