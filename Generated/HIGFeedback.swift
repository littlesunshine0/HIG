//
//  HIGFeedback.swift
//  Generated from Apple Human Interface Guidelines
//
//  HIG-compliant feedback and status components
//
//  Generated: 2025-11-25
//

import SwiftUI

/// Unified feedback state for HIG components
enum HIGFeedbackState: Equatable {
    case idle
    case loading(message: String? = nil)
    case empty(systemImage: String, title: String, description: String, actionTitle: String? = nil)
    case error(message: String, retryTitle: String = "Try Again")
    case success(message: String, autoDismissAfter: TimeInterval = 2)
    case progress(value: Double, label: String? = nil)
}

@MainActor
@Observable
final class HIGFeedbackViewModel {
    var state: HIGFeedbackState = .idle
    var isBannerPresented: Bool = false
    var action: (() -> Void)? = nil
    
    init(state: HIGFeedbackState = .idle, action: (() -> Void)? = nil) {
        self.state = state
        self.action = action
    }
    
    func setAction(_ action: @escaping () -> Void) {
        self.action = action
    }
}

// MARK: - HIG Feedback Components

/// Loading indicator with optional message
struct HIGLoadingView: View {
    var message: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)

            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Empty state view following HIG patterns
struct HIGEmptyStateView: View {
    let systemImage: String
    let title: String
    let description: String
    var action: (() -> Void)? = nil
    var actionTitle: String = "Get Started"

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(description)
        } actions: {
            if let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

/// Error state view
struct HIGErrorView: View {
    let error: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error)
        } actions: {
            if let retryAction {
                Button("Try Again", action: retryAction)
                    .buttonStyle(.bordered)
            }
        }
    }
}

/// Success feedback (brief, non-blocking)
struct HIGSuccessBanner: View {
    let message: String
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(message)
                Spacer()
            }
            .padding()
            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
        }
    }
}

/// Progress indicator for determinate tasks
struct HIGProgressView: View {
    let progress: Double
    var label: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label {
                HStack {
                    Text(label)
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
        }
    }
}

/// Container that renders appropriate feedback UI based on state
struct HIGFeedbackContainer: View {
    @Bindable var viewModel: HIGFeedbackViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        content
            .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: viewModel.state)
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .loading(let message):
            HIGLoadingView(message: message)
        case .empty(let systemImage, let title, let description, let actionTitle):
            HIGEmptyStateView(
                systemImage: systemImage,
                title: title,
                description: description,
                action: viewModel.action,
                actionTitle: actionTitle ?? "Get Started"
            )
        case .error(let message, _):
            HIGErrorView(error: message, retryAction: viewModel.action)
                .accessibilityLabel("Error: \(message)")
        case .success(let message, let autoDismissAfter):
            HIGSuccessBanner(message: message, isPresented: $viewModel.isBannerPresented)
                .onAppear {
                    viewModel.isBannerPresented = true
                    // Auto-dismiss only when not reducing motion
                    guard autoDismissAfter > 0 else { return }
                    if !reduceMotion {
                        DispatchQueue.main.asyncAfter(deadline: .now() + autoDismissAfter) {
                            withAnimation {
                                viewModel.isBannerPresented = false
                                viewModel.state = .idle
                            }
                        }
                    }
                }
        case .progress(let value, let label):
            HIGProgressView(progress: value, label: label)
                .accessibilityValue("\(Int(value * 100)) percent")
        }
    }
}

// MARK: - Preview

#Preview("HIG Feedback") {
    VStack(spacing: 40) {
        HIGLoadingView(message: "Loading...")

        HIGEmptyStateView(
            systemImage: "doc",
            title: "No Documents",
            description: "Create a document to get started"
        ) {}

        HIGProgressView(progress: 0.65, label: "Uploading")
    }
    .padding()
}

#Preview("HIG Feedback Container States") {
    @State var vm = HIGFeedbackViewModel()
    return VStack(spacing: 20) {
        HStack {
            Button("Loading") { vm.state = .loading(message: "Fetching data…") }
            Button("Empty") {
                vm.setAction { print("Get Started tapped") }
                vm.state = .empty(systemImage: "doc", title: "No Documents", description: "Create a document to get started")
            }
            Button("Error") {
                vm.setAction { print("Retry tapped") }
                vm.state = .error(message: "Network error. Please try again.")
            }
            Button("Success") { vm.state = .success(message: "Saved successfully.") }
            Button("Progress") { vm.state = .progress(value: 0.42, label: "Uploading") }
        }
        .buttonStyle(.bordered)
        
        HIGFeedbackContainer(viewModel: vm)
            .frame(maxWidth: 420)
            .padding()
            .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}
