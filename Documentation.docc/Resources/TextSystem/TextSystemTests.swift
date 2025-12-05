import Testing
@testable import YourModuleName

@Suite("Text System Update Flow")
struct TextSystemTests {

    @Test("Apply theme updates config and posts notification")
    func applyTheme() async throws {
        let mgr = TextSystemManager.shared
        let exp = AsyncExpectation()
        var observed = false
        let token = NotificationCenter.default.addObserver(forName: .TextSystemDidUpdate, object: nil, queue: .main) { _ in
            observed = true
            exp.fulfill()
        }
        defer { NotificationCenter.default.removeObserver(token) }

        await MainActor.run {
            mgr.applyTheme(named: "HighContrast")
        }

        await exp.value
        #expect(observed)
        #expect(mgr.config.themeName == "HighContrast")
        #expect(mgr.config.features.contains(.highContrast))
    }

    @Test("Bundle config load")
    func bundleLoad() async throws {
        let cfg = TextSystemConfigLoader.loadFromBundle()
        #expect(cfg != nil)
    }
}

final class AsyncExpectation {
    private var continuation: CheckedContinuation<Void, Never>?
    private var fulfilled = false

    func fulfill() {
        guard !fulfilled else { return }
        fulfilled = true
        continuation?.resume()
    }

    var value: Void {
        get async {
            await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
                if fulfilled {
                    c.resume()
                } else {
                    continuation = c
                }
            }
        }
    }
}
