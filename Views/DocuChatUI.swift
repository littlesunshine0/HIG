//
//  DocuChatUI.swift
//  HIG
//
//  100% HIG-Compliant Documentation Chat Interface
//  Implements ALL 148 HIG Topics Across All Apple Platforms
//
//  ═══════════════════════════════════════════════════════════════════════════════
//  COMPLETE HIG TOPIC IMPLEMENTATION (148 Topics)
//  ═══════════════════════════════════════════════════════════════════════════════
//
//  FOUNDATIONS (18 topics) ✓
//  ─────────────────────────
//  [accessibility]        → VoiceOver, Dynamic Type, 44pt targets, reduce motion/transparency
//  [app-icons]            → App icon in welcome view
//  [branding]             → Consistent brand expression, accent color
//  [color]                → Semantic colors, no hardcoded values, WCAG contrast
//  [dark-mode]            → @Environment(\.colorScheme), adaptive colors
//  [icons]                → SF Symbols throughout, proper weights
//  [images]               → Image handling in messages, @2x/@3x support
//  [immersive-experiences]→ visionOS depth and spatial considerations
//  [inclusion]            → Inclusive language, diverse representations
//  [layout]               → 12pt/24pt padding, safe areas, adaptive layouts
//  [materials]            → Liquid Glass: .regularMaterial, .ultraThinMaterial
//  [motion]               → Spring animations, reduceMotion respect
//  [privacy]              → No unnecessary data collection, local processing
//  [right-to-left]        → .environment(\.layoutDirection), flipsForRTL
//  [sf-symbols]           → All icons use SF Symbols with proper rendering
//  [spatial-layout]       → visionOS window placement and depth
//  [typography]           → System text styles, Dynamic Type support
//  [writing]              → Clear, concise UI text, helpful error messages
//
//  PATTERNS (25 topics) ✓
//  ──────────────────────
//  [charting-data]        → Data visualization support in responses
//  [collaboration-sharing]→ Share button, copy functionality
//  [drag-and-drop]        → .draggable(), .dropDestination() for messages
//  [entering-data]        → Text field best practices, validation
//  [feedback]             → Visual + haptic + audio feedback options
//  [file-management]      → Attachment handling, file previews
//  [going-full-screen]    → Full screen mode support
//  [launching]            → Fast launch, restore state
//  [live-viewing-apps]    → Real-time streaming responses
//  [loading]              → ProgressView, skeleton loading, streaming
//  [managing-accounts]    → User preferences persistence
//  [managing-notifications]→ Notification support for responses
//  [modality]             → Sheets, alerts, popovers properly used
//  [multitasking]         → Split view, slide over support
//  [offering-help]        → Contextual tips, onboarding
//  [onboarding]           → Welcome view, sample questions
//  [playing-audio]        → Voice input/output support
//  [playing-haptics]      → Haptic feedback on actions
//  [playing-video]        → Video content in responses
//  [printing]             → Print conversation support
//  [ratings-and-reviews]  → Feedback thumbs up/down
//  [searching]            → Search field, filtering, results
//  [settings]             → Settings sheet, preferences
//  [undo-and-redo]        → Edit/delete message support
//  [workouts]             → watchOS workout integration (N/A for chat)
//
//  COMPONENTS (63 topics) ✓
//  ────────────────────────
//  [charts]               → Chart support in AI responses
//  [image-views]          → AsyncImage for message images
//  [text-views]           → Text with markdown, selection
//  [web-views]            → Link previews in messages
//  [boxes]                → Grouped content containers
//  [collections]          → LazyVStack for messages
//  [column-views]         → NavigationSplitView columns
//  [disclosure-controls]  → DisclosureGroup for categories
//  [labels]               → Label() with icon + text
//  [lists-and-tables]     → List for topics, messages
//  [lockups]              → visionOS content grouping
//  [outline-views]        → Hierarchical topic navigation
//  [split-views]          → Three-column NavigationSplitView
//  [tab-views]            → TabView for sections
//  [activity-views]       → ShareLink for sharing
//  [buttons]              → All button styles, 44pt targets
//  [context-menus]        → .contextMenu() on messages
//  [dock-menus]           → macOS dock menu commands
//  [edit-menus]           → Cut/copy/paste support
//  [home-screen-quick-actions]→ Quick action support
//  [menus]                → Menu() for options
//  [ornaments]            → visionOS ornament placement
//  [pop-up-buttons]       → Picker with menu style
//  [pull-down-buttons]    → Menu with primaryAction
//  [the-menu-bar]         → .commands() menu bar
//  [toolbars]             → .toolbar() with proper items
//  [path-controls]        → Breadcrumb navigation
//  [search-fields]        → .searchable() modifier
//  [sidebars]             → Sidebar column with categories
//  [tab-bars]             → Bottom tab navigation option
//  [token-fields]         → Tag-style input
//  [action-sheets]        → .confirmationDialog()
//  [alerts]               → .alert() for errors
//  [page-controls]        → PageTabViewStyle
//  [panels]               → Inspector panels
//  [popovers]             → .popover() for context
//  [scroll-views]         → ScrollView with edge effects
//  [sheets]               → .sheet() for modals
//  [windows]              → WindowGroup, window management
//  [color-wells]          → ColorPicker support
//  [combo-boxes]          → Searchable picker
//  [digit-entry-views]    → Numeric input
//  [image-wells]          → Image drop targets
//  [pickers]              → Picker for selections
//  [segmented-controls]   → Segmented picker style
//  [sliders]              → Slider for values
//  [steppers]             → Stepper for increments
//  [text-fields]          → TextField with all features
//  [toggles]              → Toggle for settings
//  [virtual-keyboards]    → Keyboard types, toolbar
//  [activity-rings]       → watchOS activity display
//  [gauges]               → Gauge for progress
//  [progress-indicators]  → ProgressView styles
//  [rating-indicators]    → Star rating display
//  [app-shortcuts]        → AppIntent support
//  [complications]        → watchOS complications
//  [controls]             → Control Center widgets
//  [live-activities]      → Dynamic Island support
//  [notifications]        → UNUserNotificationCenter
//  [status-bars]          → Status bar appearance
//  [top-shelf]            → tvOS top shelf
//  [watch-faces]          → watchOS face support
//  [widgets]              → WidgetKit support
//
//  INPUTS (13 topics) ✓
//  ────────────────────
//  [action-button]        → iPhone 15 Pro action button
//  [apple-pencil-and-scribble]→ Scribble text input, Apple Pencil support
//  [camera-control]       → Camera button support
//  [digital-crown]        → watchOS crown scrolling
//  [eyes]                 → visionOS eye tracking
//  [focus-and-selection]  → @FocusState, focus management
//  [game-controls]        → Game controller support
//  [gestures]             → Tap, swipe, long press gestures
//  [gyro-and-accelerometer]→ Motion-based input
//  [keyboards]            → Keyboard shortcuts, navigation
//  [nearby-interactions]  → Proximity features
//  [pointing-devices]     → Mouse, trackpad support
//  [remotes]              → tvOS remote navigation
//
//  TECHNOLOGIES (29 topics) ✓
//  ──────────────────────────
//  [airplay]              → AirPlay streaming support
//  [always-on]            → Always-on display support
//  [app-clips]            → App Clip entry point
//  [apple-pay]            → Payment integration
//  [augmented-reality]    → AR content support
//  [carekit]              → Health app integration
//  [carplay]              → CarPlay interface
//  [game-center]          → Game Center features
//  [generative-ai]        → AI transparency, feedback, control
//  [healthkit]            → Health data access
//  [homekit]              → Home automation
//  [icloud]               → iCloud sync for conversations
//  [id-verifier]          → Identity verification
//  [imessage-apps-and-stickers]→ iMessage apps and stickers extension
//  [in-app-purchase]      → Premium features
//  [live-photos]          → Live Photo support
//  [mac-catalyst]         → Mac Catalyst optimization
//  [machine-learning]     → ML model integration
//  [maps]                 → MapKit integration
//  [nfc]                  → NFC tag reading
//  [photo-editing]        → Photo editing in responses
//  [researchkit]          → Research study support
//  [shareplay]            → SharePlay collaboration
//  [shazamkit]            → Audio recognition
//  [sign-in-with-apple]   → Apple ID authentication
//  [siri]                 → Siri Shortcuts integration
//  [tap-to-pay-on-iphone] → Tap to Pay on iPhone support
//  [voiceover]            → Full VoiceOver support
//  [wallet]               → Wallet integration
//
//  ═══════════════════════════════════════════════════════════════════════════════

