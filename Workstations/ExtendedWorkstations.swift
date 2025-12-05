//
//  ExtendedWorkstations.swift
//  HIG
//
//  Extended workstations for:
//  - Editor, Tools, Defender, Security, Explorer
//  - Generator, Network, Services, Virtual/Ghost Storage
//  - Executor, Asset Explorer, Gallery, Icon, List
//  - Column, Editor, Creator, Detail, Table, Row
//

import SwiftUI

// MARK: - Extended Workstation Types

enum ExtendedWorkstationType: String, CaseIterable, Identifiable {
    case editor = "Editor"
    case tools = "Tools"
    case defender = "Defender"
    case security = "Security"
    case explorer = "Explorer"
    case generator = "Generator"
    case network = "Network"
    case services = "Services"
    case virtualStorage = "Virtual Storage"
    case ghostStorage = "Ghost Storage"
    case executor = "Executor"
    case assetExplorer = "Assets"
    case gallery = "Gallery"
    case icons = "Icons"
    case lists = "Lists"
    case columns = "Columns"
    case creator = "Creator"
    case detail = "Detail"
    case tables = "Tables"
    case rows = "Rows"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .editor: return "pencil.and.outline"
        case .tools: return "wrench.and.screwdriver.fill"
        case .defender: return "shield.fill"
        case .security: return "lock.shield.fill"
        case .explorer: return "folder.badge.gearshape"
        case .generator: return "wand.and.stars"
        case .network: return "network"
        case .services: return "server.rack"
        case .virtualStorage: return "externaldrive.badge.icloud"
        case .ghostStorage: return "cloud.fill"
        case .executor: return "play.rectangle.fill"
        case .assetExplorer: return "photo.on.rectangle.angled"
        case .gallery: return "square.grid.3x3.fill"
        case .icons: return "star.square.on.square.fill"
        case .lists: return "list.bullet.rectangle.fill"
        case .columns: return "rectangle.split.3x1.fill"
        case .creator: return "plus.rectangle.fill"
        case .detail: return "doc.text.magnifyingglass"
        case .tables: return "tablecells.fill"
        case .rows: return "rectangle.split.1x2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .editor: return .blue
        case .tools: return .orange
        case .defender: return .red
        case .security: return .green
        case .explorer: return .purple
        case .generator: return .pink
        case .network: return .cyan
        case .services: return .indigo
        case .virtualStorage: return .teal
        case .ghostStorage: return .gray
        case .executor: return .mint
        case .assetExplorer: return .yellow
        case .gallery: return .purple
        case .icons: return .orange
        case .lists: return .blue
        case .columns: return .green
        case .creator: return .pink
        case .detail: return .indigo
        case .tables: return .cyan
        case .rows: return .brown
        }
    }
    
    var description: String {
        switch self {
        case .editor: return "Code & text editing workspace"
        case .tools: return "Development tools & utilities"
        case .defender: return "System protection & monitoring"
        case .security: return "Security settings & audit"
        case .explorer: return "File & folder navigation"
        case .generator: return "Code & content generation"
        case .network: return "Network monitoring & config"
        case .services: return "Background services management"
        case .virtualStorage: return "Virtual storage management"
        case .ghostStorage: return "Ephemeral/temp storage"
        case .executor: return "Task & script execution"
        case .assetExplorer: return "Media & asset browser"
        case .gallery: return "Visual gallery view"
        case .icons: return "Icon library & management"
        case .lists: return "List view patterns"
        case .columns: return "Column-based layouts"
        case .creator: return "Content creation tools"
        case .detail: return "Detail view patterns"
        case .tables: return "Table view patterns"
        case .rows: return "Row-based layouts"
        }
    }
}


// MARK: - Extended Workstations Hub

struct ExtendedWorkstationsHub: View {
    @State private var selectedWorkstation: ExtendedWorkstationType = .editor
    
    var body: some View {
        HSplitView {
            workstationSidebar.frame(minWidth: 220, maxWidth: 280)
            workstationContent
        }
    }
    
