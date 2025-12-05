//
//  DocumentExtractor.swift
//  HIG
//
//  Advanced content extraction for different file types
//  Extracts documentation, comments, and structured information
//

import Foundation

// MARK: - Document Content

struct ExtractedContent {
    let filePath: String
    let fileType: FileType
    let title: String
    let content: String
    let metadata: [String: String]
    let sections: [ContentSection]
    
    struct ContentSection {
        let heading: String
        let content: String
        let lineNumber: Int?
    }
    
    enum FileType {
        case markdown
        case code(language: String)
        case json
        case log
        case database
        case plain
    }
}

// MARK: - Document Extractor

class DocumentExtractor {
    
    /// Extract structured content from a file
    static func extract(from url: URL) -> ExtractedContent? {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        
        let ext = url.pathExtension.lowercased()
        let filename = url.lastPathComponent
        
        // Determine file type and extract accordingly
        if ext == "swift" {
            return extractSwift(content: content, filename: filename, path: url.path)
        } else if ext == "json" {
            return extractJSON(content: content, filename: filename, path: url.path)
        } else if ["md", "markdown"].contains(ext) {
            return extractMarkdown(content: content, filename: filename, path: url.path)
        } else if ["log", "diag", "crash", "hang", "spin"].contains(ext) {
            return extractLog(content: content, filename: filename, path: url.path)
        } else if ["h", "m", "mm", "c", "cpp"].contains(ext) {
            return extractCFamily(content: content, filename: filename, path: url.path, language: ext)
        } else if ["js", "ts", "jsx", "tsx"].contains(ext) {
            return extractJavaScript(content: content, filename: filename, path: url.path)
        } else if ext == "py" {
            return extractPython(content: content, filename: filename, path: url.path)
        } else {
            return extractPlain(content: content, filename: filename, path: url.path)
        }
    }
    
    // MARK: - Swift Extraction
    
    private static func extractSwift(content: String, filename: String, path: String) -> ExtractedContent {
        var sections: [ExtractedContent.ContentSection] = []
        var metadata: [String: String] = [:]
        
        let lines = content.components(separatedBy: .newlines)
        var currentComment = ""
        var lineNumber = 0
        
        for line in lines {
            lineNumber += 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Extract documentation comments
            if trimmed.hasPrefix("///") {
                let comment = trimmed.dropFirst(3).trimmingCharacters(in: .whitespaces)
                currentComment += comment + "\n"
            }
            // Extract multi-line doc comments
            else if trimmed.hasPrefix("/**") || trimmed.contains("/**") {
                currentComment += trimmed.replacingOccurrences(of: "/**", with: "")
                    .replacingOccurrences(of: "*/", with: "")
                    .trimmingCharacters(in: .whitespaces) + "\n"
            }
            // Extract MARK comments
            else if trimmed.contains("// MARK:") {
                let mark = trimmed.replacingOccurrences(of: "// MARK:", with: "")
                    .replacingOccurrences(of: "-", with: "")
                    .trimmingCharacters(in: .whitespaces)
                if !mark.isEmpty {
                    sections.append(.init(heading: mark, content: "", lineNumber: lineNumber))
                }
            }
            // Extract function/class/struct declarations with their doc comments
            else if trimmed.hasPrefix("func ") || trimmed.hasPrefix("class ") ||
                    trimmed.hasPrefix("struct ") || trimmed.hasPrefix("enum ") ||
                    trimmed.hasPrefix("protocol ") || trimmed.hasPrefix("extension ") {
                
                if !currentComment.isEmpty {
                    let declaration = extractDeclaration(from: trimmed)
                    sections.append(.init(
                        heading: declaration,
                        content: currentComment,
                        lineNumber: lineNumber
                    ))
                    currentComment = ""
                }
            }
        }
        
        // Extract file-level documentation from header
        let headerDoc = extractHeaderComment(from: content)
        metadata["description"] = headerDoc
        
        return ExtractedContent(
            filePath: path,
            fileType: .code(language: "swift"),
            title: filename,
            content: content,
            metadata: metadata,
            sections: sections
        )
    }
    
    // MARK: - JSON Extraction
    