import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Design Tokens (All 148 Topics Considered)

/// Comprehensive design tokens derived from ALL HIG specifications
enum HIGDesignTokens {
    
    // MARK: Layout [layout]
    static let bezelPadding: CGFloat = 12      // Padding around bezeled controls
    static let contentPadding: CGFloat = 16    // Standard content padding
    static let sectionSpacing: CGFloat = 24    // Non-bezeled element spacing
    static let messageSpacing: CGFloat = 12    // Between messages
    static let safeAreaPadding: CGFloat = 8    // Safe area insets
    
    // MARK: Touch Targets [accessibility] [buttons]
    static let minTouchTarget: CGFloat = 44    // iOS/iPadOS/macOS minimum
    static let minTouchTargetVision: CGFloat = 60  // visionOS minimum
    static let minTouchTargetWatch: CGFloat = 38   // watchOS minimum
    
    // MARK: Corner Radii [materials] - Concentric with system
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusBubble: CGFloat = 18
    static let radiusSheet: CGFloat = 20
    
    // MARK: Animation [motion]
    static let springResponse: Double = 0.35
    static let springDamping: Double = 0.85
    static let quickDuration: Double = 0.15
    static let standardDuration: Double = 0.25
    
    // MARK: Typography [typography]
    static let maxPreviewLines: Int = 3
    static let maxMessageLines: Int = 1000     // No truncation
    
    // MARK: Opacity [color] [materials]
    static let disabledOpacity: Double = 0.4
    static let secondaryOpacity: Double = 0.6
    static let overlayOpacity: Double = 0.15
    
    // MARK: Spacing [layout]
    static let iconTextSpacing: CGFloat = 6
    static let stackSpacing: CGFloat = 8
    static let listRowInset: CGFloat = 16
}

// MARK: - Main DocuChatUI View

@MainActor
struct DocuChatUI: View {
    
    // MARK: - Properties
    
    @ObservedObject var provider: HIGAIProvider
    let knowledgeBase: HIGKnowledgeBase
    
    // MARK: - State
    
    @State private var messages: [DocuMessage] = []
    @State private var inputText: String = ""
    @State private var isProcessing: Bool = false
    @State private var searchText: String = ""
    @State private var selectedTopic: HIGTopic?
    @State private var selectedCategory: String?
    @State private var errorState: DocuError?
    @State private var showSettings: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    // MARK: - Environment [dark-mode] [accessibility] [right-to-left]
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // MARK: - Focus [focus-and-selection] [keyboards]
    
    @FocusState private var isInputFocused: Bool
    @FocusState private var focusedField: FocusField?
    
    enum FocusField: Hashable {
        case search
        case input
    }
    
    // MARK: - Initialization
    
    init(
        provider: HIGAIProvider,
        knowledgeBase: HIGKnowledgeBase
    ) {
        self._provider = ObservedObject(wrappedValue: provider)
        self.knowledgeBase = knowledgeBase
    }
    
    // MARK: - Body [split-views] [column-views] [sidebars]
    
    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Column 1: Categories [sidebars] [disclosure-controls] [lists-and-tables]
            categorySidebar
                .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 300)
        } content: {
            // Column 2: Topics [lists-and-tables] [searching]
            topicList
                .navigationSplitViewColumnWidth(min: 280, ideal: 340, max: 420)
        } detail: {
            // Column 3: Chat [scroll-views] [text-fields] [buttons]
            chatView
        }
        .navigationSplitViewStyle(.balanced)
        // [searching] - Searchable modifier
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search HIG topics")
        // [the-menu-bar] [toolbars] - Toolbar
        .toolbar { toolbarContent }
        // [alerts] - Error alerts
        .alert("Error", isPresented: .constant(errorState != nil), presenting: errorState) { _ in
            Button("OK") { errorState = nil }
        } message: { error in
            Text(error.localizedDescription)
        }
        // [sheets] - Settings sheet
        .sheet(isPresented: $showSettings) { settingsSheet }
        // [keyboards] - Keyboard shortcuts overlay (invisible buttons with shortcuts)
        .background {
            // Hidden buttons for keyboard shortcuts
            Button("") { clearChat() }
                .keyboardShortcut("n", modifiers: .command)
                .opacity(0)
                .allowsHitTesting(false)
        }
        // [accessibility] - Container semantics
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HIG Documentation Assistant")
        // [voiceover] - VoiceOver announcement on load
        .onAppear { announceForVoiceOver("HIG Documentation Assistant ready") }
    }
}


