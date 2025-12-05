//
//  SemanticNebulaView.swift
//  HIG
//
//  Semantic Nebula: Files as stars in 3D void, positioned by vector embedding similarity
//  Abolishes folders - related files cluster together regardless of filesystem location
//

import SwiftUI
import simd
import Combine
// MARK: - Semantic Node Model

struct SemanticNode: Identifiable, Equatable {
    let id: UUID
    let name: String
    let path: String
    let fileType: FileType
    var position: SIMD3<Float>
    var embedding: [Float]
    var connections: [UUID]
    var brightness: Float
    var pulsePhase: Float
    
    enum FileType: String, CaseIterable {
        case code = "Code"
        case document = "Document"
        case config = "Config"
        case media = "Media"
        case data = "Data"
        
        var color: Color {
            switch self {
            case .code: return .cyan
            case .document: return .purple
            case .config: return .orange
            case .media: return .pink
            case .data: return .green
            }
        }
        
        var icon: String {
            switch self {
            case .code: return "chevron.left.forwardslash.chevron.right"
            case .document: return "doc.text"
            case .config: return "gearshape"
            case .media: return "photo"
            case .data: return "cylinder"
            }
        }
    }
    
    static func == (lhs: SemanticNode, rhs: SemanticNode) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Nebula Physics Engine

@Observable
class NebulaPhysicsEngine {
    var nodes: [SemanticNode] = []
    var selectedNode: SemanticNode?
    var hoveredNode: SemanticNode?
    
    private var velocities: [UUID: SIMD3<Float>] = [:]
    private let repulsionStrength: Float = 50.0
    private let attractionStrength: Float = 0.1
    private let damping: Float = 0.95
    private let minDistance: Float = 2.0
    
    func addNode(_ node: SemanticNode) {
        nodes.append(node)
        velocities[node.id] = .zero
    }
    
    func update(deltaTime: Float) {
        guard nodes.count > 1 else { return }
        
        // Calculate forces
        for i in 0..<nodes.count {
            var force: SIMD3<Float> = .zero
            
            for j in 0..<nodes.count where i != j {
                let diff = nodes[i].position - nodes[j].position
                let distance = max(length(diff), 0.1)
                let direction = normalize(diff)
                
                // Repulsion (inverse square)
                let repulsion = direction * (repulsionStrength / (distance * distance))
                force += repulsion
                
                // Attraction based on embedding similarity
                let similarity = cosineSimilarity(nodes[i].embedding, nodes[j].embedding)
                if similarity > 0.5 {
                    let attraction = -direction * attractionStrength * similarity
                    force += attraction
                }
            }
            
            // Update velocity with damping
            velocities[nodes[i].id] = (velocities[nodes[i].id] ?? .zero) + force * deltaTime
            velocities[nodes[i].id]! *= damping
        }
        
        // Apply velocities
        for i in 0..<nodes.count {
            nodes[i].position += velocities[nodes[i].id] ?? .zero
            nodes[i].pulsePhase += deltaTime * 2.0
        }
    }
    
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        
        var dotProduct: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        
        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        
        let denominator = sqrt(normA) * sqrt(normB)
        return denominator > 0 ? dotProduct / denominator : 0
    }
    
    func findClusters() -> [[SemanticNode]] {
        var clusters: [[SemanticNode]] = []
        var visited: Set<UUID> = []
        
        for node in nodes where !visited.contains(node.id) {
            var cluster: [SemanticNode] = [node]
            visited.insert(node.id)
            
            for other in nodes where !visited.contains(other.id) {
                let similarity = cosineSimilarity(node.embedding, other.embedding)
                if similarity > 0.7 {
                    cluster.append(other)
                    visited.insert(other.id)
                }
            }
            
            clusters.append(cluster)
        }
        
        return clusters
    }
}

// MARK: - Semantic Nebula View