    private var workstationSidebar: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(ExtendedWorkstationType.allCases) { type in
                    ExtendedSidebarRow(type: type, isSelected: selectedWorkstation == type) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedWorkstation = type }
                    }
                }
            }
            .padding(12)
        }
        .background(.regularMaterial)
    }
    
    @ViewBuilder
    private var workstationContent: some View {
        switch selectedWorkstation {
        case .editor: EditorWorkstation()
        case .tools: ToolsWorkstation()
        case .defender: DefenderWorkstation()
        case .security: SecurityWorkstation()
        case .explorer: ExplorerWorkstation()
        case .generator: GeneratorWorkstation()
        case .network: NetworkWorkstation()
        case .services: ServicesWorkstation()
        case .virtualStorage: VirtualStorageWorkstation()
        case .ghostStorage: GhostStorageWorkstation()
        case .executor: ExecutorWorkstation()
        case .assetExplorer: AssetExplorerWorkstation()
        case .gallery: GalleryWorkstation()
        case .icons: IconsWorkstation()
        case .lists: ListsWorkstation()
        case .columns: ColumnsWorkstation()
        case .creator: CreatorWorkstation()
        case .detail: DetailWorkstation()
        case .tables: TablesWorkstation()
        case .rows: RowsWorkstation()
        }
    }
}

struct ExtendedSidebarRow: View {
    let type: ExtendedWorkstationType
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: type.icon).foregroundStyle(isSelected ? type.color : .secondary).frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue).font(.subheadline.weight(isSelected ? .semibold : .regular))
                    Text(type.description).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(isSelected ? type.color.opacity(0.15) : (isHovered ? Color.secondary.opacity(0.1) : Color.clear)))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}


// MARK: - Editor Workstation
struct EditorWorkstation: View {
    @State private var code = "// Your code here\nimport SwiftUI\n\nstruct MyView: View {\n    var body: some View {\n        Text(\"Hello\")\n    }\n}"
    @State private var language = "Swift"
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Code Editor", icon: "pencil.and.outline", color: .blue)
            HStack { Picker("Language", selection: $language) { ForEach(["Swift", "Python", "JavaScript", "JSON"], id: \.self) { Text($0) } }.frame(width: 150); Spacer() }.padding(.horizontal).padding(.vertical, 8).background(.regularMaterial)
            Divider()
            TextEditor(text: $code).font(.system(.body, design: .monospaced))
        }
    }
}

// MARK: - Tools Workstation
struct ToolsWorkstation: View {
    let tools = ["Formatter", "Linter", "Debugger", "Profiler", "Diff Tool", "Regex Tester", "JSON Validator", "Base64 Encoder"]
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Developer Tools", icon: "wrench.and.screwdriver.fill", color: .orange)
            ScrollView { LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) { ForEach(tools, id: \.self) { ToolCard(name: $0) } }.padding() }
        }
    }
}
struct ToolCard: View {
    let name: String; @State private var isHovered = false
    var body: some View {
        VStack(spacing: 12) { Image(systemName: "wrench.fill").font(.title).foregroundStyle(.orange); Text(name).font(.subheadline.weight(.medium)) }
        .padding().frame(maxWidth: .infinity).background(RoundedRectangle(cornerRadius: 12).fill(isHovered ? Color.orange.opacity(0.15) : Color(.controlBackgroundColor)))
        .scaleEffect(isHovered ? 1.05 : 1.0).onHover { isHovered = $0 }.animation(.easeOut(duration: 0.15), value: isHovered)
    }
}

