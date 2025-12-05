//
//  FileStorageService.swift
//  HIG
//
//  Multi-cloud file storage with CDN integration
//

import Foundation
import Combine

@MainActor
class FileStorageService: ObservableObject {
    
    static let shared = FileStorageService()
    
    @Published var files: [UUID: StoredFile] = [:]
    @Published var folders: [UUID: Folder] = [:]
    @Published var uploads: [UUID: UploadTask] = [:]
    @Published var downloads: [UUID: DownloadTask] = [:]
    @Published var cdnNodes: [CDNNode] = []
    @Published var storageMetrics: [StorageMetric] = []
    
    private let maxFileSize: Int64 = 5_000_000_000 // 5GB
    private let supportedFormats = ["jpg", "png", "pdf", "mp4", "mp3", "zip", "doc", "docx"]
    
    private init() {
        loadCDNNodes()
        loadSampleFiles()
    }
    
    // MARK: - File Upload
    
    func uploadFile(_ request: UploadRequest) async throws -> StoredFile {
        // Validate file size
        guard request.size <= maxFileSize else {
            throw FileStorageError.fileTooLarge
        }
        
        // Validate format
        let ext = request.filename.components(separatedBy: ".").last?.lowercased() ?? ""
        guard supportedFormats.contains(ext) else {
            throw FileStorageError.unsupportedFormat
        }
        
        // Create upload task
        let uploadTask = UploadTask(
            id: UUID(),
            filename: request.filename,
            size: request.size,
            progress: 0,
            status: .uploading,
            startedAt: Date()
        )
        
        uploads[uploadTask.id] = uploadTask
        
        // Simulate upload with progress
        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            try await Task.sleep(nanoseconds: 100_000_000)
            uploads[uploadTask.id]?.progress = progress
        }
        
        // Virus scan
        try await virusScan(uploadTask.id)
        
        // Optimize if image
        let optimizedSize = ext == "jpg" || ext == "png" ? request.size / 2 : request.size
        
        // Generate thumbnail
        let thumbnailUrl = ext == "jpg" || ext == "png" || ext == "pdf" ? 
            "https://cdn.hig.app/thumbnails/\(UUID().uuidString).jpg" : nil
        
        // Create file record
        let file = StoredFile(
            id: UUID(),
            filename: request.filename,
            size: optimizedSize,
            mimeType: mimeType(for: ext),
            url: "https://storage.hig.app/files/\(UUID().uuidString)",
            cdnUrl: "https://cdn.hig.app/files/\(UUID().uuidString)",
            thumbnailUrl: thumbnailUrl,
            ownerId: request.ownerId,
            folderId: request.folderId,
            isPublic: request.isPublic,
            uploadedAt: Date(),
            lastAccessedAt: nil,
            downloadCount: 0,
            metadata: extractMetadata(filename: request.filename, size: optimizedSize)
        )
        
        files[file.id] = file
        uploads[uploadTask.id]?.status = .completed
        
        recordMetric(type: .upload, size: optimizedSize)
        