struct SemanticNebulaView: View {
    @State private var engine = NebulaPhysicsEngine()
    @State private var cameraRotation: SIMD2<Float> = .zero
    @State private var cameraZoom: Float = 1.0
    @State private var isDragging = false
    @State private var lastDragPosition: CGPoint = .zero
    @State private var showConnections = true
    @State private var showLabels = true
    @State private var filterType: SemanticNode.FileType?
    @State private var searchQuery = ""
    
    private let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Deep space background
            nebulaBackground
            
            // 3D star field
            GeometryReader { geometry in
                Canvas { context, size in
                    drawNebula(context: context, size: size)
                }
                .gesture(dragGesture)
                .gesture(magnificationGesture)
            }
            
            // UI Overlay
            VStack {
                topControls
                Spacer()
                bottomInfo
            }
            .padding()
            
            // Selected node detail
            if let selected = engine.selectedNode {
                nodeDetailPanel(selected)
            }
        }
        .onReceive(timer) { _ in
            engine.update(deltaTime: 1/60)
        }
        .onAppear {
            generateSampleNodes()
        }
    }
    
    // MARK: - Background
    
    private var nebulaBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.05, green: 0.02, blue: 0.1),
                    Color(red: 0.02, green: 0.05, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Nebula clouds
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -200...200)
                    )
                    .blur(radius: 50)
            }
        }
        .ignoresSafeArea()
    }

    
    // MARK: - Drawing
    
    private func drawNebula(context: GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let scale = CGFloat(cameraZoom) * min(size.width, size.height) / 10
        
        // Draw connections first (behind nodes)
        if showConnections {
            drawConnections(context: context, center: center, scale: scale)
        }
        
        // Draw nodes
        let filteredNodes = filterType == nil ? engine.nodes : engine.nodes.filter { $0.fileType == filterType }
        let searchedNodes = searchQuery.isEmpty ? filteredNodes : filteredNodes.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.path.localizedCaseInsensitiveContains(searchQuery)
        }
        
        for node in searchedNodes {
            drawNode(node, context: context, center: center, scale: scale)
        }
    }
    
    private func drawConnections(context: GraphicsContext, center: CGPoint, scale: CGFloat) {
        for node in engine.nodes {
            let pos1 = project3D(node.position, center: center, scale: scale)
            
            for connectionID in node.connections {
                guard let connected = engine.nodes.first(where: { $0.id == connectionID }) else { continue }
                let pos2 = project3D(connected.position, center: center, scale: scale)
                
                var path = Path()
                path.move(to: pos1)
                path.addLine(to: pos2)
                
                let depth = (node.position.z + connected.position.z) / 2
                let opacity = Double(max(0.1, min(0.5, 1 - depth / 20)))
                
                context.stroke(
                    path,
                    with: .color(.white.opacity(opacity)),
                    lineWidth: 0.5
                )
            }
        }
    }
    
    private func drawNode(_ node: SemanticNode, context: GraphicsContext, center: CGPoint, scale: CGFloat) {
        let screenPos = project3D(node.position, center: center, scale: scale)
        let depth = node.position.z
        let depthScale = max(0.3, min(1.5, 1 - depth / 30))
        
        let baseSize: CGFloat = 8 * CGFloat(depthScale)
        let pulseScale = 1 + 0.1 * sin(CGFloat(node.pulsePhase))
        let size = baseSize * pulseScale
        
        let isSelected = engine.selectedNode?.id == node.id
        let isHovered = engine.hoveredNode?.id == node.id
        
        // Glow effect
        let glowRadius = size * (isSelected ? 4 : (isHovered ? 3 : 2))
        let glowRect = CGRect(
            x: screenPos.x - glowRadius,
            y: screenPos.y - glowRadius,
            width: glowRadius * 2,
            height: glowRadius * 2
        )
        
        context.fill(
            Path(ellipseIn: glowRect),
            with: .radialGradient(
                Gradient(colors: [
                    node.fileType.color.opacity(Double(node.brightness) * 0.5),
                    node.fileType.color.opacity(0)
                ]),
                center: screenPos,
                startRadius: 0,
                endRadius: glowRadius
            )
        )
        
        // Core star
        let coreRect = CGRect(
            x: screenPos.x - size / 2,
            y: screenPos.y - size / 2,
            width: size,
            height: size
        )
        
        context.fill(
            Path(ellipseIn: coreRect),
            with: .color(node.fileType.color)
        )
        
        // Bright center
        let innerSize = size * 0.4
        let innerRect = CGRect(
            x: screenPos.x - innerSize / 2,
            y: screenPos.y - innerSize / 2,
            width: innerSize,
            height: innerSize
        )
        
        context.fill(
            Path(ellipseIn: innerRect),
            with: .color(.white)
        )
        
        // Label
        if showLabels && depthScale > 0.5 {
            let text = Text(node.name)
                .font(.system(size: 10 * CGFloat(depthScale)))
                .foregroundColor(.white.opacity(Double(depthScale)))
            
            context.draw(
                text,
                at: CGPoint(x: screenPos.x, y: screenPos.y + size + 8)
            )
        }
    }
    
    private func project3D(_ position: SIMD3<Float>, center: CGPoint, scale: CGFloat) -> CGPoint {
        // Apply camera rotation
        let cosX = cos(cameraRotation.x)
        let sinX = sin(cameraRotation.x)
        let cosY = cos(cameraRotation.y)
        let sinY = sin(cameraRotation.y)
        
        // Rotate around Y axis
        var rotated = SIMD3<Float>(
            position.x * cosY - position.z * sinY,
            position.y,
            position.x * sinY + position.z * cosY
        )
        
        // Rotate around X axis
        rotated = SIMD3<Float>(
            rotated.x,
            rotated.y * cosX - rotated.z * sinX,
            rotated.y * sinX + rotated.z * cosX
        )
        
        // Perspective projection
        let perspective: Float = 10
        let z = rotated.z + perspective
        let projectionScale = perspective / max(z, 0.1)
        
        return CGPoint(
            x: center.x + CGFloat(rotated.x * projectionScale) * scale,
            y: center.y + CGFloat(rotated.y * projectionScale) * scale
        )
    }
    
    // MARK: - Gestures
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if isDragging {
                    let delta = CGPoint(
                        x: value.location.x - lastDragPosition.x,
                        y: value.location.y - lastDragPosition.y
                    )
                    cameraRotation.x += Float(delta.y) * 0.01
                    cameraRotation.y += Float(delta.x) * 0.01
                }
                lastDragPosition = value.location
                isDragging = true
            }
            .onEnded { _ in
                isDragging = false
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                cameraZoom = Float(value) * cameraZoom
                cameraZoom = max(0.2, min(5.0, cameraZoom))
            }
    }
    
    // MARK: - UI Components
    
    private var topControls: some View {
        HStack(spacing: 16) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search files...", text: $searchQuery)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .frame(width: 200)
            
            Spacer()
            
            // Filter by type
            Menu {
                Button("All Types") { filterType = nil }
                Divider()
                ForEach(SemanticNode.FileType.allCases, id: \.self) { type in
                    Button {
                        filterType = type
                    } label: {
                        Label(type.rawValue, systemImage: type.icon)
                    }
                }
            } label: {
                Label(filterType?.rawValue ?? "All Types", systemImage: "line.3.horizontal.decrease.circle")
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            
            // Toggle controls
            Toggle(isOn: $showConnections) {
                Image(systemName: "link")
            }
            .toggleStyle(.button)
            .help("Show connections")
            
            Toggle(isOn: $showLabels) {
                Image(systemName: "textformat")
            }
            .toggleStyle(.button)
            .help("Show labels")
        }
    }
    
    private var bottomInfo: some View {
        HStack {
            // Cluster info
            let clusters = engine.findClusters()
            VStack(alignment: .leading, spacing: 4) {
                Text("Semantic Clusters")
                    .font(.caption.weight(.semibold))
                Text("\(clusters.count) clusters • \(engine.nodes.count) files")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            
            Spacer()
            
            // Legend
            HStack(spacing: 12) {
                ForEach(SemanticNode.FileType.allCases, id: \.self) { type in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(type.color)
                            .frame(width: 8, height: 8)
                        Text(type.rawValue)
                            .font(.caption2)
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private func nodeDetailPanel(_ node: SemanticNode) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: node.fileType.icon)
                    .foregroundStyle(node.fileType.color)
                Text(node.name)
                    .font(.headline)
                Spacer()
                Button {
                    engine.selectedNode = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Text(node.path)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            
            Divider()
            
            Text("Related Files")
                .font(.caption.weight(.semibold))
            
            let related = engine.nodes.filter { node.connections.contains($0.id) }
            ForEach(related.prefix(5)) { relatedNode in
                HStack {
                    Circle()
                        .fill(relatedNode.fileType.color)
                        .frame(width: 6, height: 6)
                    Text(relatedNode.name)
                        .font(.caption)
                }
            }
        }
        .padding(16)
        .frame(width: 280)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .position(x: 160, y: 200)
    }
    
    // MARK: - Sample Data
    
    private func generateSampleNodes() {
        let sampleFiles: [(String, String, SemanticNode.FileType, [Float])] = [
            ("ContentView.swift", "/HIG/ContentView.swift", .code, [0.9, 0.8, 0.2, 0.1]),
            ("HIGApp.swift", "/HIG/HIGApp.swift", .code, [0.85, 0.75, 0.25, 0.15]),
            ("README.md", "/README.md", .document, [0.2, 0.3, 0.9, 0.8]),
            ("ARCHITECTURE.md", "/docs/ARCHITECTURE.md", .document, [0.25, 0.35, 0.85, 0.75]),
            ("config.json", "/config.json", .config, [0.1, 0.9, 0.1, 0.5]),
            ("settings.plist", "/settings.plist", .config, [0.15, 0.85, 0.15, 0.45]),
            ("AppIcon.png", "/Assets/AppIcon.png", .media, [0.5, 0.1, 0.5, 0.9]),
            ("data.json", "/Knowledge/data.json", .data, [0.3, 0.6, 0.3, 0.6]),
            ("AIKnowledgeBase.swift", "/Models/AIKnowledgeBase.swift", .code, [0.88, 0.78, 0.22, 0.12]),
            ("contract.pdf", "/Downloads/contract.pdf", .document, [0.22, 0.32, 0.88, 0.78]),
            ("contract_notes.txt", "/Documents/contract_notes.txt", .document, [0.24, 0.34, 0.86, 0.76]),
        ]
        
        for (i, file) in sampleFiles.enumerated() {
            let angle = Float(i) / Float(sampleFiles.count) * 2 * .pi
            let radius: Float = 3 + Float.random(in: -1...1)
            
            let node = SemanticNode(
                id: UUID(),
                name: file.0,
                path: file.1,
                fileType: file.2,
                position: SIMD3<Float>(
                    cos(angle) * radius,
                    Float.random(in: -2...2),
                    sin(angle) * radius
                ),
                embedding: file.3,
                connections: [],
                brightness: Float.random(in: 0.6...1.0),
                pulsePhase: Float.random(in: 0...(.pi * 2))
            )
            
            engine.addNode(node)
        }
        
        // Create connections based on similarity
        for i in 0..<engine.nodes.count {
            for j in (i+1)..<engine.nodes.count {
                let sim = cosineSimilarity(engine.nodes[i].embedding, engine.nodes[j].embedding)
                if sim > 0.6 {
                    engine.nodes[i].connections.append(engine.nodes[j].id)
                    engine.nodes[j].connections.append(engine.nodes[i].id)
                }
            }
        }
    }
    
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        var dot: Float = 0, normA: Float = 0, normB: Float = 0
        for i in 0..<a.count {
            dot += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        let denom = sqrt(normA) * sqrt(normB)
        return denom > 0 ? dot / denom : 0
    }
}

#Preview {
    SemanticNebulaView()
        .frame(width: 1200, height: 800)
}
