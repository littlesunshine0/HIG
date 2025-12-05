//
//  RelativisticViewsContainer.swift
//  HIG
//
//  Unified container for Temporal & Relativistic Views
//  Time-based visualizations with depth and perspective
//

import SwiftUI

// MARK: - Relativistic View Mode

enum RelativisticViewMode: String, CaseIterable, Identifiable {
    case parallaxStream = "Parallax Stream"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .parallaxStream: return "arrow.left.arrow.right"
        }
    }
    
    var description: String {
        switch self {
        case .parallaxStream:
            return "Timeline with depth - urgent moves fast, background moves slow"
        }
    }
    
    var color: Color {
        switch self {
        case .parallaxStream: return .purple
        }
    }
}

// MARK: - Relativistic Views Container

struct RelativisticViewsContainer: View {
    @State private var selectedMode: RelativisticViewMode = .parallaxStream
    @State private var showModeSelector = true
    @State private var isFullscreen = false
    
    var body: some View {
        ZStack {
            visualizationContent
            
            if showModeSelector {
                VStack {
                    relativisticModeSelectorBar
                    Spacer()
                }
            }
            
            if !showModeSelector {
                VStack {
                    HStack {
                        floatingModeButton
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .ignoresSafeArea(isFullscreen ? .all : [])
    }
    
    @ViewBuilder
    private var visualizationContent: some View {
        switch selectedMode {
        case .parallaxStream:
            ParallaxStreamView()
        }
    }
    
    private var relativisticModeSelectorBar: some View {
        HStack(spacing: 0) {
            ForEach(RelativisticViewMode.allCases) { mode in
                RelativisticModeTab(
                    mode: mode,
                    isSelected: selectedMode == mode
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedMode = mode
                    }
                }
            }
            
            Spacer()
            
            // Info about relativistic views
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.2.circlepath")
                    .foregroundStyle(.purple)
                Text("Time Dilation Effects")
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.purple.opacity(0.1), in: Capsule())
            
            HStack(spacing: 12) {
                Button {
                    withAnimation { showModeSelector.toggle() }
                } label: {
                    Image(systemName: showModeSelector ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button {
                    withAnimation { isFullscreen.toggle() }
                } label: {
                    Image(systemName: isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.trailing, 16)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
    
    private var floatingModeButton: some View {
        Menu {
            ForEach(RelativisticViewMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedMode = mode
                    }
                } label: {
                    Label(mode.rawValue, systemImage: mode.icon)
                }
            }
            Divider()
            Button {
                withAnimation { showModeSelector = true }
            } label: {
                Label("Show Mode Bar", systemImage: "chevron.down")
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: selectedMode.icon)
                Text(selectedMode.rawValue)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

// MARK: - Relativistic Mode Tab

struct RelativisticModeTab: View {
    let mode: RelativisticViewMode
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: mode.icon)
                        .font(.body)
                        .foregroundStyle(isSelected ? mode.color : .secondary)
                    
                    Text(mode.rawValue)
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                }
                
                if isSelected || isHovered {
                    Text(mode.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? mode.color.opacity(0.1) : (isHovered ? Color.secondary.opacity(0.05) : Color.clear))
            .overlay(alignment: .bottom) {
                if isSelected {
                    Rectangle()
                        .fill(mode.color)
                        .frame(height: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    RelativisticViewsContainer()
        .frame(width: 1400, height: 900)
}
