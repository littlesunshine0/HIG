//
//  AppIcons.swift
//  Shared helpers for App Icon alternates and SwiftUI picker.
//  Requires iOS 10.3+ (for alternate icons). Gracefully no-ops on unsupported platforms.
//

import Foundation
import SwiftUI

// MARK: - App Icon Variants

public enum AppIconVariant: String, CaseIterable, Identifiable, Codable, Hashable {
    /// Matches the primary icon (nil alternate name).
    case primary = "_primary"
    /// Declare additional cases to mirror CFBundleAlternateIcons keys, e.g. "Blue", "Retro".
    /// case blue = "Blue"
    /// case retro = "Retro"

    public var id: String { rawValue }

    /// Human-readable label for UI
    public var displayName: String {
        switch self {
        case .primary: return "Default"
        default: return rawValue
        }
    }

    /// Name of the asset catalog entry for previews (convention: AppIcon or AppIcon-Alt-<Name>).
    public var assetName: String {
        switch self {
        case .primary: return "AppIcon"
        default: return "AppIcon-Alt-\(rawValue)"
        }
    }

    /// Underlying alternate icon name for UIApplication (nil for primary).
    public var alternateIconSystemName: String? {
        switch self {
        case .primary: return nil
        default: return rawValue
        }
    }
}

// MARK: - Manager

@MainActor
public final class AppIconManager: ObservableObject {
    @Published public private(set) var current: AppIconVariant = .primary
    @Published public private(set) var available: [AppIconVariant] = [.primary]

    public init() {
        reloadFromBundle()
        current = detectCurrent()
    }

    /// Returns true when the platform and OS support switching icons at runtime.
    public func supportsAlternateIcons() -> Bool {
        #if os(iOS) || os(visionOS)
        if #available(iOS 10.3, *) {
            return UIApplication.shared.supportsAlternateIcons
        }
        return false
        #else
        return false
        #endif
    }

    /// Apply the given variant; on unsupported platforms this completes with success and no-ops.
    public func apply(_ variant: AppIconVariant, completion: @escaping (Result<Void, Error>) -> Void) {
        #if os(iOS) || os(visionOS)
        if #available(iOS 10.3, *) {
            let name = variant.alternateIconSystemName
            UIApplication.shared.setAlternateIconName(name) { error in
                Task { @MainActor in
                    if let error = error { completion(.failure(error)) }
                    else {
                        self.current = self.detectCurrent()
                        #if canImport(UIKit)
                        UIAccessibility.post(notification: .announcement, argument: "App icon updated")
                        #endif
                        completion(.success(()))
                    }
                }
            }
            return
        }
        #endif
        // Unsupported platforms: update model only.
        self.current = variant
        completion(.success(()))
    }

    /// Refresh available variants from Info.plist (CFBundleAlternateIcons).
    public func reloadFromBundle() {
        let names = alternateIconNamesInBundle()
        var variants: [AppIconVariant] = [.primary]
        for name in names.sorted() {
            if let v = AppIconVariant(rawValue: name) {
                variants.append(v)
            } else {
                // If not declared as a case, still expose a dynamic variant
                variants.append(.init(rawValue: name))
            }
        }
        available = Array(Set(variants)).sorted { $0.displayName < $1.displayName }
    }

    /// Returns CFBundleAlternateIcons keys.
    public func alternateIconNamesInBundle() -> [String] {
        guard
            let info = Bundle.main.infoDictionary,
            let icons = info["CFBundleIcons"] as? [String: Any],
            let alternates = icons["CFBundleAlternateIcons"] as? [String: Any]
        else { return [] }
        return Array(alternates.keys)
    }

    private func detectCurrent() -> AppIconVariant {
        #if os(iOS) || os(visionOS)
        if #available(iOS 10.3, *) {
            if let name = UIApplication.shared.alternateIconName {
                return AppIconVariant(rawValue: name) ?? .init(rawValue: name)
            }
        }
        #endif
        return .primary
    }
}

// MARK: - SwiftUI Picker

public struct AppIconPickerView: View {
    @ObservedObject var manager: AppIconManager

    public init(manager: AppIconManager) { self.manager = manager }

    public var body: some View {
        // Use a simple grid/list that works across platforms
        let cols = [GridItem(.adaptive(minimum: 88), spacing: 16)]
        LazyVGrid(columns: cols, spacing: 16) {
            ForEach(manager.available, id: \.self) { variant in
                AppIconPreviewTile(variant: variant,
                                   isSelected: variant == manager.current)
                .onTapGesture { select(variant) }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("\(variant.displayName) icon"))
                .accessibilityValue(Text(variant == manager.current ? "Selected" : "Not selected"))
                .accessibilityAddTraits(variant == manager.current ? .isSelected : [])
            }
        }
        .onAppear { manager.reloadFromBundle() }
    }

    private func select(_ variant: AppIconVariant) {
        manager.apply(variant) { _ in }
    }
}

struct AppIconPreviewTile: View {
    let variant: AppIconVariant
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Placeholder preview using app asset name; in practice, use a proper preview image.
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.12))
                .frame(width: 72, height: 72)
                .overlay(
                    Text(variant.displayName.prefix(1))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary.opacity(0.85))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.25), lineWidth: isSelected ? 2 : 1)
                )

            Text(variant.displayName)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.gray.opacity(0.08)))
    }
}

// MARK: - Previews (SwiftUI)

#if DEBUG
struct _AppIconPickerPreview: PreviewProvider {
    static var previews: some View {
        AppIconPickerView(manager: AppIconManager())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
