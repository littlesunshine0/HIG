//
//  HIGChatView.swift
//  HIG
//
//  AI chat interface with HIG knowledge integration
//

import SwiftUI

struct HIGChatView: View {
    @State private var aiService = AIService()
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var showContext = false
    @State private var showSources = false
    @State private var selectedContextTopic: HIGTopic?
    @FocusState private var isInputFocused: Bool
    
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Main content
            HSplitView {
                chatPanel
                    .frame(minWidth: 500)
                
                if showContext {
                    contextPanel
                        .frame(minWidth: 320, maxWidth: 450)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            
            // Floating toolbar
            VStack {
                HStack {
                    Spacer()
                    floatingToolbar
                        .padding(.trailing, 20)
                        .padding(.top, 12)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showSettings) {
            AISettingsView(config: $aiService.config)
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusSearch)) { _ in
            isInputFocused = true
        }
        .onAppear {
            isInputFocused = true
        }
    }
    
    // MARK: - Floating Toolbar
    
    private var floatingToolbar: some View {
        HStack(spacing: 8) {
            // Sources indicator
            if !messages.isEmpty {
                Button {
                    showSources.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "link.circle.fill")
                            .font(.caption)
                        Text("\(messages.count)")
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
                .help("View sources")
            }
            
            // Context toggle
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showContext.toggle()
                }
            } label: {
                Image(systemName: showContext ? "sidebar.right.fill" : "sidebar.right")
                    .font(.body.weight(.medium))
                    .foregroundStyle(showContext ? .purple : .secondary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .help(showContext ? "Hide context" : "Show context")
            
            // More menu
            Menu {
                Button {
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                
                Button {
                    showAbout = true
                } label: {
                    Label("About", systemImage: "info.circle")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    withAnimation {
                        messages.removeAll()
                    }
                } label: {
                    Label("Clear Chat", systemImage: "trash")
                }
                .disabled(messages.isEmpty)
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .help("More options")
        }
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Chat Panel
    
    private var chatPanel: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(white: 0.08), Color(white: 0.05)]
                    : [Color(white: 0.98), Color(white: 0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with branding
                chatHeader
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            if messages.isEmpty {
                                welcomeMessage
                                    .padding(.top, 40)
                            } else {
                                // Spacer for better top padding
                                Color.clear.frame(height: 20)
                            }
                            
                            ForEach(messages) { message in
                                MessageBubble(
                                    message: message,
                                    onContextTap: { topicId in
                                        if let topic = HIGKnowledgeBase.shared.topic(byId: topicId) {
                                            selectedContextTopic = topic
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                showContext = true
                                            }
                                        }
                                    },
                                    onRatingChanged: { rating in
                                        updateMessageRating(messageId: message.id, rating: rating)
                                    }
                                )
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                            
                            if aiService.isProcessing {
                                typingIndicatorView
                                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                            }
                            
                            // Bottom spacer
                            Color.clear.frame(height: 20)
                        }
                        .padding(.horizontal, 24)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: messages.count) {
                        if let lastMessage = messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input area with enhanced design
                enhancedInputArea
            }
        }
    }
    
    // MARK: - Chat Header
    
    private var chatHeader: some View {
        HStack(spacing: 12) {
            // App icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.purple)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("DocuChat")
                    .font(.headline.weight(.semibold))
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                    
                    Text("Ready")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Typing Indicator View
    
    private var typingIndicatorView: some View {
        HStack(alignment: .top, spacing: 14) {
            // Assistant avatar with glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(0.3), .purple.opacity(0.1), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Image(systemName: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.purple)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text("AI Assistant")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(.secondary)
                
                HStack(spacing: 10) {
                    TypingIndicator()
                    Text("Searching knowledge sources...")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "apple.logo")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(.secondary)
            
            Text("HIG Assistant")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Ask me anything about Apple's Human Interface Guidelines. I'll provide guidance based on HIG best practices and include relevant documentation.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 400)
            
            // Local-first indicator
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(.green)
                Text("100% Local & Private")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.1), in: Capsule())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Try asking:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ForEach(sampleQuestions, id: \.self) { question in
                    Button {
                        inputText = question
                        sendMessage()
                    } label: {
                        Text(question)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.vertical, 40)
    }
    
    private var sampleQuestions: [String] {
        [
            "How should I design buttons for iOS?",
            "What are the best practices for dark mode?",
            "How do I make my app accessible?",
            "What colors should I use in my app?",
            "How should onboarding work?"
        ]
    }
    
    private var enhancedInputArea: some View {
        VStack(spacing: 0) {
            // Suggestions bar (when empty)
            if messages.isEmpty && inputText.isEmpty {
                quickSuggestionsBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                // Text input with enhanced styling
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        TextField("Ask anything about development...", text: $inputText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .lineLimit(1...6)
                            .focused($isInputFocused)
                            .onSubmit {
                                sendMessage()
                            }
                        
                        if !inputText.isEmpty {
                            Button {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    inputText = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.tertiary)
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                }
                
                // Send button with enhanced design
                Button {
                    sendMessage()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                canSend
                                    ? LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color(.controlBackgroundColor), Color(.controlBackgroundColor)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .frame(width: 44, height: 44)
                            .shadow(
                                color: canSend ? Color.purple.opacity(0.3) : .clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        
                        Image(systemName: "arrow.up")
                            .font(.body.weight(.bold))
                            .foregroundStyle(canSend ? .white : .gray)
                    }
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
                .scaleEffect(canSend ? 1.0 : 0.92)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: canSend)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Quick Suggestions Bar
    
    private var quickSuggestionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(quickSuggestions, id: \.self) { suggestion in
                    Button {
                        inputText = suggestion
                        isInputFocused = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                            Text(suggestion)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.1))
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
    
    private var quickSuggestions: [String] {
        [
            "How do I implement animations?",
            "Create a custom button",
            "Explain async/await",
            "Best practices for SwiftUI",
            "Debug a memory leak"
        ]
    }
    
    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !aiService.isProcessing
    }
    
    // MARK: - Context Panel
    
    private var contextPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Context")
                    .font(.headline)
                Spacer()
                Button {
                    showContext = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            if let topic = selectedContextTopic {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(topic.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Label(topic.displayCategory, systemImage: "folder")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(topic.abstract)
                            .font(.body)
                        
                        ForEach(topic.sections.prefix(3)) { section in
                            if !section.heading.isEmpty {
                                Text(section.heading)
                                    .font(.headline)
                                    .padding(.top, 8)
                                
                                ForEach(Array(section.content.prefix(3).enumerated()), id: \.offset) { _, content in
                                    if let text = content.text {
                                        Text(try! AttributedString(markdown: text))
                                            .font(.callout)
                                    }
                                }
                            }
                        }
                        
                        Link(destination: URL(string: topic.url)!) {
                            Label("View Full Topic", systemImage: "safari")
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "No Context Selected",
                    systemImage: "doc.text",
                    description: Text("Click on a context tag in a message to view the HIG topic")
                )
            }
        }
        .background(.background)
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        inputText = ""
        
        // Add user message
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        
        // Get AI response
        Task {
            if let response = await aiService.chat(messages: messages, query: text) {
                messages.append(response)
            } else if let error = aiService.error {
                messages.append(ChatMessage(
                    role: .assistant,
                    content: "Sorry, I encountered an error: \(error)\n\nPlease check your AI settings and try again."
                ))
            }
        }
    }
    
    private func updateMessageRating(messageId: UUID, rating: ChatMessage.FeedbackRating) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            var updatedMessage = messages[index]
            updatedMessage.rating = rating
            messages[index] = updatedMessage
            
            // Persist the rating (will be implemented in next subtask)
            FeedbackManager.shared.saveRating(messageId: messageId, rating: rating)
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    var onContextTap: ((String) -> Void)?
    var onRatingChanged: ((ChatMessage.FeedbackRating) -> Void)?
    
    @State private var isHovered = false
    @State private var localRating: ChatMessage.FeedbackRating?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                assistantAvatar
            } else {
                // Spacer to push user messages to the right
                Spacer(minLength: 0)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
                // Message content
                VStack(alignment: .leading, spacing: 8) {
                    if message.role == .assistant {
                        // AI indicator
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                            Text("AI Response")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    Text(parseMarkdown(message.content))
                        .textSelection(.enabled)
                        .foregroundStyle(message.role == .user ? .white : .primary)
                }
                .padding(14)
                .background(bubbleBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(alignment: .bottomTrailing) {
                    if isHovered && message.role == .assistant {
                        messageActions
                            .offset(y: 30)
                    }
                }
                
                // Context tags
                if let context = message.context, !context.isEmpty {
                    contextTags(context)
                }
                
                // Feedback buttons for AI messages
                if message.role == .assistant {
                    feedbackButtons
                }
            }
            .frame(maxWidth: 600, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .user {
                userAvatar
            } else {
                // Spacer to keep AI messages on the left
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onAppear {
            localRating = message.rating
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var assistantAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(.purple)
        }
        .frame(width: 32, height: 32)
        .accessibilityHidden(true)
    }
    
    private var userAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
            
            Image(systemName: "person.fill")
                .font(.caption)
                .foregroundStyle(Color.accentColor)
        }
        .frame(width: 32, height: 32)
        .accessibilityHidden(true)
    }
    
    @ViewBuilder
    private var bubbleBackground: some View {
        if message.role == .user {
            LinearGradient(
                colors: [Color.accentColor, Color.accentColor.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            ZStack {
                Color(.secondarySystemFill)
                
                // Subtle glass effect
                LinearGradient(
                    colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.05 : 0.3),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .center
                )
            }
        }
    }
    
    private var messageActions: some View {
        HStack(spacing: 4) {
            Button {
                copyToClipboard(message.content)
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .padding(6)
            .background(Circle().fill(.regularMaterial))
            .help("Copy message")
            .accessibilityLabel("Copy message")
            .accessibilityHint("Copy message text to clipboard")
            
            ShareLink(item: message.content) {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .padding(6)
            .background(Circle().fill(.regularMaterial))
            .help("Share message")
            .accessibilityLabel("Share message")
            .accessibilityHint("Share message text")
        }
        .opacity(isHovered ? 1 : 0)
        .scaleEffect(isHovered ? 1 : 0.8)
        .animation(.easeOut(duration: 0.2), value: isHovered)
    }
    
    private var feedbackButtons: some View {
        HStack(spacing: 8) {
            Text("Was this helpful?")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            
            // Thumbs up button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    let newRating: ChatMessage.FeedbackRating = localRating == .thumbsUp ? .thumbsUp : .thumbsUp
                    localRating = newRating
                    onRatingChanged?(newRating)
                }
            } label: {
                Image(systemName: localRating == .thumbsUp ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.caption)
                    .foregroundStyle(localRating == .thumbsUp ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .padding(6)
            .background(
                Circle()
                    .fill(localRating == .thumbsUp ? Color.green.opacity(0.15) : Color(.controlBackgroundColor))
            )
            .help("This was helpful")
            .accessibilityLabel("Rate as helpful")
            
            // Thumbs down button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    let newRating: ChatMessage.FeedbackRating = localRating == .thumbsDown ? .thumbsDown : .thumbsDown
                    localRating = newRating
                    onRatingChanged?(newRating)
                }
            } label: {
                Image(systemName: localRating == .thumbsDown ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .font(.caption)
                    .foregroundStyle(localRating == .thumbsDown ? .red : .secondary)
            }
            .buttonStyle(.plain)
            .padding(6)
            .background(
                Circle()
                    .fill(localRating == .thumbsDown ? Color.red.opacity(0.15) : Color(.controlBackgroundColor))
            )
            .help("This was not helpful")
            .accessibilityLabel("Rate as not helpful")
            
            if localRating != nil {
                Text("Thanks for your feedback!")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .padding(.top, 4)
    }
    
    private func contextTags(_ context: [String]) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.text")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            
            Text("Based on:")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            
            ForEach(context.prefix(3), id: \.self) { topicId in
                if let topic = HIGKnowledgeBase.shared.topic(byId: topicId) {
                    Button {
                        onContextTap?(topicId)
                    } label: {
                        Text(topic.title)
                            .font(.caption2)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.purple.opacity(0.15))
                            )
                            .foregroundStyle(.purple)
                    }
                    .buttonStyle(.plain)
                    .hoverScale(1.05)
                    .help(topic.title)
                    .accessibilityLabel("View \(topic.title)")
                    .accessibilityHint("Open this HIG topic in the context panel")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Context topics")
    }
    
    private func parseMarkdown(_ text: String) -> AttributedString {
        // Try to parse as markdown first
        if let attributed = try? AttributedString(markdown: text), !attributed.characters.isEmpty {
            return attributed
        }
        // Fall back to plain text - explicitly create from String to avoid markdown parsing
        var plainText = AttributedString()
        plainText.append(AttributedString(text))
        return plainText
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
    
    private var accessibilityLabel: String {
        let role = message.role == .user ? "You said" : "AI responded"
        return "\(role): \(message.content)"
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dotScale: [CGFloat] = [1, 1, 1]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(dotScale[index])
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 16))
        .onAppear {
            guard !reduceMotion else { return }
            animateDots()
        }
    }
    
    private func animateDots() {
        for i in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.4)
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.15)
            ) {
                dotScale[i] = 0.5
            }
        }
    }
}

// MARK: - Settings View

struct AISettingsView: View {
    @Binding var config: AIConfig
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Provider") {
                    Picker("AI Provider", selection: $config.provider) {
                        ForEach(AIConfig.AIProvider.allCases) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    
                    if config.provider == .ollama {
                        TextField("Base URL", text: $config.baseURL)
                        TextField("Model", text: $config.model)
                            .textContentType(.none)
                    } else {
                        SecureField("API Key", text: Binding(
                            get: { config.apiKey ?? "" },
                            set: { config.apiKey = $0.isEmpty ? nil : $0 }
                        ))
                        
                        TextField("Model (optional)", text: $config.model)
                    }
                }
                
                Section("Parameters") {
                    HStack {
                        Text("Temperature")
                        Spacer()
                        Text(String(format: "%.1f", config.temperature))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $config.temperature, in: 0...1, step: 0.1)
                    
                    Stepper("Max Tokens: \(config.maxTokens)", value: $config.maxTokens, in: 256...8192, step: 256)
                }
                
                Section {
                    if config.provider == .ollama {
                        Text("Make sure Ollama is running locally with the specified model.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Your API key is stored locally and never shared.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("AI Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        config.save()
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 400)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("AI Settings")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HIGChatView()
    }
    .frame(width: 900, height: 600)
}