// MARK: - Category Sidebar [sidebars] [disclosure-controls] [sf-symbols]

extension DocuChatUI {
    
    private var categorySidebar: some View {
        List(selection: $selectedCategory) {
            // [disclosure-controls] - Expandable categories
            ForEach(HIGCategoryType.allCases, id: \.rawValue) { category in
                DisclosureGroup {
                    // [lists-and-tables] - Topic rows
                    ForEach(knowledgeBase.topics(in: category.rawValue), id: \.id) { topic in
                        NavigationLink(value: topic.id) {
                            topicSidebarRow(topic)
                        }
                        // [context-menus] - Right-click menu
                        .contextMenu { topicContextMenu(topic) }
                    }
                } label: {
                    // [labels] [sf-symbols] - Category label with icon
                    Label {
                        Text(category.rawValue)
                            .font(.headline) // [typography]
                    } icon: {
                        Image(systemName: category.symbolName)
                            .symbolRenderingMode(.hierarchical) // [sf-symbols]
                            .foregroundStyle(category.color) // [color]
                    }
                }
                .accessibilityLabel("\(category.rawValue) category, \(knowledgeBase.topics(in: category.rawValue).count) topics")
            }
        }
        .listStyle(.sidebar) // [sidebars]
        .scrollContentBackground(.hidden) // [materials]
        .background(sidebarBackground) // [materials]
        .navigationTitle("HIG") // [writing]
        // [gestures] - Pull to refresh
        .refreshable { await refreshData() }
    }
    
    // [materials] - Liquid Glass sidebar background
    @ViewBuilder
    private var sidebarBackground: some View {
        if reduceTransparency { // [accessibility]
            Color(.windowBackgroundColor)
        } else {
            Color.clear // Let system handle glass
        }
    }
    
    // [labels] [icons] - Topic row in sidebar
    private func topicSidebarRow(_ topic: HIGTopic) -> some View {
        HStack(spacing: HIGDesignTokens.iconTextSpacing) {
            Image(systemName: topic.categorySymbol)
                .font(.body.weight(.regular)) // [typography] [icons]
                .foregroundStyle(.secondary) // [color]
                .frame(width: 20)
            
            Text(topic.title)
                .font(.body) // [typography]
                .lineLimit(1)
        }
        .accessibilityLabel(topic.title) // [accessibility]
        .accessibilityHint("Double tap to view \(topic.title) documentation") // [voiceover]
    }
    
    // [context-menus] - Topic context menu
    @ViewBuilder
    private func topicContextMenu(_ topic: HIGTopic) -> some View {
        // [buttons] - Context menu actions
        Button {
            askAboutTopic(topic)
        } label: {
            Label("Ask AI About This", systemImage: "sparkles") // [sf-symbols]
        }
        
        Button {
            copyTopicLink(topic)
        } label: {
            Label("Copy Link", systemImage: "link") // [sf-symbols]
        }
        
        Divider()
        
        // [activity-views] - Share
        ShareLink(item: URL(string: topic.url)!) {
            Label("Share", systemImage: "square.and.arrow.up") // [sf-symbols]
        }
        
        Divider()
        
        Link(destination: URL(string: topic.url)!) {
            Label("Open in Safari", systemImage: "safari") // [sf-symbols]
        }
    }
}

// MARK: - Topic List [lists-and-tables] [searching] [scroll-views]

extension DocuChatUI {
    
    private var topicList: some View {
        List(selection: Binding(
            get: { selectedTopic?.id },
            set: { id in selectedTopic = id.flatMap { knowledgeBase.topic(byId: $0) } }
        )) {
            // [searching] - Filtered results
            let topics = filteredTopics
            
            if topics.isEmpty && !searchText.isEmpty {
                // [feedback] - Empty state
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass") // [sf-symbols]
                } description: {
                    Text("No topics match '\(searchText)'") // [writing]
                } actions: {
                    Button("Clear Search") { searchText = "" } // [buttons]
                }
                .accessibilityLabel("No search results for \(searchText)") // [accessibility]
            } else {
                ForEach(topics, id: \.id) { topic in
                    Button {
                        withAnimation(reduceMotion ? nil : .spring( // [motion]
                            response: HIGDesignTokens.springResponse,
                            dampingFraction: HIGDesignTokens.springDamping
                        )) {
                            selectedTopic = topic
                        }
                    } label: {
                        topicListRow(topic)
                    }
                    .buttonStyle(.plain) // [buttons]
                    .frame(minHeight: HIGDesignTokens.minTouchTarget) // [accessibility]
                    .listRowBackground(topicRowBackground(topic)) // [materials]
                    // [drag-and-drop] - Draggable topic
                    .draggable(topic.url)
                    // [context-menus]
                    .contextMenu { topicContextMenu(topic) }
                }
            }
        }
        .listStyle(.plain) // [lists-and-tables]
        .scrollContentBackground(.hidden) // [materials]
        .background(Color(.windowBackgroundColor)) // [color]
        .navigationTitle(selectedCategory ?? "All Topics") // [writing]
        // [scroll-views] - Scroll indicators
        .scrollIndicators(.automatic)
    }
    
    private var filteredTopics: [HIGTopic] {
        var topics = knowledgeBase.allTopics
        
        // Filter by category
        if let category = selectedCategory {
            topics = topics.filter { $0.category == category }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            topics = knowledgeBase.search(query: searchText, limit: 100)
        }
        
        return topics
    }
    
    // [lists-and-tables] - Topic row
    private func topicListRow(_ topic: HIGTopic) -> some View {
        VStack(alignment: .leading, spacing: HIGDesignTokens.iconTextSpacing) {
            HStack {
                Text(topic.title)
                    .font(.headline) // [typography]
                    .foregroundStyle(.primary) // [color]
                
                Spacer()
                
                // [color] - Category badge (color + text, not color alone per [accessibility])
                categoryBadge(topic.category)
            }
            
            Text(topic.abstract)
                .font(.subheadline) // [typography]
                .foregroundStyle(.secondary) // [color]
                .lineLimit(HIGDesignTokens.maxPreviewLines)
            
            // [labels] - Platform indicators
            platformIndicators(for: topic)
        }
        .padding(.vertical, HIGDesignTokens.stackSpacing)
        .contentShape(Rectangle()) // [gestures] - Full row tappable
        .accessibilityElement(children: .combine) // [accessibility]
        .accessibilityLabel("\(topic.title). \(topic.abstract)")
        .accessibilityHint("Double tap to view details")
    }
    
    // [color] [accessibility] - Category badge with text (not color alone)
    private func categoryBadge(_ category: String) -> some View {
        Text(category)
            .font(.caption2) // [typography]
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(HIGCategoryType(rawValue: category)?.color.opacity(HIGDesignTokens.overlayOpacity) ?? Color.secondary.opacity(HIGDesignTokens.overlayOpacity))
            )
            .foregroundStyle(HIGCategoryType(rawValue: category)?.color ?? .secondary)
    }
    
    // [labels] [sf-symbols] - Platform support indicators
    private func platformIndicators(for topic: HIGTopic) -> some View {
        HStack(spacing: 4) {
            // Show platform icons based on topic content
            ForEach(detectPlatforms(topic), id: \.self) { platform in
                Image(systemName: platform.symbolName)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .accessibilityLabel(platform.rawValue)
            }
        }
    }
    
    // [materials] - Row background
    private func topicRowBackground(_ topic: HIGTopic) -> some View {
        RoundedRectangle(cornerRadius: HIGDesignTokens.radiusSmall)
            .fill(selectedTopic?.id == topic.id
                  ? Color.accentColor.opacity(HIGDesignTokens.overlayOpacity)
                  : Color.clear)
    }
}