// MARK: - Defender Workstation
struct DefenderWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "System Defender", icon: "shield.fill", color: .red)
            ScrollView {
                VStack(spacing: 20) {
                    DefenderCard(title: "Threat Protection", status: "Active", icon: "checkmark.shield.fill", color: .green)
                    DefenderCard(title: "Firewall", status: "Enabled", icon: "flame.fill", color: .orange)
                    DefenderCard(title: "Real-time Scan", status: "Running", icon: "magnifyingglass", color: .blue)
                    DefenderCard(title: "Last Scan", status: "2 hours ago", icon: "clock.fill", color: .purple)
                }.padding()
            }
        }
    }
}
struct DefenderCard: View {
    let title: String; let status: String; let icon: String; let color: Color
    var body: some View {
        HStack(spacing: 16) { Image(systemName: icon).font(.title).foregroundStyle(color); VStack(alignment: .leading) { Text(title).font(.headline); Text(status).font(.caption).foregroundStyle(.secondary) }; Spacer() }
        .padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Security Workstation
struct SecurityWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Security Center", icon: "lock.shield.fill", color: .green)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    SecurityCard(title: "Encryption", value: "AES-256", icon: "lock.fill")
                    SecurityCard(title: "Auth Method", value: "Biometric", icon: "faceid")
                    SecurityCard(title: "Certificates", value: "3 Valid", icon: "checkmark.seal.fill")
                    SecurityCard(title: "Audit Log", value: "1,234 entries", icon: "list.bullet.rectangle")
                }.padding()
            }
        }
    }
}
struct SecurityCard: View {
    let title: String; let value: String; let icon: String
    var body: some View {
        VStack(spacing: 12) { Image(systemName: icon).font(.title).foregroundStyle(.green); Text(title).font(.headline); Text(value).font(.caption).foregroundStyle(.secondary) }
        .padding().frame(maxWidth: .infinity).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}


// MARK: - Explorer Workstation
struct ExplorerWorkstation: View {
    @State private var path = "~/Documents"
    var body: some View {
        HSplitView {
            VStack(spacing: 0) { ExtendedHeader(title: "File Explorer", icon: "folder.badge.gearshape", color: .purple)
                List { Section("Favorites") { Label("Documents", systemImage: "folder"); Label("Downloads", systemImage: "arrow.down.circle"); Label("Desktop", systemImage: "menubar.dock.rectangle") }
                    Section("Devices") { Label("Macintosh HD", systemImage: "internaldrive"); Label("iCloud", systemImage: "icloud") }
                }.listStyle(.sidebar)
            }.frame(minWidth: 200)
            VStack(spacing: 0) { HStack { Image(systemName: "folder"); Text(path).font(.caption); Spacer() }.padding().background(.regularMaterial); Divider()
                ScrollView { LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) { ForEach(0..<20, id: \.self) { i in FileIcon(name: "File \(i + 1)") } }.padding() }
            }
        }
    }
}
struct FileIcon: View {
    let name: String; @State private var isHovered = false
    var body: some View {
        VStack(spacing: 8) { Image(systemName: "doc.fill").font(.largeTitle).foregroundStyle(.blue); Text(name).font(.caption).lineLimit(1) }
        .padding(8).background(RoundedRectangle(cornerRadius: 8).fill(isHovered ? Color.blue.opacity(0.1) : Color.clear))
        .scaleEffect(isHovered ? 1.05 : 1.0).onHover { isHovered = $0 }.animation(.easeOut(duration: 0.15), value: isHovered)
    }
}

// MARK: - Generator Workstation
struct GeneratorWorkstation: View {
    @State private var prompt = ""; @State private var output = ""
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Code Generator", icon: "wand.and.stars", color: .pink)
            HSplitView {
                VStack(alignment: .leading, spacing: 12) { Text("Prompt").font(.headline); TextEditor(text: $prompt).font(.body); Button("Generate") { output = "// Generated code based on: \(prompt)" }.buttonStyle(.borderedProminent) }.padding()
                VStack(alignment: .leading, spacing: 12) { Text("Output").font(.headline); TextEditor(text: $output).font(.system(.body, design: .monospaced)) }.padding()
            }
        }
    }
}

// MARK: - Network Workstation
struct NetworkWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Network Monitor", icon: "network", color: .cyan)
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 20) { NetworkStat(title: "Download", value: "45.2 MB/s", icon: "arrow.down.circle.fill", color: .green); NetworkStat(title: "Upload", value: "12.8 MB/s", icon: "arrow.up.circle.fill", color: .blue) }
                    NetworkStat(title: "Latency", value: "24ms", icon: "clock.fill", color: .orange)
                    NetworkStat(title: "Connected Devices", value: "8", icon: "wifi", color: .purple)
                }.padding()
            }
        }
    }
}
struct NetworkStat: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View {
        VStack(spacing: 12) { Image(systemName: icon).font(.largeTitle).foregroundStyle(color); Text(value).font(.title2.monospacedDigit().bold()); Text(title).font(.caption).foregroundStyle(.secondary) }
        .padding().frame(maxWidth: .infinity).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Services Workstation
struct ServicesWorkstation: View {
    let services = [("API Server", "Running", Color.green), ("Database", "Running", Color.green), ("Cache", "Idle", Color.orange), ("Queue", "Running", Color.green), ("Scheduler", "Stopped", Color.red)]
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Services Manager", icon: "server.rack", color: .indigo)
            List { ForEach(services, id: \.0) { name, status, color in HStack { Circle().fill(color).frame(width: 8, height: 8); Text(name); Spacer(); Text(status).foregroundStyle(.secondary); Button("Restart") {}.buttonStyle(.bordered).controlSize(.small) } } }.listStyle(.inset)
        }
    }
}

