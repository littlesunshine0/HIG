//
//  DesignerWorkstation.swift
//  HIG
//
//  Designer workstation: Canvas + Assets + Color Inspector
//  Liquid glass with interruptible spring animations
//

import SwiftUI
import Observation

// MARK: - Designer State

@MainActor
@Observable
final class DesignerState {
    var selectedTool: Tool = .select
    var selectedAsset: String? = nil
    var canvasZoom: CGFloat = 1.0
    var selectedColor: Color = .blue
    
    enum Tool: String, CaseIterable, Sendable {
        case select = "Select"
        case rectangle = "Rectangle"
        case circle = "Circle"
        case text = "Text"
        
        var icon: String {
            switch self {
            case .select: return "cursorarrow"
            case .rectangle: return "rectangle"
            case .circle: return "circle"
            case .text: return "textformat"
            }
        }
    }
}

// MARK: - Designer Workstation

struct DesignerWorkstation: View {
    @State private var state = DesignerState()
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 12) {
                // Left: Tools + Assets
                VStack(spacing: 12) {
                    toolsPanel
                        .frame(height: 200)
                    
                    assetsPanel
                        .frame(maxHeight: .infinity)
                }
                .frame(width: geometry.size.width * 0.2)
                
                // Center: Canvas
                canvasPanel
                    .frame(maxWidth: .infinity)
                
                // Right: Inspector
                inspectorPanel
                    .frame(width: geometry.size.width * 0.25)
            }
            .padding(12)
        }
    }
    
    // MARK: - Tools
    
    private var toolsPanel: some View {
        LiquidGlassPanel(
            title: "Tools",
            icon: "hammer.fill",
            color: .purple
        ) {
            LazyVGrid(columns: [SwiftUI.GridItem(.flexible()), SwiftUI.GridItem(.flexible())], spacing: 12) {
                ForEach(DesignerState.Tool.allCases, id: \.self) { tool in
                    DesignerToolButton(
                        tool: tool,
                        isSelected: state.selectedTool == tool
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            state.selectedTool = tool
                        }
                    }
                }
            }
            .padding(12)
        }
    }
    
    // MARK: - Assets
    
    private var assetsPanel: some View {
        LiquidGlassPanel(
            title: "Assets",
            icon: "photo.stack.fill",
            color: .purple
        ) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(1...8, id: \.self) { index in
                        AssetThumbnail(name: "Asset \(index)")
                    }
                }
                .padding(12)
            }
        }
    }
    
    // MARK: - Canvas
    
    private var canvasPanel: some View {
        LiquidGlassPanel(
            title: "Canvas",
            icon: "square.on.square.dashed",
            color: .purple
        ) {
            ZStack {
                // Grid background
                Canvas { context, size in
                    let spacing: CGFloat = 20
                    context.stroke(
                        Path { path in
                            for x in stride(from: 0, through: size.width, by: spacing) {
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: size.height))
                            }
                            for y in stride(from: 0, through: size.height, by: spacing) {
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: size.width, y: y))
                            }
                        },
                        with: .color(.secondary.opacity(0.1)),
                        lineWidth: 0.5
                    )
                }
                
                // Sample shapes
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(state.selectedColor.gradient)
                        .frame(width: 120, height: 80)
                        .shadow(radius: 8)
                    
                    Circle()
                        .fill(Color.purple.gradient)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 8)
                }
            }
        }
    }
    
    // MARK: - Inspector
    
    private var inspectorPanel: some View {
        LiquidGlassPanel(
            title: "Inspector",
            icon: "slider.horizontal.3",
            color: .purple
        ) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    InspectorSection(title: "Position") {
                        InspectorRow(label: "X", value: "120")
                        InspectorRow(label: "Y", value: "80")
                    }
                    
                    InspectorSection(title: "Size") {
                        InspectorRow(label: "Width", value: "200")
                        InspectorRow(label: "Height", value: "150")
                    }
                    
                    InspectorSection(title: "Color") {
                        ColorPicker("Fill", selection: $state.selectedColor)
                            .font(.caption)
                    }
                }
                .padding(12)
            }
        }
    }
}

// MARK: - Supporting Views

struct DesignerToolButton: View {
    let tool: DesignerState.Tool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tool.icon)
                    .font(.title3)
                Text(tool.rawValue)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.purple.opacity(0.2) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct AssetThumbnail: View {
    let name: String
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.2))
                .frame(height: 60)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            
            Text(name)
                .font(.caption2)
                .lineLimit(1)
        }
    }
}

struct InspectorSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
            content
        }
    }
}

struct InspectorRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
            
            Text(value)
                .font(.caption.monospacedDigit())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
        }
    }
}

// MARK: - Previews

#Preview("Designer Workstation") {
    DesignerWorkstation()
        .frame(width: 1200, height: 800)
}

#Preview("Tool Button - Selected") {
    DesignerToolButton(
        tool: .rectangle,
        isSelected: true
    ) {
        print("Rectangle tool selected")
    }
    .frame(width: 100, height: 80)
    .padding()
}

#Preview("Tool Button - Unselected") {
    DesignerToolButton(
        tool: .circle,
        isSelected: false
    ) {
        print("Circle tool selected")
    }
    .frame(width: 100, height: 80)
    .padding()
}

#Preview("Asset Thumbnail") {
    AssetThumbnail(name: "Sample Asset")
        .frame(width: 100)
        .padding()
}

#Preview("Inspector Section") {
    InspectorSection(title: "Position") {
        InspectorRow(label: "X", value: "120")
        InspectorRow(label: "Y", value: "80")
        InspectorRow(label: "Z", value: "0")
    }
    .padding()
}

#Preview("Inspector Row") {
    VStack(spacing: 8) {
        InspectorRow(label: "Width", value: "200")
        InspectorRow(label: "Height", value: "150")
        InspectorRow(label: "Rotation", value: "45°")
    }
    .padding()
}