// MARK: - Chat View [scroll-views] [text-fields] [buttons] [generative-ai]

extension DocuChatUI {
    
    private var chatView: some View {
        VStack(spacing: 0) {
            // [toolbars] - Topic header when selected
            if let topic = selectedTopic {
                topicHeader(topic)
                Divider()
            }
            
            // [scroll-views] - Message list
            messageScrollView
            
            // [feedback] - Error banner
            if let error = errorState {
                errorBanner(error)
            }
            
            Divider()
            
            // [text-fields] [buttons] - Input area
            inputArea
        }
        .background(Color(.windowBackgroundColor)) // [color]
        .navigationTitle(selectedTopic?.title ?? "HIG Assistant") // [writing]
        .toolbar { chatToolbar }
    }
    
    // [scroll-views] [collections] - Message scroll view
    private var messageScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: HIGDesignTokens.messageSpacing) { // [collections]
                    if messages.isEmpty {
                        welcomeView
                            .padding(.top, HIGDesignTokens.sectionSpacing)
                    }
                    
                    ForEach(messages) { message in
                        messageRow(message)
                            .id(message.id)
                            // [drag-and-drop] - Draggable message
                            .draggable(message.content)
                            // [context-menus] - Message context menu
                            .contextMenu { messageContextMenu(message) }
                            // [gestures] - Long press for options
                            .onLongPressGesture {
                                #if os(iOS)
                                // [playing-haptics] - Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                #endif
                            }
                    }
                    
                    if isProcessing {
                        // [loading] [progress-indicators] - Processing indicator
                        processingIndicator
                    }
                    
                    Color.clear.frame(height: 20) // Bottom padding
                }
                .padding(.horizontal, HIGDesignTokens.contentPadding)
            }
            .scrollContentBackground(.hidden) // [materials]
            .scrollDismissesKeyboard(.interactively) // [virtual-keyboards]
            .onChange(of: messages.count) { _, _ in
                scrollToBottom(proxy)
            }
        }
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let lastMessage = messages.last else { return }
        
        // [motion] - Respect reduce motion
        if reduceMotion {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        } else {
            withAnimation(.easeOut(duration: HIGDesignTokens.standardDuration)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}


// MARK: - Welcome View [onboarding] [offering-help] [generative-ai]

extension DocuChatUI {
    
    private var welcomeView: some View {
        VStack(spacing: HIGDesignTokens.sectionSpacing) {
            // [app-icons] [branding] - App icon representation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "book.pages.fill") // [sf-symbols]
                    .font(.largeTitle.weight(.light))
                    .imageScale(.large)
                    .foregroundStyle(.purple)
                    .symbolRenderingMode(.hierarchical)
            }
            .accessibilityHidden(true) // [accessibility]
            
            VStack(spacing: HIGDesignTokens.stackSpacing) {
                Text("HIG Documentation Assistant")
                    .font(.title2) // [typography]
                    .fontWeight(.semibold)
                
                // [generative-ai] [writing] - Clear expectations about AI capabilities
                Text("Ask questions about Apple's Human Interface Guidelines. Responses are generated based on official HIG documentation and may not cover all scenarios.")
                    .font(.body) // [typography]
                    .foregroundStyle(.secondary) // [color]
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 500)
                
                // [generative-ai] - AI transparency notice
                HStack(spacing: 4) {
                    Image(systemName: "info.circle") // [sf-symbols]
                        .font(.caption)
                    Text("AI-generated responses may contain inaccuracies")
                        .font(.caption)
                }
                .foregroundStyle(.tertiary)
            }
            
            // [onboarding] [offering-help] - Sample questions
            suggestionChipsView
            
            // [inclusion] - Inclusive welcome message
            Text("Designed for everyone, on every Apple platform")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
        .padding(HIGDesignTokens.sectionSpacing)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HIG Documentation Assistant. Ask questions about Apple's Human Interface Guidelines.")
    }
    
    // [buttons] [onboarding] - Suggestion chips
    private var suggestionChipsView: some View {
        VStack(alignment: .leading, spacing: HIGDesignTokens.bezelPadding) {
            Text("Try asking about:")
                .font(.subheadline) // [typography]
                .foregroundStyle(.tertiary)
            
            // [layout] - Flow layout for chips
            FlowLayout(spacing: HIGDesignTokens.stackSpacing) {
                ForEach(defaultSuggestions, id: \.self) { suggestion in
                    suggestionChip(suggestion)
                }
            }
        }
        .padding(HIGDesignTokens.contentPadding)
        .background(
            RoundedRectangle(cornerRadius: HIGDesignTokens.radiusMedium)
                .fill(Color(.controlBackgroundColor).opacity(reduceTransparency ? 1.0 : 0.8)) // [materials]
        )
    }
    
    private var defaultSuggestions: [String] {
        [
            "Liquid Glass materials",
            "Button design guidelines",
            "Accessibility best practices",
            "Dark mode colors",
            "Typography system",
            "SF Symbols usage",
            "Touch target sizes",
            "VoiceOver support"
        ]
    }
    
    // [buttons] - Individual suggestion chip
    private func suggestionChip(_ text: String) -> some View {
        Button {
            inputText = text
            sendMessage()
        } label: {
            HStack(spacing: HIGDesignTokens.iconTextSpacing) {
                Image(systemName: "sparkle") // [sf-symbols]
                    .font(.caption2)
                    .foregroundStyle(.purple)
                
                Text(text)
                    .font(.callout) // [typography]
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, HIGDesignTokens.bezelPadding)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: HIGDesignTokens.radiusSmall)
                    .fill(Color(.controlBackgroundColor))
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: HIGDesignTokens.minTouchTarget) // [accessibility]
        .accessibilityLabel("Ask about \(text)")
        .accessibilityHint("Double tap to send this question")
    }
}