// MARK: - Virtual Storage Workstation
struct VirtualStorageWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Virtual Storage", icon: "externaldrive.badge.icloud", color: .teal)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    VStorageCard(title: "Primary", used: 128, total: 500, color: .blue)
                    VStorageCard(title: "Backup", used: 89, total: 250, color: .green)
                    VStorageCard(title: "Archive", used: 456, total: 1000, color: .purple)
                }.padding()
            }
        }
    }
}
struct VStorageCard: View {
    let title: String; let used: Double; let total: Double; let color: Color
    var body: some View {
        VStack(spacing: 12) { Image(systemName: "externaldrive.fill").font(.largeTitle).foregroundStyle(color); Text(title).font(.headline); ProgressView(value: used / total).tint(color); Text("\(Int(used))/\(Int(total)) GB").font(.caption).foregroundStyle(.secondary) }
        .padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Ghost Storage Workstation
struct GhostStorageWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Ghost Storage", icon: "cloud.fill", color: .gray)
            VStack(spacing: 20) {
                Image(systemName: "cloud.fill").font(.system(size: 60)).foregroundStyle(.gray)
                Text("Ephemeral Storage").font(.title2.bold())
                Text("Temporary storage that auto-deletes after session").foregroundStyle(.secondary)
                HStack(spacing: 16) { GhostStat(label: "Active", value: "12 files"); GhostStat(label: "Size", value: "234 MB"); GhostStat(label: "Expires", value: "2h 30m") }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
struct GhostStat: View {
    let label: String; let value: String
    var body: some View { VStack { Text(value).font(.headline); Text(label).font(.caption).foregroundStyle(.secondary) }.padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8)) }
}


// MARK: - Executor Workstation
struct ExecutorWorkstation: View {
    @State private var command = ""; @State private var output = "Ready to execute..."
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Task Executor", icon: "play.rectangle.fill", color: .mint)
            HSplitView {
                VStack(alignment: .leading, spacing: 12) { Text("Command").font(.headline); TextField("Enter command...", text: $command).textFieldStyle(.roundedBorder)
                    HStack { Button("Run") { output = "Executing: \(command)..." }.buttonStyle(.borderedProminent); Button("Clear") { output = "" }.buttonStyle(.bordered) }
                    Text("History").font(.headline).padding(.top); List { ForEach(["build", "test", "deploy"], id: \.self) { Text($0).font(.system(.body, design: .monospaced)) } }.listStyle(.inset)
                }.padding().frame(minWidth: 300)
                VStack(alignment: .leading, spacing: 12) { Text("Output").font(.headline); ScrollView { Text(output).font(.system(.body, design: .monospaced)).frame(maxWidth: .infinity, alignment: .leading) }.padding().background(Color.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 8)) }.padding()
            }
        }
    }
}

// MARK: - Asset Explorer Workstation
struct AssetExplorerWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Asset Explorer", icon: "photo.on.rectangle.angled", color: .yellow)
            HSplitView {
                List { Section("Categories") { Label("Images", systemImage: "photo"); Label("Videos", systemImage: "video"); Label("Audio", systemImage: "waveform"); Label("Documents", systemImage: "doc"); Label("3D Models", systemImage: "cube") } }.listStyle(.sidebar).frame(minWidth: 180)
                ScrollView { LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) { ForEach(0..<24, id: \.self) { i in AssetThumb(index: i) } }.padding() }
            }
        }
    }
}
struct AssetThumb: View {
    let index: Int; @State private var isHovered = false
    var body: some View {
        VStack(spacing: 8) { RoundedRectangle(cornerRadius: 8).fill(Color(hue: Double(index) / 24, saturation: 0.6, brightness: 0.8)).frame(height: 80); Text("Asset \(index + 1)").font(.caption) }
        .padding(8).background(RoundedRectangle(cornerRadius: 12).fill(isHovered ? Color.secondary.opacity(0.1) : Color.clear))
        .scaleEffect(isHovered ? 1.05 : 1.0).onHover { isHovered = $0 }.animation(.easeOut(duration: 0.15), value: isHovered)
    }
}

