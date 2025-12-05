//
//  HIGButtons.swift
//  Generated from Apple Human Interface Guidelines
//
//  HIG-compliant button styles and components
//
//  Generated: 2025-11-25
//

import SwiftUI

#if os(macOS)
private let HIGIsMac: Bool = true
#else
private let HIGIsMac: Bool = false
#endif

/// Visual configuration for HIG buttons (icon, shape, color, layout, tooltip)
struct HIGButtonStyleConfig {
    var systemImage: String? = nil
    var tooltip: String? = nil
    var tint: Color? = nil
    var controlSize: ControlSize = .large
    var shape: HIGButtonShape = .rounded
    var fillsWidth: Bool = !HIGIsMac
    
    init(systemImage: String? = nil, tooltip: String? = nil, tint: Color? = nil, controlSize: ControlSize = .large, shape: HIGButtonShape = .rounded, fillsWidth: Bool = !HIGIsMac) {
        self.systemImage = systemImage
        self.tooltip = tooltip
        self.tint = tint
        self.controlSize = controlSize
        self.shape = shape
        self.fillsWidth = fillsWidth
    }
}

enum HIGButtonShape {
    case rounded
    case capsule
    case pill
}

/// Shape wrapper for styling
struct HIGButtonBackgroundShape: ViewModifier {
    let shape: HIGButtonShape
    func body(content: Content) -> some View {
        switch shape {
        case .rounded: content.clipShape(RoundedRectangle(cornerRadius: 10))
        case .capsule: content.clipShape(Capsule())
        case .pill: content.clipShape(RoundedRectangle(cornerRadius: 100))
        }
    }
}

extension View {
    func higButtonShape(_ shape: HIGButtonShape) -> some View { modifier(HIGButtonBackgroundShape(shape: shape)) }
}

/// Unified state for HIG buttons
enum HIGButtonState: Equatable {
    case idle
    case loading
    case disabled
    case success
    case error(String)
    case confirming // for destructive actions
}

@MainActor
@Observable
final class HIGButtonViewModel {
    var state: HIGButtonState = .idle
    var title: String
    var confirmTitle: String?
    var showsProgressWhileLoading: Bool = true
    
    init(title: String, state: HIGButtonState = .idle, confirmTitle: String? = nil) {
        self.title = title
        self.state = state
        self.confirmTitle = confirmTitle
    }
    
    func perform(_ action: @escaping () async throws -> Void) {
        guard case .disabled = state else {
            // proceed
            self.state = .loading
            Task {
                do {
                    try await action()
                    self.state = .success
                    // Return to idle after a short delay
                    try? await Task.sleep(for: .seconds(0.8))
                    if case .success = self.state { self.state = .idle }
                } catch {
                    self.state = .error(error.localizedDescription)
                }
            }
            return
        }
    }
}

// MARK: - HIG Button Styles

/// Primary action button following HIG guidelines
/// - Use for the main action in a view
/// - Limit to one per screen/context
struct HIGPrimaryButton: View {
    let title: String
    let action: () -> Void
    var config: HIGButtonStyleConfig = .init()

    var body: some View {
        Button(action: action) {
            labelContent
        }
        .buttonStyle(.borderedProminent)
        .controlSize(config.controlSize)
        .tint(config.tint ?? .accentColor)
        .higButtonShape(config.shape)
        .frame(maxWidth: HIGIsMac && config.fillsWidth ? 360 : nil)
        .frame(minHeight: HIGIsMac ? 32 : nil)
        .applyHelp(config.tooltip)
    }

    @ViewBuilder
    private var labelContent: some View {
        if config.fillsWidth {
            if let image = config.systemImage {
                Label(title, systemImage: image)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body.weight(.semibold) : nil)
            } else {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body.weight(.semibold) : nil)
            }
        } else {
            if let image = config.systemImage {
                Label(title, systemImage: image)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body.weight(.semibold) : nil)
            } else {
                Text(title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body.weight(.semibold) : nil)
            }
        }
    }
}

/// Secondary action button
/// - Use for alternative actions
/// - Should be visually less prominent than primary
struct HIGSecondaryButton: View {
    let title: String
    let action: () -> Void
    var config: HIGButtonStyleConfig = .init()

    var body: some View {
        Button(action: action) {
            labelContent
        }
        .buttonStyle(.bordered)
        .controlSize(config.controlSize)
        .tint(config.tint ?? .accentColor)
        .higButtonShape(config.shape)
        .frame(maxWidth: HIGIsMac && config.fillsWidth ? 360 : nil)
        .frame(minHeight: HIGIsMac ? 32 : nil)
        .applyHelp(config.tooltip)
    }

    @ViewBuilder
    private var labelContent: some View {
        if config.fillsWidth {
            if let image = config.systemImage {
                Label(title, systemImage: image)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body : nil)
            } else {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body : nil)
            }
        } else {
            if let image = config.systemImage {
                Label(title, systemImage: image)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body : nil)
            } else {
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body : nil)
            }
        }
    }
}