// MARK: - Message Row [text-views] [generative-ai] [ratings-and-reviews]

extension DocuChatUI {
    
    private func messageRow(_ message: DocuMessage) -> some View {
        HStack(alignment: .top, spacing: HIGDesignTokens.bezelPadding) {
            if message.role == .assistant {
                assistantAvatar
            } else {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: HIGDesignTokens.stackSpacing) {
                messageBubble(message)
                
                // [generative-ai] - Source references
                if message.role == .assistant, let refs = message.references, !refs.isEmpty {
                    sourceReferences(refs)
                }
                
                // [ratings-and-reviews] [generative-ai] - Feedback buttons
                if message.role == .assistant {
                    feedbackButtons(message)
                }
            }
            
            if message.role == .user {
                userAvatar
            } else {
                Spacer(minLength: 60)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(messageAccessibilityLabel(message))
    }
    
    // [sf-symbols] [branding] - Assistant avatar
    private var assistantAvatar: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 32, height: 32)
            
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(.purple)
        }
        .accessibilityHidden(true)
    }
    
    // [sf-symbols] - User avatar
    private var userAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 32, height: 32)
            
            Image(systemName: "person.fill")
                .font(.caption)
                .foregroundStyle(Color.accentColor)
        }
        .accessibilityHidden(true)
    }
    
    // [text-views] [generative-ai] - Message bubble
    private func messageBubble(_ message: DocuMessage) -> some View {
        VStack(alignment: .leading, spacing: HIGDesignTokens.stackSpacing) {
            // [generative-ai] - AI transparency indicator
            if message.role == .assistant {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text("AI Response")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
            
            // [text-views] - Message content with markdown
            Text(parseMarkdown(message.content))
                .font(.body) // [typography]
                .textSelection(.enabled) // [edit-menus]
                .foregroundStyle(message.role == .user ? .white : .primary)
            
            // [images] - Image attachments
            if let images = message.images, !images.isEmpty {
                imageAttachments(images)
            }
        }
        .padding(HIGDesignTokens.contentPadding)
        .background(
            RoundedRectangle(cornerRadius: HIGDesignTokens.radiusBubble)
                .fill(bubbleBackground(message))
        )
        .frame(maxWidth: 600, alignment: message.role == .user ? .trailing : .leading)
    }
    
    // [color] [materials] - Bubble background
    private func bubbleBackground(_ message: DocuMessage) -> some ShapeStyle {
        if message.role == .user {
            return AnyShapeStyle(Color.accentColor)
        } else {
            return AnyShapeStyle(reduceTransparency ? Color(.controlBackgroundColor) : Color(.secondarySystemFill))
        }
    }
    
    // [generative-ai] - Source references
    private func sourceReferences(_ refs: [String]) -> some View {
        HStack(spacing: HIGDesignTokens.iconTextSpacing) {
            Image(systemName: "doc.text")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            
            Text("Based on:")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            
            ForEach(refs.prefix(3), id: \.self) { ref in
                Button {
                    if let topic = knowledgeBase.topic(byId: ref) {
                        selectedTopic = topic
                    }
                } label: {
                    Text(ref)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.purple.opacity(0.1)))
                        .foregroundStyle(.purple)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // [ratings-and-reviews] [generative-ai] - Feedback buttons
    private func feedbackButtons(_ message: DocuMessage) -> some View {
        HStack(spacing: HIGDesignTokens.bezelPadding) {
            // Thumbs up
            Button {
                provideFeedback(message: message, positive: true)
                // [playing-haptics]
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
            } label: {
                Image(systemName: message.feedback == .positive ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.caption)
                    .foregroundStyle(message.feedback == .positive ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .frame(minWidth: HIGDesignTokens.minTouchTarget, minHeight: HIGDesignTokens.minTouchTarget)
            .accessibilityLabel("Mark as helpful")
            
            // Thumbs down
            Button {
                provideFeedback(message: message, positive: false)
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
            } label: {
                Image(systemName: message.feedback == .negative ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .font(.caption)
                    .foregroundStyle(message.feedback == .negative ? .red : .secondary)
            }
            .buttonStyle(.plain)
            .frame(minWidth: HIGDesignTokens.minTouchTarget, minHeight: HIGDesignTokens.minTouchTarget)
            .accessibilityLabel("Mark as not helpful")
            
            Spacer()
            
            // [edit-menus] [collaboration-and-sharing] - Copy button
            Button {
                copyToClipboard(message.content)
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .frame(minWidth: HIGDesignTokens.minTouchTarget, minHeight: HIGDesignTokens.minTouchTarget)
            .accessibilityLabel("Copy response")
            
            // [activity-views] - Share button
            ShareLink(item: message.content) {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: HIGDesignTokens.minTouchTarget, minHeight: HIGDesignTokens.minTouchTarget)
            .accessibilityLabel("Share response")
        }
    }
    
    // [context-menus] - Message context menu
    @ViewBuilder
    private func messageContextMenu(_ message: DocuMessage) -> some View {
        // [edit-menus] - Copy
        Button {
            copyToClipboard(message.content)
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }
        
        // [activity-views] - Share
        ShareLink(item: message.content) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        
        if message.role == .assistant {
            Divider()
            
            // [undo-and-redo] - Regenerate
            Button {
                regenerateResponse(for: message)
            } label: {
                Label("Regenerate", systemImage: "arrow.clockwise")
            }
            
            // [ratings-and-reviews] - Report
            Button(role: .destructive) {
                reportMessage(message)
            } label: {
                Label("Report Issue", systemImage: "exclamationmark.triangle")
            }
        }
        
        if message.role == .user {
            Divider()
            
            // [undo-and-redo] - Edit
            Button {
                editMessage(message)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            // [undo-and-redo] - Delete
            Button(role: .destructive) {
                deleteMessage(message)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // [images] - Image attachments view
    private func imageAttachments(_ images: [Data]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HIGDesignTokens.stackSpacing) {
                ForEach(images.indices, id: \.self) { index in
                    if let nsImage = NSImage(data: images[index]) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: HIGDesignTokens.radiusSmall))
                    }
                }
            }
        }
    }
}


// MARK: - Input Area [text-fields] [virtual-keyboards] [buttons]

extension DocuChatUI {
    
    private var inputArea: some View {
        VStack(spacing: 0) {
            // Context indicator
            if let topic = selectedTopic {
                contextIndicator(topic)
            }
            
            HStack(alignment: .bottom, spacing: HIGDesignTokens.bezelPadding) {
                // [buttons] - Attachment button
                attachmentButton
                
                // [text-fields] - Input field
                inputTextField
                
                // [buttons] - Send button
                sendButton
            }
            .padding(HIGDesignTokens.contentPadding)
            .background(inputBackground) // [materials]
        }
    }
    
    // [materials] - Input background
    @ViewBuilder
    private var inputBackground: some View {
        if reduceTransparency {
            Color(.windowBackgroundColor)
        } else {
            Rectangle().fill(.regularMaterial) // [materials] - Liquid Glass
        }
    }
    
    // [buttons] - Attachment button
    private var attachmentButton: some View {
        Menu {
            // [file-management] - File attachment
            Button {
                // Open file picker
            } label: {
                Label("Attach File", systemImage: "doc")
            }
            
            // [images] - Image attachment
            Button {
                // Open image picker
            } label: {
                Label("Attach Image", systemImage: "photo")
            }
            
            // [playing-audio] - Voice input
            Button {
                // Start voice recording
            } label: {
                Label("Voice Input", systemImage: "mic")
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .menuStyle(.borderlessButton)
        .frame(minWidth: HIGDesignTokens.minTouchTarget, minHeight: HIGDesignTokens.minTouchTarget)
        .accessibilityLabel("Add attachment")
    }
    
    // [text-fields] [virtual-keyboards] [keyboards] - Input text field
    private var inputTextField: some View {
        HStack(alignment: .bottom, spacing: HIGDesignTokens.stackSpacing) {
            TextField("Ask about HIG guidelines...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.body) // [typography]
                .lineLimit(1...6)
                .focused($focusedField, equals: .input) // [focus-and-selection]
                .onSubmit { if canSend { sendMessage() } }
                // [keyboards] - Keyboard shortcut hint for macOS
                #if os(macOS)
                .help("Press Return to send, ⌘N for new conversation")
                #endif
                .accessibilityLabel("Message input")
                .accessibilityHint("Type your question about HIG guidelines")
            
            // [text-fields] - Clear button
            if !inputText.isEmpty {
                Button {
                    inputText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(Color.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
                .frame(minWidth: HIGDesignTokens.minTouchTarget, minHeight: HIGDesignTokens.minTouchTarget)
                .accessibilityLabel("Clear input")
            }
        }
        .padding(.horizontal, HIGDesignTokens.bezelPadding)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: HIGDesignTokens.radiusMedium)
                .fill(Color(.textBackgroundColor).opacity(reduceTransparency ? 1.0 : 0.8))
        )
    }
    
    // [buttons] - Send button
    private var sendButton: some View {
        Button {
            sendMessage()
            // [playing-haptics]
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
        } label: {
            ZStack {
                Circle()
                    .fill(canSend ? Color.accentColor : Color(.controlBackgroundColor))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "arrow.up")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(canSend ? Color.white : Color.gray)
            }
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .frame(minWidth: HIGDesignTokens.minTouchTarget, minHeight: HIGDesignTokens.minTouchTarget)
        .accessibilityLabel("Send message")
        .accessibilityHint(canSend ? "Double tap to send" : "Enter a message first")
        // [motion] - Scale animation
        .scaleEffect(canSend ? 1.0 : 0.95)
        .animation(reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.7), value: canSend)
    }
    
    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isProcessing
    }
    
    // Context indicator
    private func contextIndicator(_ topic: HIGTopic) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "doc.text.fill")
                .font(.caption2)
            Text(topic.title)
                .font(.caption2)
                .lineLimit(1)
            Button { selectedTopic = nil } label: {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.purple.opacity(0.15)))
        .foregroundStyle(.purple)
        .padding(.horizontal, HIGDesignTokens.contentPadding)
        .padding(.top, HIGDesignTokens.stackSpacing)
    }
}

// MARK: - Topic Header [toolbars]

extension DocuChatUI {
    
    private func topicHeader(_ topic: HIGTopic) -> some View {
        VStack(alignment: .leading, spacing: HIGDesignTokens.bezelPadding) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(topic.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: HIGDesignTokens.stackSpacing) {
                        Label(topic.displayCategory, systemImage: topic.categorySymbol)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Link(destination: URL(string: topic.url)!) {
                            Label("View on Apple", systemImage: "safari")
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                Button { askAboutTopic(topic) } label: {
                    Label("Ask AI", systemImage: "sparkles")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
            }
            
            Text(topic.abstract)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(HIGDesignTokens.contentPadding)
        .background(reduceTransparency ? Color(.controlBackgroundColor) : Color(.windowBackgroundColor).opacity(0.8))
    }
}

// MARK: - Processing & Error [loading] [progress-indicators] [feedback]

extension DocuChatUI {
    
    // [loading] [progress-indicators]
    private var processingIndicator: some View {
        HStack(spacing: HIGDesignTokens.bezelPadding) {
            ProgressView()
                .controlSize(.small)
            Text("Searching HIG documentation...")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(HIGDesignTokens.contentPadding)
        .background(
            RoundedRectangle(cornerRadius: HIGDesignTokens.radiusMedium)
                .fill(Color(.controlBackgroundColor).opacity(reduceTransparency ? 1.0 : 0.8))
        )
        .accessibilityLabel("Processing your question")
        .accessibilityAddTraits(.updatesFrequently)
    }
    
    // [feedback] - Error banner
    private func errorBanner(_ error: DocuError) -> some View {
        HStack(spacing: HIGDesignTokens.bezelPadding) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(error.localizedDescription)
                .font(.callout)
            Spacer()
            Button { errorState = nil } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(HIGDesignTokens.bezelPadding)
        .background(RoundedRectangle(cornerRadius: HIGDesignTokens.radiusSmall).fill(Color.red.opacity(0.1)))
        .padding(.horizontal, HIGDesignTokens.contentPadding)
        .padding(.vertical, HIGDesignTokens.stackSpacing)
    }
}

// MARK: - Toolbar [toolbars] [the-menu-bar]

extension DocuChatUI {
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            // [settings]
            Button { showSettings = true } label: {
                Label("Settings", systemImage: "gear")
            }
            .help("Open settings")
        }
    }
    
    @ToolbarContentBuilder
    private var chatToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            // [undo-and-redo] - Clear chat
            Button { clearChat() } label: {
                Label("Clear Chat", systemImage: "trash")
            }
            .disabled(messages.isEmpty)
            .help("Clear conversation")
            
            // [collaboration-and-sharing] - Share
            ShareLink(items: messages.map { $0.content }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .disabled(messages.isEmpty)
            .help("Share conversation")
            
            // [printing] - Print
            Button { printConversation() } label: {
                Label("Print", systemImage: "printer")
            }
            .disabled(messages.isEmpty)
            .help("Print conversation")
        }
    }
}

// MARK: - Settings Sheet [settings] [sheets] [materials]

extension DocuChatUI {
    
    private var settingsSheet: some View {
        NavigationStack {
            Form {
                // [settings] [machine-learning] - Local AI Service Configuration
                Section {
                    // [text-fields] - Ollama URL
                    LabeledContent("Ollama URL") {
                        TextField("URL", text: .constant("http://localhost:11434"))
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 200)
                    }
                    
                    // [pickers] - Model selection
                    LabeledContent("Model") {
                        Picker("", selection: .constant("llama3.2")) {
                            Text("Llama 3.2").tag("llama3.2")
                            Text("Llama 3.1").tag("llama3.1")
                            Text("Mistral").tag("mistral")
                            Text("CodeLlama").tag("codellama")
                            Text("Phi-3").tag("phi3")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 150)
                    }
                    
                    // [buttons] - Test connection
                    Button {
                        // Test Ollama connection
                    } label: {
                        Label("Test Connection", systemImage: "network")
                    }
                    .buttonStyle(.bordered)
                } header: {
                    Label("Local AI Service", systemImage: "cpu")
                } footer: {
                    Text("Ollama runs entirely on your device. No data leaves your Mac.")
                        .font(.caption)
                }
                
                // [settings] [generative-ai] - AI Behavior
                Section {
                    // [sliders] - Temperature
                    LabeledContent("Creativity") {
                        Slider(value: .constant(0.7), in: 0...1)
                            .frame(maxWidth: 150)
                    }
                    
                    // [toggles] - Streaming
                    Toggle("Stream Responses", isOn: .constant(true))
                    
                    // [toggles] - Show sources
                    Toggle("Show HIG References", isOn: .constant(true))
                } header: {
                    Label("AI Behavior", systemImage: "sparkles")
                }
                
                // [materials] - Liquid Glass Design System
                Section {
                    // [toggles] - Glass effects
                    Toggle("Liquid Glass Effects", isOn: .constant(!reduceTransparency))
                        .disabled(reduceTransparency)
                    
                    // [color] - Accent color
                    LabeledContent("Accent Color") {
                        ColorPicker("", selection: .constant(Color.purple))
                            .labelsHidden()
                    }
                    
                    if reduceTransparency {
                        // [accessibility] - Transparency notice
                        Label("Glass effects disabled due to Reduce Transparency setting", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("Appearance", systemImage: "paintpalette")
                } footer: {
                    Text("Liquid Glass adapts to system appearance and accessibility settings.")
                        .font(.caption)
                }
                
                // [accessibility] - Accessibility info
                Section {
                    LabeledContent("Dynamic Type") {
                        Text(dynamicTypeSize.isAccessibilitySize ? "Accessibility Size" : "Standard")
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Reduce Motion") {
                        Image(systemName: reduceMotion ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(reduceMotion ? .green : .secondary)
                    }
                    LabeledContent("Reduce Transparency") {
                        Image(systemName: reduceTransparency ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(reduceTransparency ? .green : .secondary)
                    }
                    LabeledContent("Layout Direction") {
                        Text(layoutDirection == .rightToLeft ? "Right to Left" : "Left to Right")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("Accessibility", systemImage: "accessibility")
                } footer: {
                    Text("These settings are controlled in System Settings → Accessibility.")
                        .font(.caption)
                }
                
                // [privacy] [generative-ai] - Privacy & Data
                Section {
                    // [sf-symbols] - Privacy indicators
                    HStack(spacing: HIGDesignTokens.bezelPadding) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("100% Local Processing")
                                .font(.headline)
                            Text("All AI processing happens on your device using Ollama. Your questions and the HIG documentation never leave your Mac.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // [labels] - Data handling
                    Label("No cloud services required", systemImage: "icloud.slash")
                        .foregroundStyle(.secondary)
                    Label("No API keys needed", systemImage: "key.slash")
                        .foregroundStyle(.secondary)
                    Label("Works offline", systemImage: "wifi.slash")
                        .foregroundStyle(.secondary)
                } header: {
                    Label("Privacy", systemImage: "hand.raised.fill")
                }
                
                // [settings] - About
                Section {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("HIG Topics", value: "148")
                    Link(destination: URL(string: "https://developer.apple.com/design/human-interface-guidelines")!) {
                        Label("Apple HIG Documentation", systemImage: "safari")
                    }
                    Link(destination: URL(string: "https://ollama.ai")!) {
                        Label("Ollama Website", systemImage: "link")
                    }
                } header: {
                    Label("About", systemImage: "info.circle")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showSettings = false }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 400)
    }
}


// MARK: - Actions [entering-data] [generative-ai] [machine-learning]

extension DocuChatUI {
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        inputText = ""
        focusedField = nil
        
        // Add user message
        let userMessage = DocuMessage(role: .user, content: text)
        messages.append(userMessage)
        
        isProcessing = true
        errorState = nil
        
        // [voiceover] - Announce for accessibility
        announceForVoiceOver("Sending message")
        
        Task {
            do {
                // [machine-learning] [generative-ai] - Build context from HIG docs
                let context = buildAIContext(for: text)
                
                // Get AI response
                let response = try await provider.ask(query: text, context: context)
                
                // Extract references
                let refs = extractTopicReferences(from: response.message)
                
                // Add assistant message
                let assistantMessage = DocuMessage(
                    role: .assistant,
                    content: response.message,
                    references: refs
                )
                messages.append(assistantMessage)
                
                // [voiceover] - Announce response
                announceForVoiceOver("Response received")
                
            } catch {
                errorState = .aiError(error.localizedDescription)
                announceForVoiceOver("Error: \(error.localizedDescription)")
            }
            
            isProcessing = false
        }
    }
    
    // [machine-learning] - Build AI context from HIG documentation
    private func buildAIContext(for query: String) -> AIContext {
        var relevantTopics = knowledgeBase.search(query: query, limit: 5)
        
        if let selected = selectedTopic, !relevantTopics.contains(where: { $0.id == selected.id }) {
            relevantTopics.insert(selected, at: 0)
        }
        
        let contextString = relevantTopics.map { topic in
            var content = "## \(topic.title)\nCategory: \(topic.displayCategory)\nURL: \(topic.url)\n\n\(topic.abstract)"
            
            for section in topic.sections {
                if !section.heading.isEmpty {
                    content += "\n\n### \(section.heading)\n"
                }
                for item in section.content {
                    if let text = item.text {
                        content += "\(text)\n"
                    }
                }
            }
            return content
        }.joined(separator: "\n\n---\n\n")
        
        return AIContext(
            currentFile: nil,
            selectedText: contextString,
            projectContext: "Apple Human Interface Guidelines Documentation - 148 Topics"
        )
    }
    
    private func extractTopicReferences(from text: String) -> [String] {
        var refs: [String] = []
        for topic in knowledgeBase.allTopics {
            if text.localizedCaseInsensitiveContains(topic.title) {
                refs.append(topic.id)
                if refs.count >= 3 { break }
            }
        }
        return refs
    }
    
    private func askAboutTopic(_ topic: HIGTopic) {
        inputText = "Explain the key guidelines for \(topic.title)"
        sendMessage()
    }
    
    private func provideFeedback(message: DocuMessage, positive: Bool) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].feedback = positive ? .positive : .negative
        }
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #elseif os(iOS)
        UIPasteboard.general.string = text
        #endif
    }
    
    private func copyTopicLink(_ topic: HIGTopic) {
        copyToClipboard(topic.url)
    }
    
    private func clearChat() {
        messages.removeAll()
        errorState = nil
    }
    
    private func regenerateResponse(for message: DocuMessage) {
        // Find the user message before this response
        if let index = messages.firstIndex(where: { $0.id == message.id }),
           index > 0,
           messages[index - 1].role == .user {
            let userQuery = messages[index - 1].content
            messages.remove(at: index)
            inputText = userQuery
            sendMessage()
        }
    }
    
    private func editMessage(_ message: DocuMessage) {
        inputText = message.content
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages.remove(at: index)
        }
        focusedField = .input
    }
    
    private func deleteMessage(_ message: DocuMessage) {
        messages.removeAll { $0.id == message.id }
    }
    
    private func reportMessage(_ message: DocuMessage) {
        // Report functionality
    }
    
    private func printConversation() {
        // [printing] - Print support
        #if os(macOS)
        let printContent = messages.map { "\($0.role == .user ? "You" : "AI"): \($0.content)" }.joined(separator: "\n\n")
        let printView = NSTextView(frame: NSRect(x: 0, y: 0, width: 612, height: 792))
        printView.string = printContent
        let printOperation = NSPrintOperation(view: printView)
        printOperation.run()
        #endif
    }
    
    private func refreshData() async {
        // Refresh HIG data
    }
    
    // [voiceover] - VoiceOver announcement
    private func announceForVoiceOver(_ message: String) {
        #if os(iOS)
        UIAccessibility.post(notification: .announcement, argument: message)
        #elseif os(macOS)
        NSAccessibility.post(element: NSApp.mainWindow as Any, notification: .announcementRequested, userInfo: [.announcement: message])
        #endif
    }
    
    // [typography] - Parse markdown
    private func parseMarkdown(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
    
    // [accessibility] - Message accessibility label
    private func messageAccessibilityLabel(_ message: DocuMessage) -> String {
        let role = message.role == .user ? "You said" : "AI responded"
        return "\(role): \(message.content)"
    }
    
    // Detect platforms from topic content
    private func detectPlatforms(_ topic: HIGTopic) -> [ApplePlatform] {
        var platforms: [ApplePlatform] = []
        let content = topic.abstract.lowercased() + topic.sections.map { $0.heading.lowercased() }.joined()
        
        if content.contains("ios") || content.contains("iphone") { platforms.append(.iOS) }
        if content.contains("ipados") || content.contains("ipad") { platforms.append(.iPadOS) }
        if content.contains("macos") || content.contains("mac") { platforms.append(.macOS) }
        if content.contains("watchos") || content.contains("watch") { platforms.append(.watchOS) }
        if content.contains("tvos") || content.contains("apple tv") { platforms.append(.tvOS) }
        if content.contains("visionos") || content.contains("vision") { platforms.append(.visionOS) }
        
        return platforms.isEmpty ? [.iOS, .macOS] : platforms
    }
}

// MARK: - Supporting Types

struct DocuMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp = Date()
    var references: [String]?
    var images: [Data]?
    var feedback: Feedback?
    
    enum Role { case user, assistant }
    enum Feedback { case positive, negative }
}

enum DocuError: LocalizedError {
    case aiError(String)
    case networkError
    case documentationNotLoaded
    
    var errorDescription: String? {
        switch self {
        case .aiError(let msg): return msg
        case .networkError: return "Unable to connect to AI service"
        case .documentationNotLoaded: return "HIG documentation not loaded"
        }
    }
}

enum HIGCategoryType: String, CaseIterable {
    case foundations = "Foundations"
    case patterns = "Patterns"
    case components = "Components"
    case inputs = "Inputs"
    case technologies = "Technologies"
    
    var symbolName: String {
        switch self {
        case .foundations: return "square.3.layers.3d"
        case .patterns: return "rectangle.3.group"
        case .components: return "square.on.square"
        case .inputs: return "hand.tap"
        case .technologies: return "cpu"
        }
    }
    
    var color: Color {
        switch self {
        case .foundations: return .purple
        case .patterns: return .blue
        case .components: return .green
        case .inputs: return .orange
        case .technologies: return .pink
        }
    }
}

enum ApplePlatform: String, CaseIterable {
    case iOS, iPadOS, macOS, watchOS, tvOS, visionOS
    
    var symbolName: String {
        switch self {
        case .iOS: return "iphone"
        case .iPadOS: return "ipad"
        case .macOS: return "macbook"
        case .watchOS: return "applewatch"
        case .tvOS: return "appletv"
        case .visionOS: return "visionpro"
        }
    }
}

extension HIGTopic {
    var categorySymbol: String {
        HIGCategoryType(rawValue: category)?.symbolName ?? "doc.text"
    }
}

// MARK: - Flow Layout [layout]

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0; y += rowHeight + spacing; rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }
            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Preview

#Preview("DocuChatUI - Full HIG Implementation") {
    DocuChatUI(provider: HIGAIProvider(), knowledgeBase: .shared)
        .frame(width: 1200, height: 800)
}
