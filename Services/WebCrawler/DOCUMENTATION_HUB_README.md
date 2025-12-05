# Documentation Hub - Complete Documentation System

A comprehensive documentation indexing and generation system that crawls Apple Developer docs, Swift.org, GitHub repositories, and local files, producing structured JSON output similar to `hig_combined.json`.

## 🎯 Overview

The Documentation Hub integrates four major documentation sources:

1. **Apple Developer Documentation** - developer.apple.com
2. **Swift.org Documentation** - swift.org and docs.swift.org
3. **GitHub Repositories** - Your personal repos via GitHub API
4. **Local File System** - Home directory, developer docs, and projects

## 📦 Generated JSON Files

The system generates three main JSON files:

### 1. `developer_docs_combined.json`
Structured documentation from Apple and Swift.org websites.

```json
{
  "version": "1.0.0",
  "generatedAt": "2024-01-15T10:30:00Z",
  "source": "Apple Developer + Swift.org",
  "topicCount": 500,
  "topics": [
    {
      "id": "swiftui-view",
      "title": "View",
      "category": "Apple Developer",
      "subcategory": "SwiftUI",
      "abstract": "A type that represents part of your app's user interface...",
      "url": "https://developer.apple.com/documentation/swiftui/view",
      "sections": [...],
      "relatedTopics": [...],
      "platforms": ["iOS", "macOS", "watchOS", "tvOS", "visionOS"],
      "availability": "iOS 13.0+, macOS 10.15+",
      "codeExamples": [...]
    }
  ]
}
```

### 2. `github_repos_combined.json`
Complete documentation of your GitHub repositories.

```json
{
  "version": "1.0.0",
  "generatedAt": "2024-01-15T10:30:00Z",
  "user": "yourusername",
  "repositoryCount": 50,
  "repositories": [
    {
      "id": "user-repo",
      "name": "MyProject",
      "fullName": "user/MyProject",
      "description": "An awesome project",
      "url": "https://github.com/user/MyProject",
      "owner": "user",
      "language": "Swift",
      "stars": 100,
      "forks": 20,
      "readme": "# MyProject\n\n...",
      "structure": [...],
      "codeFiles": [...],
      "topics": ["swift", "ios"],
      "createdAt": "2023-01-01T00:00:00Z",
      "updatedAt": "2024-01-15T00:00:00Z"
    }
  ]
}
```

### 3. `file_index.json`
Index of local files from your system.

```json
{
  "files": [...],
  "repositories": [...],
  "statistics": {
    "totalFiles": 10000,
    "totalSize": 5000000000
  },
  "lastUpdated": "2024-01-15T10:30:00Z"
}
```

## 🚀 Usage

### Quick Start

1. **Open Documentation Hub**
   - Menu: `Infrastructure > Documentation Hub...`
   - Keyboard: `⌘⌥8`

2. **Connect GitHub** (Optional)
   - Click "GitHub Repositories" tab
   - Enter your Personal Access Token
   - Token needs `repo` scope

3. **Start Crawling**
   - Click "Crawl All Sources"
   - Wait for completion (5-30 minutes depending on scope)

4. **Access Generated JSON**
   - Files saved to: `~/Library/Application Support/HIG/`
   - Also copied to project directory for bundling

### GitHub Personal Access Token

Create a token at: https://github.com/settings/tokens

Required scopes:
- `repo` - Full control of private repositories
- `read:user` - Read user profile data

### Programmatic Usage

```swift
// Web Crawler
let crawler = DocumentationCrawler.shared
await crawler.crawlAndGenerateJSON()

// GitHub Service
let github = GitHubService.shared
github.accessToken = "your_token_here"
await github.authenticate()
await github.generateCombinedDocumentation()

// File Indexing
let fileIndexing = FileIndexingService.shared
await fileIndexing.startAutomaticIndexing()
```

## 🏗️ Architecture

### Components

1. **DocumentationCrawler**
   - Crawls Apple Developer and Swift.org websites
   - Parses HTML into structured data
   - Generates HIG-compatible JSON

2. **GitHubService**
   - Authenticates via Personal Access Token
   - Fetches repository metadata
   - Downloads README and code files
   - Generates repository documentation JSON

3. **FileIndexingService**
   - Indexes home directory
   - Finds Git repositories
   - Indexes Apple/Swift local documentation
   - Creates searchable file index

4. **DocumentationHubView**
   - Unified UI for all services
   - Progress tracking
   - Configuration management

### Data Flow

```
User Action
    ↓
Documentation Hub
    ↓
┌─────────────┬──────────────┬────────────────┐
│   Web       │   GitHub     │   File         │
│   Crawler   │   Service    │   Indexing     │
└─────────────┴──────────────┴────────────────┘
    ↓              ↓               ↓
Parse HTML    Fetch via API   Scan Filesystem
    ↓              ↓               ↓
Extract Data  Build Structure  Index Files
    ↓              ↓               ↓
Generate JSON Generate JSON    Generate JSON
    ↓              ↓               ↓
Save to Disk  Save to Disk    Save to Disk
```

## 📋 Features

### Web Crawler

