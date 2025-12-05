import Foundation
#if canImport(AppKit)
import AppKit

public extension NSTextField {
    func applyTextSystem() {
        AppKitTextSystemApplier.apply(to: self, using: TextSystemManager.shared.config)
        NotificationCenter.default.addObserver(forName: .TextSystemDidUpdate, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            AppKitTextSystemApplier.apply(to: self, using: TextSystemManager.shared.config)
        }
    }
}
#endif
