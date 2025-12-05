//
//  HIGApp.swift
//  HIG
//
//  Main app entry point with state management
//  100% HIG-Compliant with Liquid Glass Design
//
//  HIG Topics Implemented:
//  [launching] - App launch experience
//  [windows] - Custom window configuration
//  [onboarding] - First-run experience flow
//  [accessibility] - VoiceOver support
//

import SwiftUI

// MARK: - Notification Names

extension Notification.Name {
    static let focusSearch = Notification.Name("focusSearch")
}

// MARK: - App State

/// Represents the current state of the application
/// Used to manage transitions between splash, onboarding, and main app
enum AppState: Equatable {
    /// Initial launch state - showing splash screen
    case launching
    /// First-run onboarding experience
    case onboarding
    /// Main app ready for use
    case ready
}

// MARK: - App Entry Point

@main
struct HIGApp: App {
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 520, height: 620)
        .commands {
            // Remove default commands that conflict with custom chrome
            CommandGroup(replacing: .newItem) { }
            
            // Add About command
            CommandGroup(replacing: .appInfo) {
                Button("About DocuChat") {
                    openWindow(id: "about")
                }
            }
            
            // Add Settings command
            CommandGroup(after: .appInfo) {
                Button("Settings...") {
                    openWindow(id: "settings")
                }
                .keyboardShortcut(",", modifiers: .command)
                
                Divider()
                
                Button("Documentation Sources...") {
                    openWindow(id: "sources")
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
            }
            
            // View commands
            CommandGroup(after: .sidebar) {
                Button("Toggle Sidebar") {
                    // This will be handled by the NavigationSplitView
                }
                .keyboardShortcut("s", modifiers: [.command, .control])
                
                Divider()
                
                Button("Focus Search") {
                    // Post notification to focus search field
                    NotificationCenter.default.post(name: .focusSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
            }
            
            // Window commands
            CommandGroup(after: .windowArrangement) {
                Button("Minimize") {
                    #if canImport(AppKit)
                    NSApplication.shared.keyWindow?.miniaturize(nil)
                    #endif
                }
                .keyboardShortcut("m", modifiers: .command)
                
                Button("Zoom") {
                    #if canImport(AppKit)
                    NSApplication.shared.keyWindow?.zoom(nil)
                    #endif
                }
            }
        }
        
        // About window
        Window("About DocuChat", id: "about") {
            AboutView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 600)
        
        // Settings window
        Window("Settings", id: "settings") {
            SettingsView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 700)
        
        // Documentation Sources window
        Window("Documentation Sources", id: "sources") {
            DocumentSourcesView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 700, height: 600)
    }
}

// MARK: - Root View

/// Root view that manages app state transitions
/// Switches between SplashView, OnboardingView, and MainView based on AppState
struct RootView: View {
    
    // MARK: - State
    
    @State private var appState: AppState = .launching
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Body
    
    var body: some View {
        Group {
            switch appState {
            case .launching:
                SplashView()
                    .transition(.opacity)
                
            case .onboarding:
                OnboardingView(
                    isComplete: $hasCompletedOnboarding,
                    onSkip: {
                        // Skip button: transition to main app without marking onboarding as complete
                        transitionToReady()
                    }
                )
                .transition(.opacity)
                .onChange(of: hasCompletedOnboarding) { _, newValue in
                    if newValue {
                        transitionToReady()
                    }
                }
                
            case .ready:
                HIGBrowserView()
                    .transition(.opacity)
                    .frame(minWidth: 900, minHeight: 600)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .animation(
            AccessibleAnimation.transition(reduceMotion: reduceMotion),
            value: appState
        )
        #if canImport(AppKit)
        .customWindowChrome()
        #endif
        .onReceive(NotificationCenter.default.publisher(for: .splashComplete)) { _ in
            handleSplashComplete()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
    }
    
    // MARK: - State Transitions
    
    /// Handles the splash screen completion notification
    private func handleSplashComplete() {
        if hasCompletedOnboarding {
            transitionToReady()
        } else {
            transitionToOnboarding()
        }
    }
    
    /// Transitions to the onboarding state
    private func transitionToOnboarding() {
        withAnimation(AccessibleAnimation.transition(reduceMotion: reduceMotion)) {
            appState = .onboarding
        }
    }
    
    /// Transitions to the ready (main app) state
    private func transitionToReady() {
        withAnimation(AccessibleAnimation.transition(reduceMotion: reduceMotion)) {
            appState = .ready
        }
    }
    
    // MARK: - Accessibility
    
    private var accessibilityLabel: String {
        switch appState {
        case .launching:
            return "DocuChat is loading"
        case .onboarding:
            return "DocuChat onboarding"
        case .ready:
            return "DocuChat main application"
        }
    }
}

// MARK: - Preview

#Preview("Root View - Launching") {
    RootView()
}
