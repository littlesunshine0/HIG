//
//  ParallaxStreamView.swift
//  HIG
//
//  Parallax Stream: Timeline with depth perception
//  Foreground (urgent) moves fast, background (long-term) moves slow
//  Creates sensation of time dilation
//

import SwiftUI
import Combine
import Combine

// MARK: - Stream Event

struct StreamEvent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let timestamp: Date
    let urgency: Urgency
    let category: String
    var xOffset: CGFloat = 0
    
    enum Urgency: Int, CaseIterable {
        case critical = 0   // Foreground - fastest
        case high = 1
        case medium = 2
        case low = 3
        case background = 4 // Background - slowest
        
        var speed: CGFloat {
            switch self {
            case .critical: return 3.0
            case .high: return 2.0
            case .medium: return 1.0
            case .low: return 0.5
            case .background: return 0.2
            }
        }
        
        var depth: CGFloat {
            CGFloat(rawValue) * 50
        }
        
        var scale: CGFloat {
            1.0 - CGFloat(rawValue) * 0.15
        }
        
        var opacity: Double {
            1.0 - Double(rawValue) * 0.15
        }
        
        var color: Color {
            switch self {
            case .critical: return .red
            case .high: return .orange
            case .medium: return .yellow
            case .low: return .blue
            case .background: return .gray
            }
        }
        
        var label: String {
            switch self {
            case .critical: return "Critical"
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            case .background: return "Background"
            }
        }
    }
}

// MARK: - Parallax Engine

@Observable
class ParallaxEngine {
    var events: [StreamEvent] = []
    var selectedEvent: StreamEvent?
    var isPlaying = true
    var timeScale: CGFloat = 1.0
    var showDepthGuides = true
    var filterUrgency: StreamEvent.Urgency?
    
    var filteredEvents: [StreamEvent] {
        guard let filter = filterUrgency else { return events }
        return events.filter { $0.urgency == filter }
    }
    
    func update(deltaTime: CGFloat, viewWidth: CGFloat) {
        guard isPlaying else { return }
        
        for i in 0..<events.count {
            let speed = events[i].urgency.speed * timeScale * 50
            events[i].xOffset -= speed * deltaTime
            
            // Wrap around
            if events[i].xOffset < -200 {
                events[i].xOffset = viewWidth + 200
            }
        }
    }
    
    func loadSampleData(viewWidth: CGFloat) {
        let calendar = Calendar.current
        let now = Date()
        
        events = [
            // Critical (foreground)
            StreamEvent(title: "Deploy Hotfix", description: "Critical bug in production", timestamp: now, urgency: .critical, category: "Dev", xOffset: CGFloat.random(in: 0...viewWidth)),
            StreamEvent(title: "Client Meeting", description: "Urgent stakeholder review", timestamp: calendar.date(byAdding: .hour, value: 1, to: now)!, urgency: .critical, category: "Meeting", xOffset: CGFloat.random(in: 0...viewWidth)),
            
            // High
            StreamEvent(title: "Code Review", description: "PR #234 needs approval", timestamp: calendar.date(byAdding: .hour, value: 3, to: now)!, urgency: .high, category: "Dev", xOffset: CGFloat.random(in: 0...viewWidth)),
            StreamEvent(title: "Bug Triage", description: "Weekly bug review", timestamp: calendar.date(byAdding: .day, value: 1, to: now)!, urgency: .high, category: "Dev", xOffset: CGFloat.random(in: 0...viewWidth)),
            
            // Medium
            StreamEvent(title: "Feature Planning", description: "Q2 roadmap discussion", timestamp: calendar.date(byAdding: .day, value: 3, to: now)!, urgency: .medium, category: "Planning", xOffset: CGFloat.random(in: 0...viewWidth)),
            StreamEvent(title: "Documentation", description: "Update API docs", timestamp: calendar.date(byAdding: .day, value: 5, to: now)!, urgency: .medium, category: "Docs", xOffset: CGFloat.random(in: 0...viewWidth)),
            StreamEvent(title: "Team Sync", description: "Weekly standup", timestamp: calendar.date(byAdding: .day, value: 2, to: now)!, urgency: .medium, category: "Meeting", xOffset: CGFloat.random(in: 0...viewWidth)),
            
            // Low
            StreamEvent(title: "Refactoring", description: "Clean up legacy code", timestamp: calendar.date(byAdding: .day, value: 7, to: now)!, urgency: .low, category: "Dev", xOffset: CGFloat.random(in: 0...viewWidth)),
            StreamEvent(title: "Learning", description: "SwiftUI workshop", timestamp: calendar.date(byAdding: .day, value: 14, to: now)!, urgency: .low, category: "Growth", xOffset: CGFloat.random(in: 0...viewWidth)),
            
            // Background (long-term)
            StreamEvent(title: "Architecture Review", description: "System redesign planning", timestamp: calendar.date(byAdding: .month, value: 1, to: now)!, urgency: .background, category: "Planning", xOffset: CGFloat.random(in: 0...viewWidth)),
            StreamEvent(title: "Tech Debt", description: "Long-term cleanup", timestamp: calendar.date(byAdding: .month, value: 2, to: now)!, urgency: .background, category: "Dev", xOffset: CGFloat.random(in: 0...viewWidth)),
            StreamEvent(title: "Career Goals", description: "Annual review prep", timestamp: calendar.date(byAdding: .month, value: 3, to: now)!, urgency: .background, category: "Growth", xOffset: CGFloat.random(in: 0...viewWidth)),
        ]
    }
}

