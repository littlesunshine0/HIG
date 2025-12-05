//
//  LatentTopographyView.swift
//  HIG
//
//  Unified container for Latent Topography visualization modes
//  Visualizing the "brain" of the AI as it maps your files
//

import SwiftUI

// MARK: - Visualization Mode

enum LatentVisualizationMode: String, CaseIterable, Identifiable {
    case semanticNebula = "Semantic Nebula"
    case dreamOverlay = "Dream Overlay"
    case dnaStrip = "DNA Strip"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .semanticNebula: return "sparkles"
        case .dreamOverlay: return "moon.stars"
        case .dnaStrip: return "dna"
        }
    }
    
    var description: String {
        switch self {
        case .semanticNebula:
            return "Files as stars in 3D space, positioned by semantic similarity"
        case .dreamOverlay:
            return "Split view showing source code and AI's predicted output"
        case .dnaStrip:
            return "Color-coded strips showing token density and code composition"
        }
    }
    
    var color: Color {
        switch self {
        case .semanticNebula: return .purple
        case .dreamOverlay: return .blue
        case .dnaStrip: return .green
        }
    }
}

// MARK: - Latent Topography View

struct LatentTopographyView: View {
    @State private var selectedMode: LatentVisualizationMode = .semanticNebula
    @State private var showModeSelector = true
    @State private var isFullscreen = false
    
    var body: some View {
        ZStack {
            // Main visualization
            visualizationContent
            
            // Mode selector overlay
            if showModeSelector {
                VStack {
                    modeSelectorBar
                    Spacer()
                }
            }
            
            // Floating mode button when selector is hidden
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
    
    // MARK: - Visualization Content
    
    @ViewBuilder
    private var visualizationContent: some View {
        switch selectedMode {
        case .semanticNebula:
            SemanticNebulaView()
        case .dreamOverlay:
            DreamOverlayView()
        case .dnaStrip:
            DNAStripView()
        }
    }
    
    // MARK: - Mode Selector Bar
    
    private var modeSelectorBar: some View {
        HStack(spacing: 0) {
            ForEach(LatentVisualizationMode.allCases) { mode in
                ModeTab(
                    mode: mode,
                    isSelected: selectedMode == mode
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedMode = mode
                    }
                }
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 12) {
                Button {
                    withAnimation {
                        showModeSelector.toggle()
                    }
                } label: {
                    Image(systemName: showModeSelector ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button {
                    withAnimation {
                        isFullscreen.toggle()
                    }
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
    
    // MARK: - Floating Mode Button
    
    private var floatingModeButton: some View {
        Menu {
            ForEach(LatentVisualizationMode.allCases) { mode in
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
                withAnimation {
                    showModeSelector = true
                }
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

// MARK: - Mode Tab

struct ModeTab: View {
    let mode: LatentVisualizationMode
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
            .background(
                isSelected ? mode.color.opacity(0.1) : (isHovered ? Color.secondary.opacity(0.05) : Color.clear)
            )
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

// MARK: - Mode Card (for selection screen)

struct ModeCard: View {
    let mode: LatentVisualizationMode
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(mode.color.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(mode.color)
                }
                
                // Title
                Text(mode.rawValue)
                    .font(.headline)
                
                // Description
                Text(mode.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .frame(width: 200, height: 200)
            .padding(20)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isHovered ? mode.color : Color.secondary.opacity(0.2), lineWidth: isHovered ? 2 : 1)
            }
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .shadow(color: isHovered ? mode.color.opacity(0.3) : .clear, radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Mode Selection Screen

struct LatentTopographySelectionView: View {
    @Binding var selectedMode: LatentVisualizationMode?
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.largeTitle)
                        .foregroundStyle(.purple)
                    
                    Text("Latent Topography")
                        .font(.largeTitle.bold())
                }
                
                Text("Visualize the AI's understanding of your codebase")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            // Mode cards
            HStack(spacing: 24) {
                ForEach(LatentVisualizationMode.allCases) { mode in
                    ModeCard(mode: mode) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedMode = mode
                        }
                    }
                }
            }
            
            // Info
            Text("Choose a visualization mode to explore your files in new ways")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Preview

#Preview("Latent Topography") {
    LatentTopographyView()
        .frame(width: 1400, height: 900)
}

#Preview("Mode Selection") {
    LatentTopographySelectionView(selectedMode: .constant(nil))
        .frame(width: 1000, height: 600)
}
