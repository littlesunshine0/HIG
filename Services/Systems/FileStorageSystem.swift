//
//  FileStorageSystem.swift
//  HIG
//
//  File Storage System - Uploads, compression, CDN, retrieval
//

import SwiftUI

struct FileStorageSystemView: View {
    @State private var selectedTab = "Files"
    @State private var files: [SystemStoredFile] = SystemStoredFile.samples
    @State private var uploadProgress: Double = 0
    @State private var isUploading = false
    
    let tabs = ["Files", "Upload", "CDN", "Settings"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "externaldrive.fill").font(.title2).foregroundStyle(.cyan)
                Text("File Storage System").font(.title2.bold())
                Spacer()
                StorageUsageBar(used: 45.2, total: 100)
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.cyan.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "Files": FileBrowserView(files: $files)
                case "Upload": UploadView(progress: $uploadProgress, isUploading: $isUploading)
                case "CDN": SystemCDNView()
                case "Settings": StorageSettingsView()
                default: EmptyView()
                }
            }
        }
    }
}

struct StorageUsageBar: View {
    let used: Double
    let total: Double
    
    var body: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.secondary.opacity(0.2))
                    RoundedRectangle(cornerRadius: 4).fill(Color.cyan).frame(width: geo.size.width * (used / total))
                }
            }
            .frame(width: 100, height: 8)
            Text("\(String(format: "%.1f", used)) / \(Int(total)) GB").font(.caption)
        }
    }
}

struct FileBrowserView: View {
    @Binding var files: [SystemStoredFile]
    @State private var viewMode = "grid"
    @State private var sortBy = "name"
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search files...", text: .constant("")).textFieldStyle(.roundedBorder).frame(width: 250)
                Spacer()
                Picker("Sort", selection: $sortBy) {
                    Text("Name").tag("name")
                    Text("Date").tag("date")
                    Text("Size").tag("size")
                }
                .frame(width: 100)
                
                Picker("View", selection: $viewMode) {
                    Image(systemName: "square.grid.2x2").tag("grid")
                    Image(systemName: "list.bullet").tag("list")
                }
                .pickerStyle(.segmented)
                .frame(width: 80)
            }
            .padding()
            
            Divider()
            
            if viewMode == "grid" {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                        ForEach(files) { file in
                            FileGridItem(file: file)
                        }
                    }
                    .padding()
                }
            } else {
                List {
                    ForEach(files) { file in
                        FileListRow(file: file)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct FileGridItem: View {
    let file: SystemStoredFile
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(file.color.opacity(0.1)).frame(height: 80)
                Image(systemName: file.icon).font(.largeTitle).foregroundStyle(file.color)
            }
            Text(file.name).font(.caption).lineLimit(1)
            Text(file.sizeString).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
    }
}

struct FileListRow: View {
    let file: SystemStoredFile
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.icon).font(.title2).foregroundStyle(file.color).frame(width: 32)
            VStack(alignment: .leading) {
                Text(file.name).font(.subheadline)
                Text(file.path).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Text(file.sizeString).font(.caption).foregroundStyle(.secondary)
            Text(file.dateString).font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct UploadView: View {
    @Binding var progress: Double
    @Binding var isUploading: Bool
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 20).strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [10]))
                    .foregroundStyle(isDragging ? .cyan : .secondary)
                    .frame(height: 200)
                
                VStack(spacing: 16) {
                    Image(systemName: "arrow.up.doc.fill").font(.system(size: 50)).foregroundStyle(isDragging ? .cyan : .secondary)
                    Text("Drop files here or click to browse").font(.headline)
                    Text("Max file size: 100MB").font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding()
            
            if isUploading {
                VStack(spacing: 8) {
                    HStack {
                        Text("Uploading...").font(.subheadline)
                        Spacer()
                        Text("\(Int(progress * 100))%").font(.caption)
                    }
                    ProgressView(value: progress)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                .frame(width: 400)
            }
            
            HStack(spacing: 16) {
                Button("Select Files") { simulateUpload() }.buttonStyle(.borderedProminent).tint(.cyan)
                Button("Upload Folder") {}.buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    func simulateUpload() {
        isUploading = true
        progress = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            progress += 0.02
            if progress >= 1 { timer.invalidate(); isUploading = false }
        }
    }
}

struct SystemCDNView: View {
    let regions = [("US East", "Active", 12), ("US West", "Active", 8), ("Europe", "Active", 15), ("Asia", "Syncing", 5)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("CDN Distribution").font(.headline)
                Spacer()
                HStack(spacing: 4) { Circle().fill(.green).frame(width: 8); Text("All regions healthy").font(.caption) }
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                ForEach(regions, id: \.0) { region in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "globe").foregroundStyle(.cyan)
                            Text(region.0).font(.subheadline.bold())
                            Spacer()
                            Circle().fill(region.1 == "Active" ? .green : .orange).frame(width: 8)
                        }
                        Text("\(region.2) edge nodes").font(.caption).foregroundStyle(.secondary)
                        Text(region.1).font(.caption2).foregroundStyle(region.1 == "Active" ? .green : .orange)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                }
            }
            
            Divider()
            
            Text("Cache Settings").font(.headline)
            VStack(alignment: .leading, spacing: 8) {
                HStack { Text("Cache TTL"); Spacer(); Text("24 hours").foregroundStyle(.secondary) }
                HStack { Text("Compression"); Spacer(); Text("Enabled (gzip, brotli)").foregroundStyle(.secondary) }
                HStack { Text("HTTPS"); Spacer(); Text("Enforced").foregroundStyle(.green) }
            }
            .font(.caption)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

