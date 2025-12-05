//
//  SettingsView.swift
//  HIG
//
//  Settings view for AI configuration
//  100% HIG-Compliant with Liquid Glass Design
//
//  HIG Topics Implemented:
//  [settings] - Settings interface
//  [pickers] - Provider and model selection
//  [sliders] - Temperature control
//  [steppers] - Max tokens control
//  [accessibility] - VoiceOver, Dynamic Type
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var config: AIConfig
    @State private var hasChanges = false
    
    init() {
        let loadedConfig = AIConfig.load()
        _config = State(initialValue: loadedConfig)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Settings Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Documentation Sources Section
                    documentationSection
                    
                    Divider()
                    
                    // Updates Section
                    updatesSection
                    
                    Divider()
                    
                    // AI Provider Section
                    providerSection
                    
                    Divider()
                    
                    // Model Configuration Section
                    modelSection
                    
                    Divider()
                    
                    // Advanced Settings Section
                    advancedSection
                }
                .padding(24)
            }
            
            Divider()
            
            // Footer with action buttons
            footerView
        }
        .frame(width: 600, height: 700)
        .background(.background)
        .onChange(of: config) { _, _ in
            hasChanges = true
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.title2.bold())
                
                Text("Configure AI provider and model settings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .help("Close settings")
            .accessibilityLabel("Close")
            .accessibilityHint("Close settings window")
        }
        .padding(24)
    }
    
    // MARK: - Documentation Section
    
    private var documentationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Documentation",
                icon: "doc.text.magnifyingglass",
                description: "Manage your documentation sources",
                color: .blue,
                shape: .roundedSquare
            )
            
            VStack(alignment: .leading, spacing: 12) {
                Text("DocuChat can index any documentation folder on your computer. Add your project docs, API references, or technical guides.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Supported formats
                VStack(alignment: .leading, spacing: 6) {
                    Text("Supported formats:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("Markdown, HTML, Text, Code files, JSON, YAML, XML, PDFs, Bundles, Frameworks, and more")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.green)
                    
                    Text("All documents stay on your device and are never uploaded")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                
                Button {
                    openWindow(id: "sources")
                } label: {
                    Label("Manage Documentation Sources", systemImage: "folder.badge.gearshape")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }
    
    @Environment(\.openWindow) private var openWindow
    @State private var updateManager = ResourceUpdateManager.shared
    
    // MARK: - Updates Section
    
    private var updatesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Resource Updates",
                icon: "arrow.triangle.2.circlepath",
                description: "Keep documentation up to date",
                color: .green,
                shape: .circle
            )
            
            VStack(alignment: .leading, spacing: 16) {
                // Auto-update toggle
                Toggle("Automatic Updates", isOn: $updateManager.config.autoUpdateEnabled)
                    .onChange(of: updateManager.config.autoUpdateEnabled) { _, _ in
                        updateManager.config.save()
                    }
                
                // Update frequency
                if updateManager.config.autoUpdateEnabled {
                    Picker("Check for updates", selection: $updateManager.config.updateFrequency) {
                        ForEach(UpdateConfig.UpdateFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .onChange(of: updateManager.config.updateFrequency) { _, _ in
                        updateManager.config.save()
                    }
                }
                
                // Status
                HStack {
                    Image(systemName: statusIcon)
                        .foregroundStyle(statusColor)
                    Text(updateManager.status.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Last update
                if let lastUpdate = updateManager.config.lastSuccessfulUpdate {
                    Text("Last updated: \(lastUpdate.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                // Update button
                HStack(spacing: 12) {
                    Button {
                        Task {
                            await updateManager.checkForUpdates()
                        }
                    } label: {
                        Label("Check Now", systemImage: "arrow.clockwise")
                    }
                    .disabled(isCheckingOrDownloading)
                    
                    if updateManager.updateAvailable {
                        Button {
                            Task {
                                await updateManager.performUpdate()
                            }
                        } label: {
                            Label("Install Update", systemImage: "arrow.down.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
    
    private var statusIcon: String {
        switch updateManager.status {
        case .idle: return "checkmark.circle.fill"
        case .checking: return "arrow.triangle.2.circlepath"
        case .updateAvailable: return "exclamationmark.circle.fill"
        case .downloading, .installing: return "arrow.down.circle"
        case .complete: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch updateManager.status {
        case .idle, .complete: return .green
        case .checking, .downloading, .installing: return .blue
        case .updateAvailable: return .orange
        case .error: return .red
        }
    }
    
    private var isCheckingOrDownloading: Bool {
        switch updateManager.status {
        case .checking, .downloading:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Provider Section
    
    private var providerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "AI Provider",
                icon: "cpu",
                description: "Choose your AI service provider",
                color: .purple,
                shape: .circle
            )
            
            // Provider Picker
            Picker("Provider", selection: $config.provider) {
                ForEach(AIConfig.AIProvider.allCases) { provider in
                    HStack {
                        Image(systemName: providerIcon(provider))
                        Text(provider.rawValue)
                    }
                    .tag(provider)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("AI Provider")
            .accessibilityHint("Select the AI service provider to use")
            
            // Provider-specific info
            providerInfoCard
            
            // API Key field (for non-local providers)
            if config.provider != .ollama {
                apiKeyField
            }
            
            // Base URL field (for Ollama)
            if config.provider == .ollama {
                baseURLField
            }
        }
    }
    
    private var providerInfoCard: some View {
        HStack(spacing: 12) {
            Image(systemName: providerInfoIcon)
                .font(.title3)
                .foregroundStyle(providerInfoColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(providerInfoTitle)
                    .font(.subheadline.weight(.medium))
                
                Text(providerInfoDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(providerInfoColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(providerInfoColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var apiKeyField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("API Key", systemImage: "key")
                .font(.subheadline.weight(.medium))
            
            SecureField("Enter your API key", text: Binding(
                get: { config.apiKey ?? "" },
                set: { config.apiKey = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .accessibilityLabel("API Key")
            .accessibilityHint("Enter your \(config.provider.rawValue) API key")
            
            Text("Your API key is stored securely and never shared")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
    
    private var baseURLField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Base URL", systemImage: "link")
                .font(.subheadline.weight(.medium))
            
            TextField("http://localhost:11434", text: $config.baseURL)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Base URL")
                .accessibilityHint("Enter the Ollama server URL")
            
            Text("Default: http://localhost:11434")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
    
    // MARK: - Model Section
    
    private var modelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Model Configuration",
                icon: "brain",
                description: "Select and configure the AI model",
                color: .cyan,
                shape: .roundedSquare
            )
            
            // Model name field
            VStack(alignment: .leading, spacing: 8) {
                Label("Model", systemImage: "cube")
                    .font(.subheadline.weight(.medium))
                
                TextField(modelPlaceholder, text: $config.model)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel("Model name")
                    .accessibilityHint("Enter the model identifier")
                
                Text(modelHint)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    // MARK: - Advanced Section
    
    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Advanced Settings",
                icon: "slider.horizontal.3",
                description: "Fine-tune model behavior",
                color: .orange,
                shape: .capsule
            )
            
            // Temperature Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Temperature", systemImage: "thermometer.medium")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                    
                    Text(String(format: "%.2f", config.temperature))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
                
                Slider(value: $config.temperature, in: 0.0...2.0, step: 0.1)
                    .accessibilityLabel("Temperature")
                    .accessibilityValue(String(format: "%.2f", config.temperature))
                    .accessibilityHint("Adjust the randomness of responses. Lower values are more focused, higher values are more creative")
                
                HStack {
                    Text("Focused")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("Creative")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Text("Controls randomness. Lower values (0.0-0.5) are more focused and deterministic. Higher values (1.0-2.0) are more creative and varied.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Max Tokens Stepper
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Max Tokens", systemImage: "text.alignleft")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                    
                    Text("\(config.maxTokens)")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
                
                Stepper(
                    value: $config.maxTokens,
                    in: 256...8192,
                    step: 256
                ) {
                    EmptyView()
                }
                .accessibilityLabel("Max Tokens")
                .accessibilityValue("\(config.maxTokens)")
                .accessibilityHint("Adjust the maximum length of responses")
                
                HStack(spacing: 16) {
                    Button("256") { config.maxTokens = 256 }
                        .buttonStyle(PresetButtonStyle(isSelected: config.maxTokens == 256))
                        .accessibilityLabel("Set max tokens to 256")
                    
                    Button("1024") { config.maxTokens = 1024 }
                        .buttonStyle(PresetButtonStyle(isSelected: config.maxTokens == 1024))
                        .accessibilityLabel("Set max tokens to 1024")
                    
                    Button("2048") { config.maxTokens = 2048 }
                        .buttonStyle(PresetButtonStyle(isSelected: config.maxTokens == 2048))
                        .accessibilityLabel("Set max tokens to 2048")
                    
                    Button("4096") { config.maxTokens = 4096 }
                        .buttonStyle(PresetButtonStyle(isSelected: config.maxTokens == 4096))
                        .accessibilityLabel("Set max tokens to 4096")
                }
                .font(.caption)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Max tokens presets")
                
                Text("Maximum length of AI responses. Higher values allow longer responses but may be slower.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack(spacing: 12) {
            // Reset to defaults button
            Button {
                resetToDefaults()
            } label: {
                Text("Reset to Defaults")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Reset all settings to default values")
            .accessibilityLabel("Reset to Defaults")
            .accessibilityHint("Reset all settings to their default values")
            
            Spacer()
            
            // Cancel button
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .frame(minWidth: 80)
            }
            .buttonStyle(.bordered)
            .help("Discard changes")
            .accessibilityLabel("Cancel")
            .accessibilityHint("Discard changes and close settings")
            
            // Save button
            Button {
                saveSettings()
            } label: {
                Text("Save")
                    .frame(minWidth: 80)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!hasChanges)
            .help(hasChanges ? "Save settings" : "No changes to save")
            .accessibilityLabel("Save")
            .accessibilityHint(hasChanges ? "Save settings and close" : "No changes to save")
        }
        .padding(24)
    }
    
    // MARK: - Helper Views
    
    enum SectionShape {
        case circle
        case roundedSquare
        case capsule
        case fill
        case outline
    }
    
    @ViewBuilder
    private func shapeView(shape: SectionShape, size: CGFloat, color: Color, style: ShapeStyle) -> some View {
        switch shape {
        case .circle:
            if style == .fill {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: size, height: size)
            } else {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 1)
                    .frame(width: size, height: size)
            }
        case .roundedSquare:
            if style == .fill {
                RoundedRectangle(cornerRadius: size * 0.25)
                    .fill(color.opacity(0.15))
                    .frame(width: size, height: size)
            } else {
                RoundedRectangle(cornerRadius: size * 0.25)
                    .stroke(color.opacity(0.3), lineWidth: 1)
                    .frame(width: size, height: size)
            }
        case .capsule:
            if style == .fill {
                Capsule()
                    .fill(color.opacity(0.15))
                    .frame(width: size * 1.2, height: size)
            } else {
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: 1)
                    .frame(width: size * 1.2, height: size)
            }
        case .fill, .outline:
            EmptyView()
        }
    }
    
    enum ShapeStyle {
        case fill
        case outline
    }
    
    private func sectionHeader(
        title: String,
        icon: String,
        description: String,
        color: Color = .purple,
        shape: SectionShape = .roundedSquare
    ) -> some View {
        HStack(spacing: 14) {
            // Icon with colored shape background
            ZStack {
                shapeView(shape: shape, size: 40, color: color, style: .fill)
                shapeView(shape: shape, size: 40, color: color, style: .outline)
                
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveSettings() {
        config.save()
        hasChanges = false
        
        // Show confirmation (optional)
        // Could add a toast notification here
        
        dismiss()
    }
    
    private func resetToDefaults() {
        config = AIConfig()
        hasChanges = true
    }
    
    // MARK: - Computed Properties
    
    private func providerIcon(_ provider: AIConfig.AIProvider) -> String {
        switch provider {
        case .ollama: return "cpu"
        case .openai: return "cloud"
        case .anthropic: return "brain"
        }
    }
    
    private var providerInfoIcon: String {
        switch config.provider {
        case .ollama: return "lock.shield"
        case .openai: return "cloud"
        case .anthropic: return "cloud"
        }
    }
    
    private var providerInfoColor: Color {
        switch config.provider {
        case .ollama: return .green
        case .openai: return .blue
        case .anthropic: return .purple
        }
    }
    
    private var providerInfoTitle: String {
        switch config.provider {
        case .ollama: return "Local & Private"
        case .openai: return "Cloud-based"
        case .anthropic: return "Cloud-based"
        }
    }
    
    private var providerInfoDescription: String {
        switch config.provider {
        case .ollama:
            return "Runs entirely on your device. No data leaves your machine. Requires Ollama to be installed and running."
        case .openai:
            return "Powered by OpenAI's GPT models. Requires an API key and internet connection."
        case .anthropic:
            return "Powered by Anthropic's Claude models. Requires an API key and internet connection."
        }
    }
    
    private var modelPlaceholder: String {
        switch config.provider {
        case .ollama: return "llama3.2"
        case .openai: return "gpt-4"
        case .anthropic: return "claude-3-sonnet-20240229"
        }
    }
    
    private var modelHint: String {
        switch config.provider {
        case .ollama:
            return "Examples: llama3.2, mistral, codellama"
        case .openai:
            return "Examples: gpt-4, gpt-4-turbo, gpt-3.5-turbo"
        case .anthropic:
            return "Examples: claude-3-opus-20240229, claude-3-sonnet-20240229"
        }
    }
}

// MARK: - Preset Button Style

struct PresetButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