        return file
    }
    
    // MARK: - File Download
    
    func downloadFile(_ fileId: UUID) async throws -> Data {
        guard var file = files[fileId] else {
            throw FileStorageError.fileNotFound
        }
        
        let downloadTask = DownloadTask(
            id: UUID(),
            fileId: fileId,
            progress: 0,
            status: .downloading,
            startedAt: Date()
        )
        
        downloads[downloadTask.id] = downloadTask
        
        // Simulate download
        for progress in stride(from: 0.0, through: 1.0, by: 0.2) {
            try await Task.sleep(nanoseconds: 100_000_000)
            downloads[downloadTask.id]?.progress = progress
        }
        
        downloads[downloadTask.id]?.status = .completed
        
        // Update file stats
        file.lastAccessedAt = Date()
        file.downloadCount += 1
        files[fileId] = file
        
        recordMetric(type: .download, size: file.size)
        
        return Data() // Simulated data
    }
    
    // MARK: - File Management
    
    func deleteFile(_ fileId: UUID) async throws {
        guard files[fileId] != nil else {
            throw FileStorageError.fileNotFound
        }
        
        files.removeValue(forKey: fileId)
        recordMetric(type: .delete, size: 0)
    }
    
    func moveFile(_ fileId: UUID, to folderId: UUID?) async throws {
        guard var file = files[fileId] else {
            throw FileStorageError.fileNotFound
        }
        
        file.folderId = folderId
        files[fileId] = file
    }
    
    // MARK: - Folder Management
    
    func createFolder(_ name: String, parentId: UUID?, ownerId: UUID) -> Folder {
        let folder = Folder(
            id: UUID(),
            name: name,
            parentId: parentId,
            ownerId: ownerId,
            createdAt: Date()
        )
        
        folders[folder.id] = folder
        return folder
    }
    
    func getFilesInFolder(_ folderId: UUID?) -> [StoredFile] {
        files.values.filter { $0.folderId == folderId }
    }
    
    // MARK: - CDN Management
    
    func getCDNUrl(_ fileId: UUID) -> String? {
        files[fileId]?.cdnUrl
    }
    
    func invalidateCDNCache(_ fileId: UUID) async throws {
        guard files[fileId] != nil else {
            throw FileStorageError.fileNotFound
        }
        
        // Simulate cache invalidation
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // MARK: - Security
    
    private func virusScan(_ uploadId: UUID) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Simulate virus detection (1% chance)
        if Int.random(in: 1...100) == 1 {
            uploads[uploadId]?.status = .failed
            throw FileStorageError.virusDetected
        }
    }
    
    func generateSignedUrl(_ fileId: UUID, expiresIn: TimeInterval) throws -> String {
        guard let file = files[fileId] else {
            throw FileStorageError.fileNotFound
        }
        
        let token = UUID().uuidString
        let expires = Date().addingTimeInterval(expiresIn).timeIntervalSince1970
        
        return "\(file.url)?token=\(token)&expires=\(Int(expires))"
    }
    
    // MARK: - Analytics
    
    func getStorageStats(ownerId: UUID) -> StorageStats {
        let userFiles = files.values.filter { $0.ownerId == ownerId }
        let totalSize = userFiles.reduce(0) { $0 + $1.size }
        let totalDownloads = userFiles.reduce(0) { $0 + $1.downloadCount }
        
        return StorageStats(
            totalFiles: userFiles.count,
            totalSize: totalSize,
            totalDownloads: totalDownloads,
            bandwidthUsed: calculateBandwidth(ownerId: ownerId)
        )
    }
    
    private func calculateBandwidth(ownerId: UUID) -> Int64 {
        let last30Days = Date().addingTimeInterval(-86400 * 30)
        return storageMetrics
            .filter { $0.timestamp >= last30Days }
            .filter { $0.type == .download }
            .reduce(0) { $0 + $1.size }
    }
    
    private func recordMetric(type: StorageMetric.MetricType, size: Int64) {
        let metric = StorageMetric(
            id: UUID(),
            type: type,
            size: size,
            timestamp: Date()
        )
        storageMetrics.append(metric)
        
        // Keep only recent metrics
        if storageMetrics.count > 100000 {
            storageMetrics.removeFirst(storageMetrics.count - 100000)
        }
    }
    
    // MARK: - Helpers
    
    private func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "pdf": return "application/pdf"
        case "mp4": return "video/mp4"
        case "mp3": return "audio/mpeg"
        case "zip": return "application/zip"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default: return "application/octet-stream"
        }
    }
    
    private func extractMetadata(filename: String, size: Int64) -> [String: String] {
        [
            "filename": filename,
            "size": "\(size)",
            "uploadedBy": "system"
        ]
    }
    
    // MARK: - Sample Data
    
    private func loadCDNNodes() {
        cdnNodes = [
            CDNNode(id: UUID(), location: "US East", region: "us-east-1", status: .active, requestsPerSecond: 1250, latency: 45),
            CDNNode(id: UUID(), location: "US West", region: "us-west-1", status: .active, requestsPerSecond: 980, latency: 38),
            CDNNode(id: UUID(), location: "Europe", region: "eu-west-1", status: .active, requestsPerSecond: 1450, latency: 52),
            CDNNode(id: UUID(), location: "Asia Pacific", region: "ap-southeast-1", status: .active, requestsPerSecond: 2100, latency: 68),
            CDNNode(id: UUID(), location: "South America", region: "sa-east-1", status: .active, requestsPerSecond: 450, latency: 95)
        ]
    }
    
    private func loadSampleFiles() {
        let sampleFile = StoredFile(
            id: UUID(),
            filename: "sample-document.pdf",
            size: 2_500_000,
            mimeType: "application/pdf",
            url: "https://storage.hig.app/files/sample",
            cdnUrl: "https://cdn.hig.app/files/sample",
            thumbnailUrl: "https://cdn.hig.app/thumbnails/sample.jpg",
            ownerId: UUID(),
            folderId: nil,
            isPublic: false,
            uploadedAt: Date().addingTimeInterval(-86400),
            lastAccessedAt: Date(),
            downloadCount: 42,
            metadata: ["type": "document"]
        )
        
        files[sampleFile.id] = sampleFile
    }
}