- ✅ Crawls Apple Developer Documentation
- ✅ Crawls Swift.org Documentation
- ✅ Extracts titles, abstracts, and content
- ✅ Parses code examples
- ✅ Detects platforms and availability
- ✅ Respects rate limits
- ✅ Generates structured JSON

### GitHub Integration

- ✅ OAuth-style authentication
- ✅ Fetches all user repositories
- ✅ Downloads README files
- ✅ Indexes repository structure
- ✅ Extracts code files
- ✅ Preserves metadata (stars, forks, topics)
- ✅ Generates comprehensive JSON

### File Indexing

- ✅ Indexes home directory
- ✅ Finds Git repositories
- ✅ Indexes Apple/Swift docs
- ✅ Full-text search
- ✅ File type detection
- ✅ Keyword extraction

## ⚙️ Configuration

### Web Crawler Settings

```swift
var config = CrawlerConfig()
config.crawlAppleDocs = true
config.crawlSwiftDocs = true
config.maxPagesPerSite = 500
config.delayBetweenRequests = 0.5 // seconds
config.respectRobotsTxt = true
```

### GitHub Settings

```swift
// Set access token
GitHubService.shared.accessToken = "ghp_..."

// Authenticate
await GitHubService.shared.authenticate()
```

### File Indexing Settings

```swift
var config = IndexingConfig()
config.indexHomeDirectory = true
config.indexAppleDocs = true
config.indexSwiftDocs = true
config.indexGitHubRepos = true
config.maxDepth = 10
config.maxFileSizeBytes = 10_000_000
```

## 🔒 Privacy & Security

- All data stored locally
- GitHub token encrypted in Keychain
- No data sent to third parties
- Respects robots.txt
- Rate limiting to avoid abuse
- User controls what gets indexed

## 📊 Performance

### Typical Crawl Times

- Apple Developer Docs: 10-20 minutes (500 pages)
- Swift.org Docs: 5-10 minutes (200 pages)
- GitHub Repos (50 repos): 15-30 minutes
- Local Files (100K files): 5-10 minutes

### Optimization

- Concurrent requests (with rate limiting)
- Incremental updates
- Persistent caching
- Background processing
- Progress tracking

## 🐛 Troubleshooting

### Web Crawler Issues

**Problem**: Crawling is slow
- **Solution**: Reduce `maxPagesPerSite` or increase `delayBetweenRequests`

**Problem**: Pages not being indexed
- **Solution**: Check internet connection, verify URLs are accessible

### GitHub Issues

**Problem**: Authentication fails
- **Solution**: Verify token has correct scopes, check token hasn't expired

**Problem**: Rate limit exceeded
- **Solution**: Wait 1 hour or use authenticated requests (higher limit)

### File Indexing Issues

**Problem**: Files not appearing
- **Solution**: Check file permissions, verify paths aren't excluded

**Problem**: High memory usage
- **Solution**: Reduce `maxDepth` or `maxFileSizeBytes`

## 🔄 Updates

### Manual Update

```swift
// Re-crawl everything
await DocumentationCrawler.shared.crawlAndGenerateJSON()
await GitHubService.shared.generateCombinedDocumentation()
await FileIndexingService.shared.startAutomaticIndexing()
```

### Automatic Updates

Configure auto-update intervals in settings:
- Daily
- Weekly
- Monthly
- Manual only

## 📝 JSON Schema

### Documentation Topic Schema

```typescript
interface DocumentationTopic {
  id: string;
  title: string;
  category: string;
  subcategory?: string;
  abstract: string;
  url: string;
  sections: Section[];
  relatedTopics: RelatedTopic[];
  platforms: string[];
  availability: string;
  codeExamples: CodeExample[];
}

interface Section {
  heading: string;
  content: Content[];
}

interface Content {
  type: "paragraph" | "code" | "list" | "image";
  text?: string;
  code?: string;
  language?: string;
}

interface CodeExample {
  title: string;
  code: string;
  language: string;
  description?: string;
}
```

## 🎯 Use Cases

1. **Offline Documentation Access**
   - Download all docs for offline use
   - Search across all sources
   - No internet required

2. **Personal Knowledge Base**
   - Index your GitHub repos
   - Search your code
   - Find examples quickly

3. **AI Training Data**
   - Generate training datasets
   - Fine-tune models on your code
   - Create custom documentation

4. **Documentation Generation**
   - Auto-generate docs from code
   - Create API references
   - Build knowledge graphs

## 🚧 Future Enhancements

- [ ] Incremental updates (only changed pages)
- [ ] Semantic search with embeddings
- [ ] AI-powered summarization
- [ ] Cross-reference linking
- [ ] Version tracking
- [ ] Diff visualization
- [ ] Export to other formats (Markdown, PDF)
- [ ] Integration with other doc sources (Stack Overflow, Medium)
- [ ] Real-time collaboration
- [ ] Cloud sync

## 📚 API Reference

See individual service documentation:
- [DocumentationCrawler.swift](./DocumentationCrawler.swift)
- [GitHubService.swift](../GitHub/GitHubService.swift)
- [FileIndexingService.swift](../FileIndexing/FileIndexingService.swift)

## 🤝 Contributing

When adding new features:
1. Update this README
2. Add tests
3. Update UI if needed
4. Consider performance impact
5. Document JSON schema changes

## 📄 License

Part of the HIG application. All rights reserved.