/// Destructive action button
/// - Use for delete, remove, or irreversible actions
/// - Always require confirmation for destructive actions
struct HIGDestructiveButton: View {
    let title: String
    let action: () -> Void
    var config: HIGButtonStyleConfig = .init()

    var body: some View {
        Button(role: .destructive, action: action) {
            labelContent
        }
        .buttonStyle(.bordered)
        .controlSize(config.controlSize)
        .tint(config.tint ?? .red)
        .higButtonShape(config.shape)
        .frame(maxWidth: HIGIsMac && config.fillsWidth ? 360 : nil)
        .frame(minHeight: HIGIsMac ? 32 : nil)
        .applyHelp(config.tooltip)
    }

    @ViewBuilder
    private var labelContent: some View {
        if config.fillsWidth {
            if let image = config.systemImage {
                Label(title, systemImage: image)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body : nil)
            } else {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body : nil)
            }
        } else {
            if let image = config.systemImage {
                Label(title, systemImage: image)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body : nil)
            } else {
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(HIGIsMac ? .body : nil)
            }
        }
    }
}

/// Icon button for toolbar/compact contexts
struct HIGIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let action: () -> Void
    var tooltip: String? = nil

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
        }
        .accessibilityLabel(accessibilityLabel)
        .frame(minWidth: HIGIsMac ? 32 : nil, minHeight: HIGIsMac ? 32 : nil)
        .help(tooltip ?? accessibilityLabel)
    }
}

private extension View {
    @ViewBuilder
    func applyHelp(_ tooltip: String?) -> some View {
        if let tip = tooltip {
            self.help(tip)
        } else {
            self
        }
    }
}

// MARK: - Button Group

/// Horizontal button group following HIG spacing
struct HIGButtonGroup<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 12) {
            content
        }
    }
}

// MARK: - Stateful Button Components

/// Primary action button with state management and async support
struct HIGPrimaryActionButton: View {
    @Bindable var viewModel: HIGButtonViewModel
    let action: () async throws -> Void
    var config: HIGButtonStyleConfig = .init()

