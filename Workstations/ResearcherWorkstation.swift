//
//  ResearcherWorkstation.swift
//  HIG
//
//  Researcher workstation: Sources + Notes + Findings
//  Ethical research with transparent methodology
//

import SwiftUI
import Observation

// MARK: - Researcher State

@MainActor
@Observable
final class ResearcherState {
    var sources: [ResearchSource] = [
        ResearchSource(title: "Apple HIG Documentation", credibility: .official),
        ResearchSource(title: "WWDC 2023 Session", credibility: .official),
        ResearchSource(title: "Community Tutorial", credibility: .community)
    ]
    var currentNote: String = ""
    var findings: [Finding] = []
    
    struct ResearchSource: Identifiable, Sendable {
        let id = UUID()
        let title: String
        let credibility: Credibility
        
        enum Credibility: String, Sendable {
            case official = "Official"
            case peerReviewed = "Peer Reviewed"
            case community = "Community"
        }
    }
    
    struct Finding: Identifiable, Sendable {
        let id = UUID()
        let title: String
        let confidence: String
        let date: Date
    }
}

// MARK: - Researcher Workstation

struct ResearcherWorkstation: View {
    @State private var state = ResearcherState()
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 12) {
                // Left: Sources
                sourcesPanel
                    .frame(width: geometry.size.width * 0.3)
                
                // Center: Notes
                notesPanel
                    .frame(maxWidth: .infinity)
                
                // Right: Findings
                findingsPanel
                    .frame(width: geometry.size.width * 0.3)
            }
            .padding(12)
        }
    }
    
    // MARK: - Sources
    
    private var sourcesPanel: some View {
        LiquidGlassPanel(
            title: "Research Sources",
            icon: "book.pages.fill",
            color: .green
        ) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(state.sources) { source in
                            ResearchSourceRow(source: source)
                        }
                    }
                    .padding(12)
                }
                
                Divider()
                
                Button {
                    // Add source
                } label: {
                    Label("Add Source", systemImage: "plus")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(8)
            }
        }
    }
    
    // MARK: - Notes
    
    private var notesPanel: some View {
        LiquidGlassPanel(
            title: "Research Notes",
            icon: "note.text",
            color: .green
        ) {
            VStack(spacing: 0) {
                TextEditor(text: $state.currentNote)
                    .font(.system(.body, design: .default))
                    .scrollContentBackground(.hidden)
                    .padding(12)
                
                Divider()
                
                HStack {
                    Text("Methodology: Systematic review")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        // Save finding
                        let finding = ResearcherState.Finding(
                            title: "New Finding",
                            confidence: "Medium",
                            date: Date()
                        )
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            state.findings.append(finding)
                        }
                    } label: {
                        Label("Record Finding", systemImage: "checkmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(8)
            }
        }
    }
    
    // MARK: - Findings
    
    private var findingsPanel: some View {
        LiquidGlassPanel(
            title: "Findings",
            icon: "lightbulb.fill",
            color: .green
        ) {
            ScrollView {
                VStack(spacing: 12) {
                    if state.findings.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundStyle(.tertiary)
                            Text("No findings yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(40)
                    } else {
                        ForEach(state.findings) { finding in
                            FindingCard(finding: finding)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                }
                .padding(12)
            }
        }
    }
}

// MARK: - Supporting Views

struct ResearchSourceRow: View {
    let source: ResearcherState.ResearchSource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(source.title)
                .font(.caption.weight(.medium))
            
            HStack {
                Image(systemName: credibilityIcon)
                    .font(.caption2)
                Text(source.credibility.rawValue)
                    .font(.caption2)
            }
            .foregroundStyle(credibilityColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
    
    private var credibilityIcon: String {
        switch source.credibility {
        case .official: return "checkmark.seal.fill"
        case .peerReviewed: return "checkmark.circle.fill"
        case .community: return "person.2.fill"
        }
    }
    
    private var credibilityColor: Color {
        switch source.credibility {
        case .official: return .green
        case .peerReviewed: return .blue
        case .community: return .orange
        }
    }
}

struct FindingCard: View {
    let finding: ResearcherState.Finding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text(finding.title)
                    .font(.caption.weight(.semibold))
            }
            
            HStack {
                Text("Confidence:")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(finding.confidence)
                    .font(.caption2.weight(.medium))
            }
            
            Text(finding.date, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Previews

#Preview("Researcher Workstation") {
    ResearcherWorkstation()
        .frame(width: 1200, height: 800)
}

#Preview("Source Row - Official") {
    ResearchSourceRow(
        source: ResearcherState.ResearchSource(
            title: "Apple Human Interface Guidelines",
            credibility: .official
        )
    )
    .padding()
}

#Preview("Source Row - Peer Reviewed") {
    ResearchSourceRow(
        source: ResearcherState.ResearchSource(
            title: "SwiftUI Performance Study (2023)",
            credibility: .peerReviewed
        )
    )
    .padding()
}

#Preview("Source Row - Community") {
    ResearchSourceRow(
        source: ResearcherState.ResearchSource(
            title: "Community Tutorial: Advanced Animations",
            credibility: .community
        )
    )
    .padding()
}

#Preview("Finding Card") {
    FindingCard(
        finding: ResearcherState.Finding(
            title: "Liquid glass materials improve user engagement",
            confidence: "High",
            date: Date()
        )
    )
    .padding()
}

#Preview("Multiple Findings") {
    VStack(spacing: 12) {
        FindingCard(
            finding: ResearcherState.Finding(
                title: "Physics-based animations feel more natural",
                confidence: "High",
                date: Date().addingTimeInterval(-86400)
            )
        )
        FindingCard(
            finding: ResearcherState.Finding(
                title: "Spring damping of 0.75 provides optimal feel",
                confidence: "Medium",
                date: Date().addingTimeInterval(-172800)
            )
        )
        FindingCard(
            finding: ResearcherState.Finding(
                title: "Users prefer adaptive layouts over fixed",
                confidence: "High",
                date: Date().addingTimeInterval(-259200)
            )
        )
    }
    .padding()
}