struct StorageSettingsView: View {
    @State private var autoCompress = true
    @State private var versioning = true
    @State private var encryption = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Storage Settings").font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Auto-compress uploads", isOn: $autoCompress)
                Toggle("File versioning", isOn: $versioning)
                Toggle("Encryption at rest", isOn: $encryption)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Allowed file types").font(.subheadline)
                    Text("Images, Documents, Videos, Audio").font(.caption).foregroundStyle(.secondary)
                    Button("Configure") {}.buttonStyle(.bordered)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Max file size").font(.subheadline)
                    Picker("", selection: .constant("100MB")) {
                        Text("10MB").tag("10MB")
                        Text("50MB").tag("50MB")
                        Text("100MB").tag("100MB")
                        Text("500MB").tag("500MB")
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

struct SystemStoredFile: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let size: Int
    let type: FileType
    let date: Date
    
    enum FileType { case image, document, video, audio, archive, other }
    
    var icon: String {
        switch type {
        case .image: return "photo.fill"
        case .document: return "doc.fill"
        case .video: return "film.fill"
        case .audio: return "waveform"
        case .archive: return "archivebox.fill"
        case .other: return "doc.fill"
        }
    }
    
    var color: Color {
        switch type {
        case .image: return .green
        case .document: return .blue
        case .video: return .purple
        case .audio: return .orange
        case .archive: return .brown
        case .other: return .secondary
        }
    }
    
    var sizeString: String {
        if size > 1_000_000 { return String(format: "%.1f MB", Double(size) / 1_000_000) }
        return String(format: "%.1f KB", Double(size) / 1_000)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    static var samples: [SystemStoredFile] {
        [
            SystemStoredFile(name: "logo.png", path: "/images/", size: 245_000, type: .image, date: Date()),
            SystemStoredFile(name: "report.pdf", path: "/documents/", size: 1_200_000, type: .document, date: Date().addingTimeInterval(-86400)),
            SystemStoredFile(name: "demo.mp4", path: "/videos/", size: 45_000_000, type: .video, date: Date().addingTimeInterval(-172800)),
            SystemStoredFile(name: "podcast.mp3", path: "/audio/", size: 8_500_000, type: .audio, date: Date().addingTimeInterval(-259200)),
            SystemStoredFile(name: "backup.zip", path: "/archives/", size: 125_000_000, type: .archive, date: Date().addingTimeInterval(-345600)),
        ]
    }
}

#Preview { FileStorageSystemView().frame(width: 1000, height: 700) }
