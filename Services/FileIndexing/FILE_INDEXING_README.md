# File Indexing Service

Comprehensive file system indexing service that automatically indexes and organizes your development environment.

## Features

### 🏠 Home Directory Indexing
- Automatically indexes your entire home directory
- Excludes system files, caches, and temporary directories
- Respects `.gitignore` patterns
- Configurable depth and file size limits

### 📚 Developer Documentation
- **Apple Documentation**: Indexes Xcode documentation and developer resources
- **Swift Documentation**: Indexes Swift language documentation and toolchain docs
- Automatically finds documentation in standard locations

### 🐙 GitHub Repository Discovery
- Automatically finds and indexes all Git repositories
- Searches common project directories (Projects, Developer, Code, Documents)
- Extracts repository metadata (name, remote URL, local path)
- Indexes repository contents while excluding build artifacts

### 🔍 Powerful Search
- Full-text search across all indexed files
- Keyword extraction and indexing
- Path-based search
- File type filtering
- Recently modified files

### ⚡️ Performance Optimized
- Background indexing doesn't block UI
- Incremental updates
- Persistent index cache
- Configurable resource limits

## Usage

### Automatic Indexing

The service starts automatically on app launch and indexes:
1. Home directory (configurable)
2. Apple developer documentation
3. Swift documentation  
4. GitHub repositories

### Manual Control

Access the File Index dashboard via:
- Menu: `Infrastructure > File Index...`
- Keyboard: `⌘⌥7`

### Search

```swift
let service = FileIndexingService.shared

// Search for files
let results = service.search(query: "authentication", limit: 50)

// Filter by type
let codeFiles = service.files(ofType: .code)

// Get recent files
let recent = service.recentFiles(limit: 20)
```

## Configuration

### Indexing Options

```swift
var config = IndexingConfig()
config.indexHomeDirectory = true
config.indexAppleDocs = true
config.indexSwiftDocs = true
config.indexGitHubRepos = true
config.maxDepth = 10
config.maxFileSizeBytes = 10_000_000 // 10MB
config.autoReindexInterval = 86400 // 24 hours
```

### Excluded Paths

The following paths are automatically excluded:
- `.Trash`
- `Library/Caches`
- `Library/Logs`
- `.cache`
- `node_modules`
- `.git`
- `build`
- `.build`

## File Types

Supported file types with specialized handling:

- **Code**: `.swift`, `.m`, `.mm`, `.h`, `.c`, `.cpp`, `.hpp`
- **Documentation**: `.md`, `.markdown`, `.txt`, `.rtf`, `.pdf`
- **Configuration**: `.json`, `.yaml`, `.yml`, `.plist`, `.xml`, `.toml`
- **Images**: `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.heic`
- **Videos**: `.mp4`, `.mov`, `.avi`, `.mkv`
- **Audio**: `.mp3`, `.m4a`, `.wav`, `.aiff`

## Architecture

### Components

1. **FileIndexingService**: Core indexing engine
2. **FileIndexingDashboard**: UI for browsing and searching
3. **IndexedFile**: File metadata model
4. **GitHubRepository**: Repository metadata model

### Data Flow

```
App Launch
    ↓
Initialize Service
    ↓
Load Cached Index (if available)
    ↓
Start Background Indexing
    ↓
Index Home Directory
    ↓
Index Developer Docs
    ↓
Index GitHub Repos
    ↓
Build Search Index
    ↓
Save to Disk
```

### Storage

Index is persisted to:
```
~/Library/Application Support/HIG/file_index.json
```

## Privacy & Security

- All indexing happens locally
- No data sent to external services
- Respects macOS sandboxing
- User can disable any indexing category
- Excluded paths configurable

## Performance

### Optimization Strategies

1. **Lazy Loading**: Files loaded on-demand
2. **Incremental Updates**: Only changed files re-indexed
3. **Background Processing**: Non-blocking UI
4. **Size Limits**: Skip large files
5. **Depth Limits**: Prevent infinite recursion
6. **Caching**: Persistent index cache

### Benchmarks

Typical indexing performance:
- Home directory (~100K files): 2-5 minutes
- Developer docs (~10K files): 30-60 seconds
- GitHub repos (~50 repos): 1-2 minutes

## Future Enhancements

- [ ] Real-time file system monitoring (FSEvents)
- [ ] Semantic code search
- [ ] Git history integration
- [ ] Duplicate file detection
- [ ] Smart folder suggestions
- [ ] Cloud sync support
- [ ] Advanced filtering (date ranges, size ranges)
- [ ] Export search results
- [ ] Saved searches
- [ ] File tagging system

## API Reference

### FileIndexingService

```swift
@MainActor
class FileIndexingService: ObservableObject {
    static let shared: FileIndexingService
    
    // State
    @Published var indexingState: IndexingState
    @Published var indexedFiles: [IndexedFile]
    @Published var indexedRepositories: [GitHubRepository]
    @Published var statistics: IndexStatistics
    @Published var isIndexing: Bool
    @Published var progress: Double
    
    // Methods
    func startAutomaticIndexing() async
    func search(query: String, limit: Int) -> [IndexedFile]
    func files(ofType type: FileType) -> [IndexedFile]
    func recentFiles(limit: Int) -> [IndexedFile]
}
```

### IndexedFile

```swift
struct IndexedFile: Codable, Identifiable {
    let id: UUID
    let path: String
    let name: String
    let type: FileType
    let size: Int64
    let modifiedDate: Date
    let content: String?
    let keywords: [String]
}
```

### GitHubRepository

```swift
struct GitHubRepository: Codable, Identifiable {
    let id: UUID
    let name: String
    let localPath: String
    let remoteURL: String?
    let lastIndexed: Date
}
```

## Troubleshooting

### Indexing is slow
- Reduce `maxDepth` in settings
- Increase `maxFileSizeBytes` threshold
- Disable indexing for large directories

### Files not appearing
- Check excluded paths configuration
- Verify file permissions
- Ensure file size is under limit

### High memory usage
- Reduce number of indexed files
- Clear and rebuild index
- Restart app

## Contributing

When adding new features:
1. Update this README
2. Add tests for new functionality
3. Update UI if needed
4. Consider performance impact

## License

Part of the HIG application. All rights reserved.
