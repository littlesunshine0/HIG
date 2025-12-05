//
//  AnimationLabView.swift
//  SpatialViews
//
//  A modern animation controller, browser, catalog, and builder/editor experience
//

import SwiftUI
import Combine

// MARK: - Missing Helpers & Extensions

private struct CubicBezierTimingFunction {
    let c1: CGPoint
    let c2: CGPoint
}

extension Animation {
    
    
    @MainActor
    static func pulse(times: Int, interval: Double, forward: @escaping () -> Void, reverse: @escaping () -> Void) async {
        guard times > 0 else { return }
        for i in 0..<times {
            withAnimation(.easeInOut(duration: interval)) { forward() }
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            withAnimation(.easeInOut(duration: interval)) { reverse() }
            if i < times - 1 {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    // MARK: - Animation Model
    
    struct AnimationPreset: Identifiable, Hashable {
        enum Category: String, CaseIterable, Identifiable {
            case springs = "Springs"
            case easing = "Easing"
            case utility = "Utility"
            
            var id: String { rawValue }
            var icon: String {
                switch self {
                case .springs: return "waveform"
                case .easing: return "chart.line.uptrend.xyaxis"
                case .utility: return "gearshape"
                }
            }
        }
        
        let id = UUID()
        let name: String
        let subtitle: String
        let category: Category
        let icon: String
        let build: (_ settings: AnimationBuilderSettings) -> Animation
        
        var accentColor: Color {
#if os(macOS)
            switch category {
            case .springs: return Color.orange.opacity(0.95)
            case .easing: return Color.purple.opacity(0.9)
            case .utility: return Color.cyan.opacity(0.95)
            }
#else
            switch category {
            case .springs: return .teal
            case .easing: return .purple
            case .utility: return .orange
            }
#endif
        }
        
        static func == (lhs: AnimationPreset, rhs: AnimationPreset) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    struct AnimationBuilderSettings: Hashable {
        var duration: Double = 0.6
        var response: Double = 0.4
        var damping: Double = 0.85
        var blendDuration: Double = 0.2
        var autoreverse: Bool = false
        var repeatCount: Int = 0
        var useSpring: Bool = true
        
        func resolvedAnimation(base: Animation) -> Animation {
            var animation = base
            if repeatCount > 0 {
                animation = animation.repeatCount(repeatCount, autoreverses: autoreverse)
            }
            return animation
        }
        
        func springAnimation() -> Animation {
            .spring(response: response, dampingFraction: damping, blendDuration: blendDuration)
        }
    }
    
    // MARK: - Catalog
    
    enum AnimationCatalog {
        static let presets: [AnimationPreset] = [
            .init(
                name: "Smooth Spring",
                subtitle: "Balanced, friendly damping",
                category: .springs,
                icon: "sparkles",
                build: { settings in settings.resolvedAnimation(base: settings.springAnimation()) }
            ),
            .init(
                name: "Snappy",
                subtitle: "Fast response, crisp feel",
                category: .springs,
                icon: "bolt.fill",
                build: { settings in
                    var tuned = settings
                    tuned.response = 0.28
                    tuned.damping = 0.82
                    return tuned.resolvedAnimation(base: tuned.springAnimation())
                }
            ),
            .init(
                name: "Bouncy",
                subtitle: "Playful overshoot",
                category: .springs,
                icon: "circle.dashed",
                build: { settings in
                    var tuned = settings
                    tuned.response = 0.55
                    tuned.damping = 0.6
                    tuned.blendDuration = 0.25
                    return tuned.resolvedAnimation(base: tuned.springAnimation())
                }
            ),
            .init(
                name: "Heavy",
                subtitle: "Weighty settle",
                category: .springs,
                icon: "hammer.fill",
                build: { settings in
                    var tuned = settings
                    tuned.response = 0.7
                    tuned.damping = 0.72
                    tuned.blendDuration = 0.28
                    return tuned.resolvedAnimation(base: tuned.springAnimation())
                }
            ),
            .init(
                name: "Ease Out Expo",
                subtitle: "Energy quickly dissipates",
                category: .easing,
                icon: "arrow.right.to.line",
                build: { settings in
                    let base = Animation.easeOutExpo(duration: settings.duration)
                    return settings.resolvedAnimation(base: base)
                }
            ),
            .init(
                name: "Ease Out Circ",
                subtitle: "Rolling to a stop",
                category: .easing,
                icon: "circle.lefthalf.filled",
                build: { settings in settings.resolvedAnimation(base: .easeOutCirc(duration: settings.duration)) }
            ),
            .init(
                name: "Ease Out Back",
                subtitle: "Subtle overshoot",
                category: .easing,
                icon: "arrow.uturn.backward",
                build: { settings in settings.resolvedAnimation(base: .easeOutBack(duration: settings.duration)) }
            ),
            .init(
                name: "Looper",
                subtitle: "Repeat forever",
                category: .utility,
                icon: "arrow.2.circlepath",
                build: { settings in .looping(duration: max(0.6, settings.duration), autoreverses: settings.autoreverse) }
            ),
            .init(
                name: "Delayed",
                subtitle: "Useful for choreography",
                category: .utility,
                icon: "timer",
                build: { settings in settings.resolvedAnimation(base: .default.delayed(0.2)) }
            )
        ]
    }
    
    // MARK: - Controller
    
    final class AnimationController: ObservableObject {
        @Published var selectedPreset: AnimationPreset = AnimationCatalog.presets.first! {
            didSet {
                if selectedPreset.category == .springs {
                    settings.useSpring = true
                } else if selectedPreset.category == .utility {
                    settings.useSpring = false
                }
            }
        }
        @Published var settings = AnimationBuilderSettings()
        @Published var previewScale: CGFloat = 1.0
        @Published var previewOpacity: Double = 1.0
        @Published var previewRotation: Double = 0
        @Published var previewOffset: CGFloat = 0
        @Published var scrubProgress: Double = 0
        
        func triggerPreview() {
            let animation = resolvedAnimation
            withAnimation(animation) {
                previewScale = previewScale == 1.0 ? 1.18 : 1.0
                previewOpacity = previewOpacity == 1.0 ? 0.65 : 1.0
                previewRotation = previewRotation == 0 ? 24 : 0
                previewOffset = previewOffset == 0 ? 18 : 0
                scrubProgress = scrubProgress == 0 ? 1.0 : 0
            }
        }
        
        func resetPreview() {
            AnimTransaction.withoutAnimation {
                previewScale = 1.0
                previewOpacity = 1.0
                previewRotation = 0
                previewOffset = 0
                scrubProgress = 0
            }
        }
        
        func scrub(to progress: Double) {
            let clamped = max(0, min(progress, 1))
            scrubProgress = clamped
            AnimTransaction.withoutAnimation {
                previewScale = 1.0 + (0.2 * clamped)
                previewOpacity = 0.6 + (0.4 * (1 - clamped/2))
                previewRotation = 36 * clamped
                previewOffset = 18 * clamped
            }
        }
        
        var resolvedAnimation: Animation {
            selectedPreset.build(settings)
        }
    }
    
    // MARK: - Views
    
    struct AnimationLabView: View {
        @StateObject private var controller = AnimationController()
        @State private var selectedCategory: AnimationPreset.Category = .springs
        
        private struct LayoutProfile {
            var horizontalPadding: CGFloat
            var sectionSpacing: CGFloat
            var previewHeight: CGFloat
            var usesCompactHeader: Bool
        }
        
        private func layoutProfile(for width: CGFloat) -> LayoutProfile {
            let isCompact = width < 700
            let isPhoneWidth = width < 520
            let previewHeight: CGFloat
            
            if isPhoneWidth {
                previewHeight = 180
            } else if width < 880 {
                previewHeight = 200
            } else {
                previewHeight = 220
            }
            
            return LayoutProfile(
                horizontalPadding: isCompact ? 16 : 24,
                sectionSpacing: isCompact ? 16 : 24,
                previewHeight: previewHeight,
                usesCompactHeader: isCompact
            )
        }
        
        var body: some View {
            GeometryReader { proxy in
                let width = proxy.size.width
                let layout = layoutProfile(for: width)
                
                ScrollView {
                    VStack(spacing: layout.sectionSpacing) {
                        header(width: width, usesCompactHeader: layout.usesCompactHeader)
                        preview(width: width, preferredHeight: layout.previewHeight)
                        controllerPanel(width: width)
                        catalogGrid(width: width)
                        builderEditor(width: width)
                    }
                    .padding(.horizontal, layout.horizontalPadding)
                    .padding(.vertical, width < 700 ? 18 : 24)
                    .frame(maxWidth: 1200)
                    .frame(maxWidth: .infinity)
                }
                .background(
                    {
#if os(macOS)
                        LinearGradient(
                            colors: [Color(NSColor.windowBackgroundColor), Color(NSColor.controlBackgroundColor)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
#else
                        LinearGradient(
                            colors: [Color(.secondarySystemBackground), Color(.systemGray6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
#endif
                    }()
                )
            }
        }
        
        private func header(width: CGFloat, usesCompactHeader: Bool) -> some View {
            VStack(alignment: .leading, spacing: usesCompactHeader ? 8 : 10) {
                if usesCompactHeader {
                    VStack(alignment: .leading, spacing: 12) {
                        headerTitle
                        chipRow
                    }
                } else {
                    HStack(alignment: .top, spacing: 12) {
                        headerTitle
                        Spacer(minLength: 8)
                        chipRow
                    }
                }
                
                Divider().opacity(0.4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        statBlock(title: "Presets", value: "\(AnimationCatalog.presets.count)")
                        statBlock(title: "Spring defaults", value: "\(AnimationCatalog.presets.filter { $0.category == .springs }.count)")
                        statBlock(title: "Easing", value: "\(AnimationCatalog.presets.filter { $0.category == .easing }.count)")
                        statBlock(title: "Utility", value: "\(AnimationCatalog.presets.filter { $0.category == .utility }.count)")
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        
        private var headerTitle: some View {
            VStack(alignment: .leading, spacing: 6) {
                Label("Animation Lab", systemImage: "rectangle.on.rectangle.angled")
                    .font(.title.bold())
                Text("A modern controller, browser, catalog, and builder for motion presets across platforms.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
        
        private var chipRow: some View {
            HStack(spacing: 8) {
                TagChip(title: "Live Preview", icon: "sparkles")
                TagChip(title: "Scrubbable", icon: "timeline.selection")
                TagChip(title: "Adaptive", icon: "square.stack.3d.up")
            }
        }
        
        private func preview(width: CGFloat, preferredHeight: CGFloat) -> some View {
            VStack(spacing: 16) {
                let leadColor: Color = {
#if os(macOS)
                    return Color.blue.opacity(0.65)
#else
                    return Color(.systemIndigo)
#endif
                }()
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: width < 500 ? 18 : 24)
                        .fill(LinearGradient(colors: [leadColor, controller.selectedPreset.accentColor], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: preferredHeight)
                        .overlay(
                            AngularGradient(colors: [.white.opacity(0.2), .clear, .white.opacity(0.12)], center: .center)
                                .blendMode(.overlay)
                        )
                        .scaleEffect(controller.previewScale)
                        .opacity(controller.previewOpacity)
                        .rotationEffect(.degrees(controller.previewRotation))
                        .offset(x: controller.previewOffset)
                        .shadow(color: controller.selectedPreset.accentColor.opacity(0.35), radius: 24, y: 12)
                        .animation(controller.resolvedAnimation, value: controller.previewScale)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TagChip(title: controller.selectedPreset.category.rawValue, icon: controller.selectedPreset.category.icon)
                            .padding(.top, 12)
                        Text(controller.selectedPreset.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(controller.selectedPreset.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(16)
                }
                
                VStack(spacing: 12) {
                    ViewThatFits {
                        HStack(spacing: 12) {
                            previewPrimaryActions
                            Spacer(minLength: 8)
                            previewMenu
                        }
                        VStack(spacing: 10) {
                            previewPrimaryActions
                            previewMenu.frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Scrub live timeline", systemImage: "timeline.selection")
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(String(format: "%.0f%%", controller.scrubProgress * 100))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: Binding(
                            get: { controller.scrubProgress },
                            set: { controller.scrub(to: $0) }
                        ), in: 0...1)
                        .tint(controller.selectedPreset.accentColor)
                    }
                }
            }
            .padding()
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        
        private var previewPrimaryActions: some View {
            HStack(spacing: 12) {
                Button {
                    controller.triggerPreview()
                } label: {
                    Label("Play Animation", systemImage: "play.fill")
                }
#if os(macOS)
                .buttonStyle(.bordered)
                .controlSize(.large)
#else
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .controlProminence(.increased)
#endif
                
                Button {
                    controller.resetPreview()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
#if os(macOS)
                .buttonStyle(.bordered)
                .controlSize(.large)
#else
                .buttonStyle(.bordered)
                .controlSize(.regular)
#endif
            }
        }
        
        private var previewMenu: some View {
            Menu {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(AnimationPreset.Category.allCases) { category in
                        Label(category.rawValue, systemImage: category.icon)
                            .tag(category)
                    }
                }
            } label: {
                Label(selectedCategory.rawValue, systemImage: selectedCategory.icon)
            }
        }
        
        private func controllerPanel(width: CGFloat) -> some View {
            VStack(alignment: .leading, spacing: 14) {
                ViewThatFits {
                    HStack(alignment: .top) {
                        controllerHeader
                        Spacer()
                        TagChip(title: "Realtime", icon: "bolt.horizontal")
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        controllerHeader
                        TagChip(title: "Realtime", icon: "bolt.horizontal")
                    }
                }
                
                let controlColumns = [GridItem(.adaptive(minimum: width < 520 ? 140 : 170), spacing: 12)]
                LazyVGrid(columns: controlColumns, spacing: 12) {
                    controllerToggle(title: "Fade", icon: "circle.lefthalf.filled") {
                        controller.previewOpacity = controller.previewOpacity < 1.0 ? 1.0 : 0.65
                    }
                    controllerToggle(title: "Scale", icon: "arrow.up.left.and.down.right.magnifyingglass") {
                        controller.previewScale = controller.previewScale == 1.0 ? 1.18 : 1.0
                    }
                    controllerToggle(title: "Offset", icon: "arrow.left.and.right") {
                        controller.previewOffset = controller.previewOffset == 0 ? 18 : 0
                    }
                    controllerToggle(title: "Rotate", icon: "arrow.triangle.2.circlepath") {
                        controller.previewRotation = controller.previewRotation == 0 ? 36 : 0
                    }
                    controllerToggle(title: "Glow", icon: "light.max") {
                        controller.previewOpacity = controller.previewOpacity == 1.0 ? 0.8 : 1.0
                    }
                    Button {
                        Task { @MainActor in
                            await Animator.pulse(times: 2, interval: 0.18, forward: { controller.previewScale = 1.22 }, reverse: { controller.previewScale = 1.0 })
                        }
                    } label: {
                        Label("Pulse x2", systemImage: "waveform")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        
        private var controllerHeader: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Modern Animation Controller")
                    .font(.headline)
                Text("Stack multiple properties, toggle interactions, and keep the preview in sync.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        
        private func catalogGrid(width: CGFloat) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Animation Browser & Catalog")
                        .font(.headline)
                    Spacer()
                }
                Picker("Category", selection: $selectedCategory) {
                    ForEach(AnimationPreset.Category.allCases) { category in
                        Label(category.rawValue, systemImage: category.icon)
                            .tag(category)
                    }
                }
                .pickerStyle(.segmented)
                
                let minWidth: CGFloat = width < 520 ? 160 : 220
                LazyVGrid(columns: [GridItem(.adaptive(minimum: minWidth), spacing: 12)], spacing: 12) {
                    ForEach(AnimationCatalog.presets.filter { $0.category == selectedCategory }) { preset in
                        AnimationPresetCard(preset: preset, isSelected: controller.selectedPreset == preset) {
                            controller.selectedPreset = preset
                            controller.triggerPreview()
                        }
                    }
                }
            }
        }
        
        private func controllerToggle(title: String, icon: String, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                    Text(title)
                    Spacer()
                }
                .padding(.horizontal, 6)
            }
            .buttonStyle(.bordered)
        }
        
        private func statBlock(title: String, value: String) -> some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        
        private func builderEditor(width: CGFloat) -> some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Builder & Editor")
                    .font(.headline)
                Text("Fine-tune duration, damping, repetition, and sequencing without leaving the lab. Mix springs with timing curves.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 12) {
                    Toggle(isOn: $controller.settings.useSpring) {
                        Label("Use Spring", systemImage: "waveform")
                    }
#if os(macOS)
                    .toggleStyle(.checkbox)
#else
                    .toggleStyle(.switch)
#endif
                    
                    if controller.selectedPreset.category == .utility {
                        Text("Utility presets favor duration-based timing. Spring tuning is disabled for these.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if controller.selectedPreset.category == .easing && controller.settings.useSpring {
                        Text("Easing presets can still use spring timing when you toggle it on.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if controller.selectedPreset.category == .springs && !controller.settings.useSpring {
                        Text("Spring presets sound better with spring timing enabled. Toggle it back on for authentic feel.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if controller.settings.useSpring {
                        adaptiveSpringSliders(width: width)
                    } else {
                        LabeledSlider(title: "Duration", value: $controller.settings.duration, range: 0.2...2.0, format: "%.2fs")
                    }
                    
                    HStack(alignment: .center) {
                        Stepper(value: $controller.settings.repeatCount, in: 0...6) {
                            Label("Repeat x\(controller.settings.repeatCount)", systemImage: "arrow.triangle.2.circlepath")
                        }
                        Spacer(minLength: 8)
                        Toggle("Autoreverse", isOn: $controller.settings.autoreverse)
#if os(macOS)
                            .toggleStyle(.checkbox)
#else
                            .toggleStyle(.switch)
#endif
                            .frame(maxWidth: width < 520 ? .infinity : nil, alignment: .leading)
                    }
                    
                    Divider().opacity(0.4)
                    
                    ViewThatFits {
                        HStack(spacing: 12) {
                            builderPrimaryActions
                            Spacer(minLength: 8)
                            sequenceButton
                        }
                        VStack(spacing: 10) {
                            builderPrimaryActions
                            sequenceButton
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                )
            }
        }
        
        private func adaptiveSpringSliders(width: CGFloat) -> some View {
            VStack(spacing: 8) {
                if width < 700 {
                    VStack(spacing: 8) {
                        LabeledSlider(title: "Response", value: $controller.settings.response, range: 0.1...1.0, format: "%.2f")
                        LabeledSlider(title: "Damping", value: $controller.settings.damping, range: 0.3...1.2, format: "%.2f")
                    }
                } else {
                    HStack(spacing: 12) {
                        LabeledSlider(title: "Response", value: $controller.settings.response, range: 0.1...1.0, format: "%.2f")
                        LabeledSlider(title: "Damping", value: $controller.settings.damping, range: 0.3...1.2, format: "%.2f")
                    }
                }
                LabeledSlider(title: "Blend", value: $controller.settings.blendDuration, range: 0...0.6, format: "%.2f")
            }
        }
        
        private var builderPrimaryActions: some View {
            Button("Apply & Preview") {
                controller.triggerPreview()
            }
#if os(macOS)
            .buttonStyle(.bordered)
            .controlSize(.large)
#else
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .controlProminence(.increased)
#endif
        }
        
        private var sequenceButton: some View {
            Button("Sequence: Fade > Scale > Rest") {
                Task { @MainActor in
                    await Animator.sequence([
                        Animator.Step(animation: .easeOutCirc(duration: 0.35), duration: 0.35) {
                            controller.previewOpacity = 1.0
                        },
                        Animator.Step(animation: .bouncySpring, duration: 0.28, delayAfter: 0.05) {
                            controller.previewScale = 1.14
                        },
                        Animator.Step(animation: .smoothSpring, duration: 0.24) {
                            controller.previewScale = 1.0
                        }
                    ])
                }
            }
#if os(macOS)
            .buttonStyle(.bordered)
            .controlSize(.regular)
#else
            .buttonStyle(.bordered)
            .controlSize(.regular)
#endif
        }
    }
    
    private struct AnimationPresetCard: View {
        let preset: AnimationPreset
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: preset.icon)
                            .foregroundStyle(preset.accentColor)
                        Text(preset.name)
                            .font(.headline)
                        Spacer()
                    }
                    Text(preset.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack {
                        Label(preset.category.rawValue, systemImage: preset.category.icon)
                            .font(.caption)
                            .foregroundStyle(preset.accentColor)
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [preset.accentColor.opacity(isSelected ? 0.18 : 0.08), Color.secondary.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct TagChip: View {
        let title: String
        let icon: String
        
        var body: some View {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.thinMaterial, in: Capsule())
        }
    }
    
    private struct LabeledSlider: View {
        let title: String
        @Binding var value: Double
        let range: ClosedRange<Double>
        let format: String
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                    Spacer()
                    Text(String(format: format, value))
                        .foregroundStyle(.secondary)
                }
                Slider(value: $value, in: range)
            }
        }
    }
    
    #Preview("Animation Lab") {
        AnimationLabView()
            .frame(width: 900, height: 1000)
#if os(macOS)
            .background(Color(NSColor.windowBackgroundColor))
#else
            .background(Color(.systemGroupedBackground))
#endif
    }
}