    var body: some View {
        Button {
            viewModel.perform(action)
        } label: {
            label
                .frame(maxWidth: config.fillsWidth ? .infinity : nil)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(config.controlSize)
        .tint(config.tint ?? .accentColor)
        .higButtonShape(config.shape)
        .frame(maxWidth: HIGIsMac && config.fillsWidth ? 360 : nil)
        .frame(minHeight: HIGIsMac ? 32 : nil)
        .applyHelp(config.tooltip)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var label: some View {
        switch viewModel.state {
        case .loading:
            HStack {
                ProgressView().controlSize(.small)
                Text("\(viewModel.title)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        case .success:
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text(viewModel.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        case .error:
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text(viewModel.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        default:
            if let image = config.systemImage {
                Label(viewModel.title, systemImage: image)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            } else {
                Text(viewModel.title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        }
    }

    private var isDisabled: Bool {
        if case .disabled = viewModel.state { return true }
        if case .loading = viewModel.state { return true }
        return false
    }

    private var accessibilityLabel: String {
        switch viewModel.state {
        case .loading: return "\(viewModel.title), loading"
        case .success: return "\(viewModel.title), completed"
        case .error(let message): return "\(viewModel.title), error: \(message)"
        case .disabled: return "\(viewModel.title), disabled"
        case .confirming: return "\(viewModel.title), confirm"
        default: return viewModel.title
        }
    }
}

/// Secondary action button with state management
struct HIGSecondaryActionButton: View {
    @Bindable var viewModel: HIGButtonViewModel
    let action: () async throws -> Void
    var config: HIGButtonStyleConfig = .init()

    var body: some View {
        Button {
            viewModel.perform(action)
        } label: {
            label
                .frame(maxWidth: config.fillsWidth ? .infinity : nil)
        }
        .buttonStyle(.bordered)
        .controlSize(config.controlSize)
        .tint(config.tint ?? .accentColor)
        .higButtonShape(config.shape)
        .frame(maxWidth: HIGIsMac && config.fillsWidth ? 360 : nil)
        .frame(minHeight: HIGIsMac ? 32 : nil)
        .applyHelp(config.tooltip)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var label: some View {
        switch viewModel.state {
        case .loading:
            HStack {
                ProgressView().controlSize(.small)
                Text(viewModel.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        default:
            if let image = config.systemImage {
                Label(viewModel.title, systemImage: image)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            } else {
                Text(viewModel.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        }
    }

    private var isDisabled: Bool {
        if case .disabled = viewModel.state { return true }
        if case .loading = viewModel.state { return true }
        return false
    }

    private var accessibilityLabel: String {
        switch viewModel.state {
        case .loading: return "\(viewModel.title), loading"
        case .disabled: return "\(viewModel.title), disabled"
        default: return viewModel.title
        }
    }
}

/// Destructive action button with confirmation flow
struct HIGDestructiveActionButton: View {
    @Bindable var viewModel: HIGButtonViewModel
    let action: () async throws -> Void
    var config: HIGButtonStyleConfig = .init()

    var body: some View {
        Button(role: .destructive) {
            switch viewModel.state {
            case .confirming:
                viewModel.perform(action)
            default:
                viewModel.state = .confirming
            }
        } label: {
            label
                .frame(maxWidth: config.fillsWidth ? .infinity : nil)
        }
        .buttonStyle(.bordered)
        .controlSize(config.controlSize)
        .tint(config.tint ?? .red)
        .higButtonShape(config.shape)
        .frame(maxWidth: HIGIsMac && config.fillsWidth ? 360 : nil)
        .frame(minHeight: HIGIsMac ? 32 : nil)
        .applyHelp(config.tooltip)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel)
        .onChange(of: viewModel.state) { old, new in
            // Reset confirmation after a short timeout if not confirmed
            if case .confirming = new {
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    if case .confirming = viewModel.state { viewModel.state = .idle }
                }
            }
        }
    }

    @ViewBuilder
    private var label: some View {
        switch viewModel.state {
        case .loading:
            HStack {
                ProgressView().controlSize(.small)
                Text(viewModel.confirmTitle ?? viewModel.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        case .confirming:
            Text(viewModel.confirmTitle ?? "Confirm")
                .lineLimit(1)
                .minimumScaleFactor(0.9)
        default:
            if let image = config.systemImage {
                Label(viewModel.title, systemImage: image)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            } else {
                Text(viewModel.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        }
    }

    private var isDisabled: Bool {
        if case .disabled = viewModel.state { return true }
        if case .loading = viewModel.state { return true }
        return false
    }

    private var accessibilityLabel: String {
        switch viewModel.state {
        case .confirming: return (viewModel.confirmTitle ?? "Confirm") + ", destructive"
        case .loading: return (viewModel.confirmTitle ?? viewModel.title) + ", loading"
        case .disabled: return viewModel.title + ", disabled"
        default: return viewModel.title + ", destructive"
        }
    }
}

// MARK: - Preview

#Preview("HIG Buttons") {
    VStack(spacing: 20) {
        HIGPrimaryButton(title: "Continue") {}
        HIGSecondaryButton(title: "Cancel") {}
        HIGDestructiveButton(title: "Delete") {}

        HIGButtonGroup {
            HIGSecondaryButton(title: "Cancel") {}
            HIGPrimaryButton(title: "Save") {}
        }
    }
    .padding()
}

#Preview("HIG Buttons - Stateful") {
    struct Demo: View {
        @State var primaryVM = HIGButtonViewModel(title: "Continue")
        @State var secondaryVM = HIGButtonViewModel(title: "Cancel")
        @State var destructiveVM = HIGButtonViewModel(title: "Delete", confirmTitle: "Confirm Delete")
        
        var body: some View {
            VStack(spacing: 20) {
                HIGPrimaryActionButton(viewModel: primaryVM) {
                    try await Task.sleep(for: .seconds(1))
                }
                HIGSecondaryActionButton(viewModel: secondaryVM) {
                    try await Task.sleep(for: .seconds(0.6))
                }
                HIGDestructiveActionButton(viewModel: destructiveVM) {
                    try await Task.sleep(for: .seconds(0.8))
                }
                
                HStack {
                    Button("Disable Primary") { primaryVM.state = .disabled }
                    Button("Reset Primary") { primaryVM.state = .idle }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
    return Demo()
}

#Preview("HIG Buttons - Configurable") {
    @Previewable @State var vm = HIGButtonViewModel(title: "Upload")
    VStack(spacing: 16) {
        HIGPrimaryButton(title: "Continue", action: {})
            .overlay(EmptyView()) // preserve original
        HIGPrimaryButton(title: "Continue", action: {}, config: .init(systemImage: "arrow.right.circle.fill", tooltip: "Proceed to next step", tint: .accentColor, controlSize: .large, shape: .capsule, fillsWidth: true))
        HIGSecondaryButton(title: "Options", action: {}, config: .init(systemImage: "slider.horizontal.3", tooltip: "More options", tint: .blue, controlSize: .regular, shape: .rounded, fillsWidth: false))
        HIGDestructiveButton(title: "Delete", action: {}, config: .init(systemImage: "trash", tooltip: "Permanently delete", tint: .red, controlSize: .regular, shape: .pill))
        HIGIconButton(systemImage: "gear", accessibilityLabel: "Settings", action: {}, tooltip: "Open settings")
        HIGPrimaryActionButton(viewModel: vm, action: { try await Task.sleep(for: .seconds(1)) }, config: .init(systemImage: "square.and.arrow.up.fill", tooltip: "Upload file", tint: .purple, controlSize: .large, shape: .capsule))
    }
    .padding()
}

