//  WorkstationCore.swift
//  HIG
//
//  Core workstation architecture with liquid glass and physics-based motion
//  Swift 6 strict concurrency compliant
//

import SwiftUI
import Observation

// MARK: - Workstation Protocol

protocol Workstation: Sendable {
    associatedtype Content: View
    var id: UUID { get }
    var title: String { get }
    var icon: String { get }
    var color: Color { get }
    
    @MainActor
    @ViewBuilder
    func makeContent() -> Content
}

// MARK: - Workstation State

@MainActor
@Observable
final class WorkstationState {
    var selectedWorkstation: WorkstationType = .developer
    var isExpanded: Bool = false
    var columnWidths: [CGFloat] = [0.25, 0.45, 0.30]
    
    // Physics-based animation state
    var velocity: CGFloat = 0
    var isDragging: Bool = false
    
    enum WorkstationType: String, CaseIterable, Sendable {
        case developer = "Developer"
        case designer = "Designer"
        case researcher = "Researcher"
        
        var icon: String {
            switch self {
            case .developer: return "hammer.fill"
            case .designer: return "paintbrush.fill"
            case .researcher: return "book.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .developer: return .blue
            case .designer: return .purple
            case .researcher: return .green
            }
        }
    }
}

// MARK: - Workstation Container

struct WorkstationContainer: View {
    @State private var state = WorkstationState()
    @Namespace private var morphSpace
    @Environment(\.colorScheme) private var colorScheme
    
    // Spring configuration for liquid glass feel
    private let liquidSpring: Animation = .spring(
        response: 0.5,
        dampingFraction: 0.75,
        blendDuration: 0.2
    )
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Workstation selector sidebar
                workstationSidebar
                    .frame(width: 80)
                
                Divider()
                
                // Active workstation content
                workstationContent
                    .frame(maxWidth: .infinity)
            }
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Sidebar
    
    private var workstationSidebar: some View {
        VStack(spacing: 16) {
            ForEach(WorkstationState.WorkstationType.allCases, id: \.self) { type in
                WorkstationButton(
                    type: type,
                    isSelected: state.selectedWorkstation == type,
                    morphSpace: morphSpace
                ) {
                    withAnimation(liquidSpring) {
                        state.selectedWorkstation = type
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 20)
        .background(Color.secondary.opacity(0.05))
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var workstationContent: some View {
        switch state.selectedWorkstation {
        case .developer:
            DeveloperWorkstation()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        case .designer:
            DesignerWorkstation()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        case .researcher:
            ResearcherWorkstation()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
    }
}

// MARK: - Workstation Button

struct WorkstationButton: View {
    let type: WorkstationState.WorkstationType
    let isSelected: Bool
    let morphSpace: Namespace.ID
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(type.color.opacity(0.2))
                            .matchedGeometryEffect(id: "selection", in: morphSpace)
                    }
                    
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? type.color : .secondary)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(width: 56, height: 56)
                
                Text(type.rawValue)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? type.color : .secondary)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Liquid Glass Panel

struct LiquidGlassPanel<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    @State private var isHovered = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .padding(16)
            .background(.regularMaterial)
            
            Divider()
            
            // Content
            content
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
                .shadow(
                    color: .black.opacity(isHovered ? 0.15 : 0.1),
                    radius: isHovered ? 16 : 12,
                    y: isHovered ? 8 : 6
                )
        }
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Previews

#Preview("Workstation Container") {
    WorkstationContainer()
        .frame(width: 1200, height: 800)
}

#Preview("Workstation Button - Selected") {
    @Previewable @Namespace var morphSpace
    
    WorkstationButton(
        type: .developer,
        isSelected: true,
        morphSpace: morphSpace
    ) {
        print("Developer selected")
    }
    .padding()
}

#Preview("Workstation Button - Unselected") {
    @Previewable @Namespace var morphSpace
    
    WorkstationButton(
        type: .designer,
        isSelected: false,
        morphSpace: morphSpace
    ) {
        print("Designer selected")
    }
    .padding()
}

#Preview("Liquid Glass Panel") {
    LiquidGlassPanel(
        title: "Sample Panel",
        icon: "star.fill",
        color: .blue
    ) {
        VStack(spacing: 16) {
            Text("This is a liquid glass panel")
                .font(.headline)
            
            Text("It has beautiful materials and hover effects")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Sample Button") {
                print("Button tapped")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
    }
    .frame(width: 300, height: 200)
    .padding()
}