    private static func extractJSON(content: String, filename: String, path: String) -> ExtractedContent {
        var sections: [ExtractedContent.ContentSection] = []
        var metadata: [String: String] = [:]
        
        // Try to parse JSON and extract structure
        if let data = content.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            
            // Extract common metadata fields
            if let name = json["name"] as? String {
                metadata["name"] = name
            }
            if let version = json["version"] as? String {
                metadata["version"] = version
            }
            if let description = json["description"] as? String {
                metadata["description"] = description
            }
            
            // Extract top-level keys as sections
            for (key, value) in json {
                let valueStr = formatJSONValue(value)
                sections.append(.init(
                    heading: key,
                    content: valueStr,
                    lineNumber: nil
                ))
            }
        }
        
        return ExtractedContent(
            filePath: path,
            fileType: .json,
            title: filename,
            content: content,
            metadata: metadata,
            sections: sections
        )
    }
    
    // MARK: - Markdown Extraction
    
    private static func extractMarkdown(content: String, filename: String, path: String) -> ExtractedContent {
        var sections: [ExtractedContent.ContentSection] = []
        let metadata: [String: String] = [:]
        
        let lines = content.components(separatedBy: .newlines)
        var currentHeading = ""
        var currentContent = ""
        var lineNumber = 0
        
        for line in lines {
            lineNumber += 1
            
            // Extract headings
            if line.hasPrefix("#") {
                // Save previous section
                if !currentHeading.isEmpty {
                    sections.append(.init(
                        heading: currentHeading,
                        content: currentContent.trimmingCharacters(in: .whitespacesAndNewlines),
                        lineNumber: lineNumber
                    ))
                }
                
                // Start new section
                currentHeading = line.replacingOccurrences(of: "#", with: "")
                    .trimmingCharacters(in: .whitespaces)
                currentContent = ""
            } else {
                currentContent += line + "\n"
            }
        }
        
        // Add last section
        if !currentHeading.isEmpty {
            sections.append(.init(
                heading: currentHeading,
                content: currentContent.trimmingCharacters(in: .whitespacesAndNewlines),
                lineNumber: nil
            ))
        }
        
        // Extract title from first heading or filename
        let title = sections.first?.heading ?? filename
        
        return ExtractedContent(
            filePath: path,
            fileType: .markdown,
            title: title,
            content: content,
            metadata: metadata,
            sections: sections
        )
    }
    
    // MARK: - Log Extraction
    
    private static func extractLog(content: String, filename: String, path: String) -> ExtractedContent {
        var sections: [ExtractedContent.ContentSection] = []
        var metadata: [String: String] = [:]
        
        let lines = content.components(separatedBy: .newlines)
        
        // Extract log metadata from first few lines
        for line in lines.prefix(10) {
            if line.contains("Process:") {
                metadata["process"] = line.replacingOccurrences(of: "Process:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.contains("Date/Time:") {
                metadata["timestamp"] = line.replacingOccurrences(of: "Date/Time:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.contains("OS Version:") {
                metadata["os_version"] = line.replacingOccurrences(of: "OS Version:", with: "").trimmingCharacters(in: .whitespaces)
            }
        }
        
        // Group log entries by severity or timestamp
        var currentSection = ""
        var currentContent = ""
        
        for line in lines {
            // Detect section headers (often in caps or with specific patterns)
            if line.uppercased() == line && line.count > 5 && !line.isEmpty {
                if !currentSection.isEmpty {
                    sections.append(.init(heading: currentSection, content: currentContent, lineNumber: nil))
                }
                currentSection = line
                currentContent = ""
            } else {
                currentContent += line + "\n"
            }
        }
        
        if !currentSection.isEmpty {
            sections.append(.init(heading: currentSection, content: currentContent, lineNumber: nil))
        }
        
        return ExtractedContent(
            filePath: path,
            fileType: .log,
            title: filename,
            content: content,
            metadata: metadata,
            sections: sections
        )
    }
    
    // MARK: - C Family Extraction
    
    private static func extractCFamily(content: String, filename: String, path: String, language: String) -> ExtractedContent {
        var sections: [ExtractedContent.ContentSection] = []
        let metadata: [String: String] = [:]
        
        let lines = content.components(separatedBy: .newlines)
        var currentComment = ""
        var lineNumber = 0
        
        for line in lines {
            lineNumber += 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Extract documentation comments (Doxygen style)
            if trimmed.hasPrefix("///") || trimmed.hasPrefix("//!") {
                currentComment += trimmed.dropFirst(3).trimmingCharacters(in: .whitespaces) + "\n"
            }
            // Multi-line comments
            else if trimmed.hasPrefix("/**") || trimmed.hasPrefix("/*!") {
                currentComment += trimmed
            }
            // Function declarations
            else if (trimmed.contains("(") && trimmed.contains(")")) &&
                    (trimmed.contains("void") || trimmed.contains("int") || trimmed.contains("*")) {
                if !currentComment.isEmpty {
                    sections.append(.init(heading: trimmed, content: currentComment, lineNumber: lineNumber))
                    currentComment = ""
                }
            }
        }
        
        return ExtractedContent(
            filePath: path,
            fileType: .code(language: language),
            title: filename,
            content: content,
            metadata: metadata,
            sections: sections
        )
    }
    
    // MARK: - JavaScript/TypeScript Extraction
    
    private static func extractJavaScript(content: String, filename: String, path: String) -> ExtractedContent {
        var sections: [ExtractedContent.ContentSection] = []
        var metadata: [String: String] = [:]
        
        let lines = content.components(separatedBy: .newlines)
        var currentComment = ""
        var lineNumber = 0
        
        for line in lines {
            lineNumber += 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // JSDoc comments
            if trimmed.hasPrefix("/**") {
                currentComment = ""
            } else if trimmed.hasPrefix("*") && !trimmed.hasPrefix("*/") {
                currentComment += trimmed.dropFirst().trimmingCharacters(in: .whitespaces) + "\n"
            }
            // Function/class declarations
            else if trimmed.hasPrefix("function ") || trimmed.hasPrefix("class ") ||
                    trimmed.hasPrefix("export ") || trimmed.hasPrefix("const ") {
                if !currentComment.isEmpty {
                    sections.append(.init(heading: trimmed, content: currentComment, lineNumber: lineNumber))
                    currentComment = ""
                }
            }
        }
        
        return ExtractedContent(
            filePath: path,
            fileType: .code(language: "javascript"),
            title: filename,
            content: content,
            metadata: metadata,
            sections: sections
        )
    }
    
    // MARK: - Python Extraction
    
    private static func extractPython(content: String, filename: String, path: String) -> ExtractedContent {
        var sections: [ExtractedContent.ContentSection] = []
        var metadata: [String: String] = [:]
        
        let lines = content.components(separatedBy: .newlines)
        var currentDocstring = ""
        var inDocstring = false
        var lineNumber = 0
        
        for line in lines {
            lineNumber += 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Python docstrings
            if trimmed.hasPrefix("\"\"\"") || trimmed.hasPrefix("'''") {
                if inDocstring {
                    inDocstring = false
                    // Docstring complete
                } else {
                    inDocstring = true
                    currentDocstring = trimmed.replacingOccurrences(of: "\"\"\"", with: "")
                        .replacingOccurrences(of: "'''", with: "")
                }
            } else if inDocstring {
                currentDocstring += trimmed + "\n"
            }
            // Function/class definitions
            else if trimmed.hasPrefix("def ") || trimmed.hasPrefix("class ") {
                if !currentDocstring.isEmpty {
                    sections.append(.init(heading: trimmed, content: currentDocstring, lineNumber: lineNumber))
                    currentDocstring = ""
                }
            }
        }
        
        return ExtractedContent(
            filePath: path,
            fileType: .code(language: "python"),
            title: filename,
            content: content,
            metadata: metadata,
            sections: sections
        )
    }
    
    // MARK: - Plain Text Extraction
    
    private static func extractPlain(content: String, filename: String, path: String) -> ExtractedContent {
        return ExtractedContent(
            filePath: path,
            fileType: .plain,
            title: filename,
            content: content,
            metadata: [:],
            sections: []
        )
    }
    
    // MARK: - Helper Functions
    
    private static func extractHeaderComment(from content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        var headerComment = ""
        var inHeader = false
        
        for line in lines {
            if line.contains("//") && !inHeader {
                inHeader = true
            }
            if inHeader {
                if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    break
                }
                headerComment += line.replacingOccurrences(of: "//", with: "").trimmingCharacters(in: .whitespaces) + "\n"
            }
        }
        
        return headerComment.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func extractDeclaration(from line: String) -> String {
        // Extract just the declaration part (before {)
        if let braceIndex = line.firstIndex(of: "{") {
            return String(line[..<braceIndex]).trimmingCharacters(in: .whitespaces)
        }
        return line
    }
    
    private static func formatJSONValue(_ value: Any) -> String {
        if let dict = value as? [String: Any] {
            return dict.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        } else if let array = value as? [Any] {
            return array.map { "\($0)" }.joined(separator: ", ")
        } else {
            return "\(value)"
        }
    }
}
