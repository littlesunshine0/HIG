import Foundation
import HIGPackage

do {
    let configuration = try CommandConfiguration(arguments: CommandLine.arguments)
    let document = try loadDocument()
    try run(configuration: configuration, document: document)
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}

private func loadDocument() throws -> HIGDocument {
    guard let url = Bundle.module.url(forResource: "hig_combined", withExtension: "json") else {
        throw CLIError.missingResource
    }
    return try HIGDataLoader.load(from: url)
}

private func run(configuration: CommandConfiguration, document: HIGDocument) throws {
    switch configuration.mode {
    case .listCategories:
        let categories = document.categories.keys.sorted()
        if categories.isEmpty {
            print("No categories found in the dataset.")
        } else {
            categories.forEach { print($0) }
        }
    case .search(let query):
        let results = HIGDataLoader.searchTopics(matching: query, in: document)
        if results.isEmpty {
            print("No topics found matching \"\(query)\".")
        } else {
            results.forEach { topic in
                print("\(topic.title) (\(topic.category))\n\(topic.url.absoluteString)\n")
            }
        }
    case .help:
        print(CommandConfiguration.helpText)
    }
}

enum CLIMode: Equatable {
    case listCategories
    case search(query: String)
    case help
}

struct CommandConfiguration {
    let mode: CLIMode

    init(arguments: [String]) throws {
        var iterator = arguments.dropFirst().makeIterator()

        if let first = iterator.next() {
            switch first {
            case "--list", "-l":
                mode = .listCategories
            case "--search", "-s":
                if let query = iterator.next(), !query.isEmpty {
                    mode = .search(query: query)
                } else {
                    throw CLIError.missingSearchQuery
                }
            case "--help", "-h":
                mode = .help
            default:
                throw CLIError.unknownFlag(first)
            }
        } else {
            mode = .help
        }
    }

    static var helpText: String {
        """
        hig-cli

        Usage:
          hig-cli --list          List all guideline categories
          hig-cli --search QUERY  Search topics by title, abstract, or section text
          hig-cli --help          Show this help information
        """
    }
}

enum CLIError: LocalizedError {
    case missingResource
    case missingSearchQuery
    case unknownFlag(String)

    var errorDescription: String? {
        switch self {
        case .missingResource:
            return "Unable to locate hig_combined.json in bundled resources."
        case .missingSearchQuery:
            return "--search requires a query argument."
        case .unknownFlag(let flag):
            return "Unknown argument: \(flag). Use --help to see available options."
        }
    }
}
