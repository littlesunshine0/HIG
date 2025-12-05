import XCTest
@testable import HIGPackage

final class HIGDataLoaderTests: XCTestCase {
    static var allTests = [
        ("testLoadsDocumentFromFixture", testLoadsDocumentFromFixture),
        ("testTopicsForCategoryFallsBackToList", testTopicsForCategoryFallsBackToList),
        ("testSearchMatchesTitleAndSectionText", testSearchMatchesTitleAndSectionText)
    ]

    func testLoadsDocumentFromFixture() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "sample_hig", withExtension: "json"))
        let document = try HIGDataLoader.load(from: url)

        XCTAssertEqual(document.version, "1.0")
        XCTAssertEqual(document.source, "Apple Human Interface Guidelines")
        XCTAssertEqual(document.topicCount, 2)
        XCTAssertEqual(document.topics.count, 2)
        XCTAssertEqual(document.categories["Foundations"]?.count, 1)
    }

    func testTopicsForCategoryFallsBackToList() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "sample_hig", withExtension: "json"))
        let document = try HIGDataLoader.load(from: url)

        // Use a custom category that is not in the categories map to exercise fallback
        let results = HIGDataLoader.topics(for: "components", in: document)
        XCTAssertEqual(results.map(\.id), ["buttons"])
    }

    func testSearchMatchesTitleAndSectionText() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "sample_hig", withExtension: "json"))
        let document = try HIGDataLoader.load(from: url)

        let matchesTitle = HIGDataLoader.searchTopics(matching: "button", in: document)
        XCTAssertEqual(matchesTitle.map(\.id), ["buttons"])

        let matchesSection = HIGDataLoader.searchTopics(matching: "contrast", in: document)
        XCTAssertEqual(matchesSection.map(\.id), ["accessibility"])
    }
}