// MARK: - Models

struct StoredFile: Identifiable {
    let id: UUID
    let filename: String
    let size: Int64
    let mimeType: String
    let url: String
    let cdnUrl: String
    let thumbnailUrl: String?
    let ownerId: UUID
    var folderId: UUID?
    let isPublic: Bool
    let uploadedAt: Date
    var lastAccessedAt: Date?
    var downloadCount: Int
    let metadata: [String: String]
}

struct Folder: Identifiable {
    let id: UUID
    let name: String
    let parentId: UUID?
    let ownerId: UUID
    let createdAt: Date
}

struct UploadRequest {
    let filename: String
    let size: Int64
    let ownerId: UUID
    let folderId: UUID?
    let isPublic: Bool
}

struct UploadTask: Identifiable {
    let id: UUID
    let filename: String
    let size: Int64
    var progress: Double
    var status: FileTaskStatus
    let startedAt: Date
}

struct DownloadTask: Identifiable {
    let id: UUID
    let fileId: UUID
    var progress: Double
    var status: FileTaskStatus
    let startedAt: Date
}

enum FileTaskStatus: String {
    case pending = "Pending"
    case uploading = "Uploading"
    case downloading = "Downloading"
    case processing = "Processing"
    case completed = "Completed"
    case failed = "Failed"
}

struct CDNNode: Identifiable {
    let id: UUID
    let location: String
    let region: String
    let status: NodeStatus
    let requestsPerSecond: Int
    let latency: Int
    
    enum NodeStatus: String {
        case active = "Active"
        case degraded = "Degraded"
        case offline = "Offline"
    }
}

struct StorageMetric: Identifiable {
    let id: UUID
    let type: MetricType
    let size: Int64
    let timestamp: Date
    
    enum MetricType {
        case upload
        case download
        case delete
    }
}

struct StorageStats {
    let totalFiles: Int
    let totalSize: Int64
    let totalDownloads: Int
    let bandwidthUsed: Int64
}

enum FileStorageError: LocalizedError {
    case fileNotFound
    case fileTooLarge
    case unsupportedFormat
    case virusDetected
    case uploadFailed
    case downloadFailed
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound: return "File not found"
        case .fileTooLarge: return "File exceeds maximum size limit"
        case .unsupportedFormat: return "File format not supported"
        case .virusDetected: return "Virus detected in file"
        case .uploadFailed: return "Upload failed"
        case .downloadFailed: return "Download failed"
        }
    }
}