// MARK: - Gallery Workstation
struct GalleryWorkstation: View {
    @State private var columns = 4
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Gallery View", icon: "square.grid.3x3.fill", color: .purple)
            HStack { Text("Columns: \(columns)"); Slider(value: Binding(get: { Double(columns) }, set: { columns = Int($0) }), in: 2...8, step: 1).frame(width: 200); Spacer() }.padding(.horizontal).padding(.vertical, 8).background(.regularMaterial)
            Divider()
            ScrollView { LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: 12) { ForEach(0..<30, id: \.self) { i in GalleryItem(index: i) } }.padding() }
        }
    }
}
struct GalleryItem: View {
    let index: Int; @State private var isHovered = false
    var body: some View {
        RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [Color(hue: Double(index) / 30, saturation: 0.7, brightness: 0.8), Color(hue: Double(index) / 30 + 0.1, saturation: 0.5, brightness: 0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .aspectRatio(1, contentMode: .fit).overlay(Text("\(index + 1)").font(.title2.bold()).foregroundStyle(.white))
        .scaleEffect(isHovered ? 1.05 : 1.0).shadow(color: isHovered ? .black.opacity(0.2) : .clear, radius: 10).onHover { isHovered = $0 }.animation(.easeOut(duration: 0.2), value: isHovered)
    }
}

// MARK: - Icons Workstation
struct IconsWorkstation: View {
    let icons = ["star.fill", "heart.fill", "bolt.fill", "flame.fill", "leaf.fill", "drop.fill", "sun.max.fill", "moon.fill", "cloud.fill", "snowflake", "wind", "sparkles", "wand.and.stars", "paintbrush.fill", "pencil", "folder.fill", "doc.fill", "book.fill", "bookmark.fill", "tag.fill", "bell.fill", "gear", "person.fill", "house.fill"]
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Icon Library", icon: "star.square.on.square.fill", color: .orange)
            ScrollView { LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) { ForEach(icons, id: \.self) { IconCard(name: $0) } }.padding() }
        }
    }
}
struct IconCard: View {
    let name: String; @State private var isHovered = false
    var body: some View {
        VStack(spacing: 8) { Image(systemName: name).font(.title).foregroundStyle(.orange); Text(name).font(.caption2).lineLimit(1) }
        .padding(12).background(RoundedRectangle(cornerRadius: 12).fill(isHovered ? Color.orange.opacity(0.15) : Color(.controlBackgroundColor)))
        .scaleEffect(isHovered ? 1.1 : 1.0).onHover { isHovered = $0 }.animation(.easeOut(duration: 0.15), value: isHovered)
    }
}

// MARK: - Lists Workstation
struct ListsWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "List Patterns", icon: "list.bullet.rectangle.fill", color: .blue)
            HSplitView {
                VStack(alignment: .leading) { Text("Simple List").font(.headline).padding(); List(0..<10, id: \.self) { Text("Item \($0 + 1)") }.listStyle(.inset) }
                VStack(alignment: .leading) { Text("Grouped List").font(.headline).padding(); List { Section("Group A") { ForEach(0..<3, id: \.self) { Text("Item \($0 + 1)") } }; Section("Group B") { ForEach(0..<3, id: \.self) { Text("Item \($0 + 4)") } } }.listStyle(.inset) }
            }
        }
    }
}

// MARK: - Columns Workstation
struct ColumnsWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Column Layouts", icon: "rectangle.split.3x1.fill", color: .green)
            HStack(spacing: 1) {
                ForEach(["To Do", "In Progress", "Done"], id: \.self) { title in
                    VStack(spacing: 0) { Text(title).font(.headline).padding(); Divider(); ScrollView { VStack(spacing: 8) { ForEach(0..<5, id: \.self) { i in ColumnCard(title: "\(title) \(i + 1)") } }.padding() } }
                    .frame(maxWidth: .infinity).background(Color(.controlBackgroundColor))
                }
            }
        }
    }
}
struct ColumnCard: View {
    let title: String
    var body: some View { Text(title).padding().frame(maxWidth: .infinity, alignment: .leading).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8)) }
}


// MARK: - Creator Workstation
struct CreatorWorkstation: View {
    @State private var title = ""; @State private var content = ""; @State private var selectedType = "Article"
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Content Creator", icon: "plus.rectangle.fill", color: .pink)
            HSplitView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Create New").font(.headline)
                    Picker("Type", selection: $selectedType) { ForEach(["Article", "Note", "Task", "Event"], id: \.self) { Text($0) } }.pickerStyle(.segmented)
                    TextField("Title", text: $title).textFieldStyle(.roundedBorder)
                    TextEditor(text: $content).frame(minHeight: 200)
                    HStack { Spacer(); Button("Create") {}.buttonStyle(.borderedProminent) }
                }.padding()
                VStack(alignment: .leading, spacing: 12) { Text("Preview").font(.headline); Divider(); Text(title.isEmpty ? "Title" : title).font(.title2.bold()); Text(content.isEmpty ? "Content preview..." : content).foregroundStyle(.secondary); Spacer() }.padding().background(Color(.controlBackgroundColor))
            }
        }
    }
}