// MARK: - Parallax Stream View

struct ParallaxStreamView: View {
    @State private var engine = ParallaxEngine()
    @State private var viewSize: CGSize = .zero
    
    private let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            
            GeometryReader { geo in
                ZStack {
                    // Gradient background with depth
                    parallaxBackground
                    
                    // Depth guides
                    if engine.showDepthGuides {
                        depthGuides(in: geo.size)
                    }
                    
                    // Events by depth layer
                    ForEach(StreamEvent.Urgency.allCases.reversed(), id: \.self) { urgency in
                        let layerEvents = engine.filteredEvents.filter { $0.urgency == urgency }
                        
                        ForEach(layerEvents) { event in
                            ParallaxEventCard(
                                event: event,
                                isSelected: engine.selectedEvent?.id == event.id,
                                onSelect: { engine.selectedEvent = event }
                            )
                            .scaleEffect(event.urgency.scale)
                            .opacity(event.urgency.opacity)
                            .offset(x: event.xOffset, y: event.urgency.depth)
                        }
                    }
                    
                    // Time dilation indicator
                    timeDilationIndicator
                        .position(x: geo.size.width - 80, y: geo.size.height - 60)
                }
                .onAppear {
                    viewSize = geo.size
                    engine.loadSampleData(viewWidth: geo.size.width)
                }
            }
            
            // Selected event detail
            if let selected = engine.selectedEvent {
                Divider()
                eventDetailBar(selected)
            }
        }
        .onReceive(timer) { _ in
            engine.update(deltaTime: 1/60, viewWidth: viewSize.width)
        }
    }
    
    // MARK: - Background
    
    private var parallaxBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Depth fog layers
            ForEach(0..<5, id: \.self) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.02))
                    .offset(y: CGFloat(i) * 50)
            }
        }
        .ignoresSafeArea()
    }
    
    private func depthGuides(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            ForEach(StreamEvent.Urgency.allCases, id: \.self) { urgency in
                HStack {
                    Text(urgency.label)
                        .font(.caption2)
                        .foregroundStyle(urgency.color.opacity(0.5))
                    
                    Rectangle()
                        .fill(urgency.color.opacity(0.1))
                        .frame(height: 1)
                }
                .frame(height: 50)
            }
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.top, 20)
    }
    
    private var timeDilationIndicator: some View {
        VStack(spacing: 4) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.5))
            
            Text("Time Dilation")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.3))
            
            Text("\(engine.timeScale, specifier: "%.1f")x")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Toolbar
    
    private var toolbar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundStyle(.purple)
                Text("Parallax Stream")
                    .font(.headline)
            }
            
            Divider().frame(height: 20)
            
            // Play/Pause
            Button {
                engine.isPlaying.toggle()
            } label: {
                Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.bordered)
            
            // Time scale
            HStack(spacing: 8) {
                Text("Speed:")
                    .font(.caption)
                Slider(value: $engine.timeScale, in: 0.1...3.0)
                    .frame(width: 100)
                Text("\(engine.timeScale, specifier: "%.1f")x")
                    .font(.caption.monospacedDigit())
                    .frame(width: 35)
            }
            
            // Filter
            Menu {
                Button("All Urgencies") { engine.filterUrgency = nil }
                Divider()
                ForEach(StreamEvent.Urgency.allCases, id: \.self) { urgency in
                    Button {
                        engine.filterUrgency = urgency
                    } label: {
                        Label(urgency.label, systemImage: "circle.fill")
                    }
                }
            } label: {
                Label(engine.filterUrgency?.label ?? "All", systemImage: "line.3.horizontal.decrease.circle")
            }
            
            Toggle(isOn: $engine.showDepthGuides) {
                Label("Guides", systemImage: "ruler")
            }
            .toggleStyle(.button)
            
            Spacer()
            
            Text("\(engine.events.count) events")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }
    
    private func eventDetailBar(_ event: StreamEvent) -> some View {
        HStack(spacing: 16) {
            Circle()
                .fill(event.urgency.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.headline)
                Text(event.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(event.urgency.label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(event.urgency.color)
                Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Button { engine.selectedEvent = nil } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
}

// MARK: - Parallax Event Card

struct ParallaxEventCard: View {
    let event: StreamEvent
    let isSelected: Bool
    let onSelect: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Circle()
                        .fill(event.urgency.color)
                        .frame(width: 8, height: 8)
                    Text(event.title)
                        .font(.caption.weight(.medium))
                        .lineLimit(1)
                }
                
                Text(event.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                Text(event.category)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(event.urgency.color.opacity(0.2), in: Capsule())
            }
            .padding(10)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? event.urgency.color : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: event.urgency.color.opacity(isHovered ? 0.3 : 0), radius: 10)
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
    ParallaxStreamView()
        .frame(width: 1200, height: 700)
}