// MARK: - Detail Workstation
struct DetailWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Detail View Patterns", icon: "doc.text.magnifyingglass", color: .indigo)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 20) { RoundedRectangle(cornerRadius: 16).fill(.indigo.opacity(0.2)).frame(width: 120, height: 120).overlay(Image(systemName: "doc.fill").font(.largeTitle).foregroundStyle(.indigo))
                        VStack(alignment: .leading, spacing: 8) { Text("Document Title").font(.title.bold()); Text("Created: Nov 27, 2025").foregroundStyle(.secondary); HStack { Label("PDF", systemImage: "doc"); Label("2.4 MB", systemImage: "internaldrive") }.font(.caption).foregroundStyle(.tertiary) } }
                    Divider()
                    Text("Description").font(.headline); Text("This is a detailed view pattern showing how to display comprehensive information about an item with metadata, actions, and related content.").foregroundStyle(.secondary)
                    Divider()
                    Text("Actions").font(.headline); HStack { Button("Edit") {}.buttonStyle(.borderedProminent); Button("Share") {}.buttonStyle(.bordered); Button("Delete") {}.buttonStyle(.bordered).tint(.red) }
                    Divider()
                    Text("Related Items").font(.headline); LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) { ForEach(0..<4, id: \.self) { i in RelatedCard(index: i) } }
                }.padding(24)
            }
        }
    }
}
struct RelatedCard: View {
    let index: Int
    var body: some View { VStack { RoundedRectangle(cornerRadius: 8).fill(.indigo.opacity(0.1)).frame(height: 60); Text("Related \(index + 1)").font(.caption) }.padding(8).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12)) }
}

// MARK: - Tables Workstation
// Table Data Model
struct TableDataItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let value: String
    let status: String
}

struct TablesWorkstation: View {
    let data: [TableDataItem] = (0..<20).map { 
        TableDataItem(
            name: "Item \($0 + 1)",
            category: "Category \(($0 % 3) + 1)",
            value: "\($0 * 10 + 50)",
            status: $0 % 2 == 0 ? "Active" : "Inactive"
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Table View", icon: "tablecells.fill", color: .cyan)
            Table(data) {
                TableColumn("Name") { item in Text(item.name) }
                TableColumn("Category") { item in Text(item.category) }
                TableColumn("Value") { item in Text(item.value) }
                TableColumn("Status") { item in Text(item.status).foregroundStyle(item.status == "Active" ? .green : .secondary) }
            }
        }
    }
}

// MARK: - Rows Workstation
struct RowsWorkstation: View {
    var body: some View {
        VStack(spacing: 0) {
            ExtendedHeader(title: "Row Patterns", icon: "rectangle.split.1x2.fill", color: .brown)
            List {
                Section("Simple Rows") { ForEach(0..<3, id: \.self) { i in SimpleRow(title: "Simple Row \(i + 1)") } }
                Section("Detail Rows") { ForEach(0..<3, id: \.self) { i in DetailRow(title: "Detail Row \(i + 1)", subtitle: "Subtitle text here") } }
                Section("Action Rows") { ForEach(0..<3, id: \.self) { i in ActionRow(title: "Action Row \(i + 1)") } }
            }.listStyle(.inset)
        }
    }
}
struct SimpleRow: View { let title: String; var body: some View { Text(title) } }
struct DetailRow: View { let title: String; let subtitle: String; var body: some View { VStack(alignment: .leading) { Text(title); Text(subtitle).font(.caption).foregroundStyle(.secondary) } } }
struct ActionRow: View { let title: String; var body: some View { HStack { Text(title); Spacer(); Button("Action") {}.buttonStyle(.bordered).controlSize(.small) } } }

// MARK: - Extended Header
struct ExtendedHeader: View {
    let title: String; let icon: String; let color: Color
    var body: some View { HStack(spacing: 12) { Image(systemName: icon).font(.title2).foregroundStyle(color); Text(title).font(.title3.bold()); Spacer() }.padding().background(.regularMaterial) }
}

// MARK: - Preview
#Preview("Extended Workstations") { ExtendedWorkstationsHub().frame(width: 1400, height: 900) }
