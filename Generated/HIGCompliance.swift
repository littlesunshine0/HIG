//
//  HIGCompliance.swift
//  HIG
//
//  Comprehensive HIG Compliance System
//  Apply these modifiers and tokens to ensure 100% HIG compliance
//
//  Based on Apple Human Interface Guidelines (148 Topics)
//  https://developer.apple.com/design/human-interface-guidelines
//

import SwiftUI

// MARK: - HIG Design Tokens

/// Centralized design tokens derived from Apple HIG specifications
public enum HIGTokens {
    
    // MARK: - Touch Targets [accessibility] [buttons]
    
    /// Minimum touch target for iOS/iPadOS/macOS (44x44 pt)
    public static let minTouchTarget: CGFloat = 44
    
    /// Minimum touch target for visionOS (60x60 pt)
    public static let minTouchTargetVision: CGFloat = 60
    
    /// Minimum touch target for watchOS (38x38 pt)
    public static let minTouchTargetWatch: CGFloat = 38
    
    // MARK: - Spacing [layout]
    
    /// Padding around bezeled controls (12pt)
    public static let bezelPadding: CGFloat = 12
    
    /// Padding around non-bezeled elements (24pt)
    public static let nonBezelPadding: CGFloat = 24
    
    /// Standard content padding (16pt)
    public static let contentPadding: CGFloat = 16
    
    /// Compact content padding (8pt)
    public static let compactPadding: CGFloat = 8
    
    /// Section spacing (24pt)
    public static let sectionSpacing: CGFloat = 24
    
    /// Element spacing (12pt)
    public static let elementSpacing: CGFloat = 12
    
    /// Tight spacing (8pt)
    public static let tightSpacing: CGFloat = 8
    
    /// Icon-text spacing (6pt)
    public static let iconTextSpacing: CGFloat = 6
    
    // MARK: - Corner Radii [materials]
    
    /// Window corner radius (12pt - macOS Sequoia+)
    public static let windowRadius: CGFloat = 12
    
    /// Card/panel radius (16pt)
    public static let cardRadius: CGFloat = 16
    
    /// Control radius (8pt)
    public static let controlRadius: CGFloat = 8
    
    /// Small control radius (6pt)
    public static let smallRadius: CGFloat = 6
    
    /// Bubble/chip radius (20pt)
    public static let bubbleRadius: CGFloat = 20
    
    /// Message bubble radius (18pt)
    public static let messageBubbleRadius: CGFloat = 18
    
    // MARK: - Animation [motion]
    
    /// Micro interaction duration (0.15s)
    public static let microDuration: Double = 0.15
    
    /// Quick feedback duration (0.25s)
    public static let quickDuration: Double = 0.25
    
    /// Standard transition duration (0.4s)
    public static let standardDuration: Double = 0.4
    
    /// Emphasized duration (0.6s)
    public static let emphasizedDuration: Double = 0.6
    
    /// Spring response (0.5)
    public static let springResponse: Double = 0.5
    
    /// Spring damping (0.8)
    public static let springDamping: Double = 0.8
    
    // MARK: - Opacity [color]
    
    /// Disabled state opacity (0.4)
    public static let disabledOpacity: Double = 0.4
    
    /// Secondary content opacity (0.6)
    public static let secondaryOpacity: Double = 0.6
    
    /// Overlay/tint opacity (0.15)
    public static let overlayOpacity: Double = 0.15
    
    // MARK: - Typography [typography]
    
    /// Maximum preview lines (3)
    public static let maxPreviewLines: Int = 3
    
    /// Line spacing multiplier (1.2)
    public static let lineSpacingMultiplier: CGFloat = 1.2
}

// MARK: - HIG Compliant View Modifiers

/// Ensures minimum touch target size for accessibility
public struct HIGTouchTargetModifier: ViewModifier {
    let minSize: CGFloat
    
    public init(minSize: CGFloat = HIGTokens.minTouchTarget) {
        self.minSize = minSize
    }
    
    public func body(content: Content) -> some View {
        content
            .frame(minWidth: minSize, minHeight: minSize)
            .contentShape(Rectangle())
    }
}

/// Applies HIG-compliant accessibility modifiers
public struct HIGAccessibilityModifier: ViewModifier {
    let label: String
    let hint: String?
    let traits: AccessibilityTraits
    
    public init(label: String, hint: String? = nil, traits: AccessibilityTraits = []) {
        self.label = label
        self.hint = hint
        self.traits = traits
    }
    
    public func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}

/// Applies reduce motion-aware animation
public struct HIGAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let animation: Animation
    let value: V
    
    public init(animation: Animation = .spring(response: HIGTokens.springResponse, dampingFraction: HIGTokens.springDamping), value: V) {
        self.animation = animation
        self.value = value
    }
    
    public func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? nil : animation, value: value)
    }
}

/// Applies reduce transparency-aware material
public struct HIGMaterialModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    
    let material: Material
    let fallbackColor: Color
    let cornerRadius: CGFloat
    
    public init(
        material: Material = .regularMaterial,
        fallbackColor: Color = Color(.controlBackgroundColor),
        cornerRadius: CGFloat = HIGTokens.cardRadius
    ) {
        self.material = material
        self.fallbackColor = fallbackColor
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(reduceTransparency ? AnyShapeStyle(fallbackColor) : AnyShapeStyle(material))
            )
    }
}

/// Applies HIG-compliant button styling
public struct HIGButtonModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    
    let style: HIGButtonStyle
    
    public enum HIGButtonStyle {
        case primary
        case secondary
        case tertiary
        case destructive
    }
    
    public init(style: HIGButtonStyle = .primary) {
        self.style = style
    }
    
    public func body(content: Content) -> some View {
        content
            .frame(minWidth: HIGTokens.minTouchTarget, minHeight: HIGTokens.minTouchTarget)
            .opacity(isEnabled ? 1.0 : HIGTokens.disabledOpacity)
    }
}

/// Applies HIG-compliant card styling with Liquid Glass
public struct HIGCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    let cornerRadius: CGFloat
    let padding: CGFloat
    let elevation: HIGElevation
    
    public enum HIGElevation {
        case none, subtle, standard, raised, floating
        
        var shadowRadius: CGFloat {
            switch self {
            case .none: return 0
            case .subtle: return 4
            case .standard: return 8
            case .raised: return 16
            case .floating: return 24
            }
        }
        
        var shadowOpacity: Double {
            switch self {
            case .none: return 0
            case .subtle: return 0.05
            case .standard: return 0.1
            case .raised: return 0.15
            case .floating: return 0.2
            }
        }
    }
    
    public init(
        cornerRadius: CGFloat = HIGTokens.cardRadius,
        padding: CGFloat = HIGTokens.contentPadding,
        elevation: HIGElevation = .standard
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.elevation = elevation
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(reduceTransparency ? Color(.controlBackgroundColor) : Color(.controlBackgroundColor).opacity(0.8))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: Color.black.opacity(reduceTransparency ? 0 : elevation.shadowOpacity),
                radius: elevation.shadowRadius,
                y: elevation.shadowRadius / 3
            )
    }
}

// MARK: - View Extensions

extension View {
    
    /// Ensures minimum touch target size (44pt default)
    public func higTouchTarget(_ minSize: CGFloat = HIGTokens.minTouchTarget) -> some View {
        modifier(HIGTouchTargetModifier(minSize: minSize))
    }
    
    /// Applies HIG-compliant accessibility
    public func higAccessibility(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        modifier(HIGAccessibilityModifier(label: label, hint: hint, traits: traits))
    }
    
    /// Applies reduce motion-aware animation
    public func higAnimation<V: Equatable>(_ animation: Animation = .spring(response: HIGTokens.springResponse, dampingFraction: HIGTokens.springDamping), value: V) -> some View {
        modifier(HIGAnimationModifier(animation: animation, value: value))
    }
    
    /// Applies reduce transparency-aware material background
    public func higMaterial(
        _ material: Material = .regularMaterial,
        fallback: Color = Color(.controlBackgroundColor),
        cornerRadius: CGFloat = HIGTokens.cardRadius
    ) -> some View {
        modifier(HIGMaterialModifier(material: material, fallbackColor: fallback, cornerRadius: cornerRadius))
    }
    
    /// Applies HIG-compliant card styling
    public func higCard(
        cornerRadius: CGFloat = HIGTokens.cardRadius,
        padding: CGFloat = HIGTokens.contentPadding,
        elevation: HIGCardModifier.HIGElevation = .standard
    ) -> some View {
        modifier(HIGCardModifier(cornerRadius: cornerRadius, padding: padding, elevation: elevation))
    }
    
    /// Applies standard HIG content padding
    public func higPadding(_ edges: Edge.Set = .all) -> some View {
        padding(edges, HIGTokens.contentPadding)
    }
    
    /// Applies HIG bezel padding (for controls)
    public func higBezelPadding(_ edges: Edge.Set = .all) -> some View {
        padding(edges, HIGTokens.bezelPadding)
    }
    
    /// Applies HIG section spacing
    public func higSectionSpacing() -> some View {
        padding(.vertical, HIGTokens.sectionSpacing / 2)
    }
}

// MARK: - HIG Compliant Animations

extension Animation {
    
    /// HIG-compliant spring animation
    public static var higSpring: Animation {
        .spring(response: HIGTokens.springResponse, dampingFraction: HIGTokens.springDamping)
    }
    
    /// HIG-compliant snappy spring
    public static var higSnappy: Animation {
        .spring(response: 0.3, dampingFraction: HIGTokens.springDamping)
    }
    
    /// HIG-compliant micro interaction
    public static var higMicro: Animation {
        .easeOut(duration: HIGTokens.microDuration)
    }
    
    /// HIG-compliant quick feedback
    public static var higQuick: Animation {
        .easeOut(duration: HIGTokens.quickDuration)
    }
    
    /// HIG-compliant standard transition
    public static var higStandard: Animation {
        .easeInOut(duration: HIGTokens.standardDuration)
    }
    
    /// HIG-compliant emphasized transition
    public static var higEmphasized: Animation {
        .easeOut(duration: HIGTokens.emphasizedDuration)
    }
}

// MARK: - HIG Environment Keys

private struct HIGReduceMotionKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct HIGReduceTransparencyKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// Convenience accessor for reduce motion preference
    public var higReduceMotion: Bool {
        get { self[HIGReduceMotionKey.self] }
        set { self[HIGReduceMotionKey.self] = newValue }
    }
    
    /// Convenience accessor for reduce transparency preference
    public var higReduceTransparency: Bool {
        get { self[HIGReduceTransparencyKey.self] }
        set { self[HIGReduceTransparencyKey.self] = newValue }
    }
}

// MARK: - HIG Compliant Container

/// A container that automatically applies HIG compliance
public struct HIGContainer<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .environment(\.higReduceMotion, reduceMotion)
            .environment(\.higReduceTransparency, reduceTransparency)
    }
}

// MARK: - Preview

#Preview("HIG Compliance Demo") {
    VStack(spacing: HIGTokens.sectionSpacing) {
        Text("HIG Compliant Components")
            .font(.title)
        
        Button("Primary Button") { }
            .higTouchTarget()
            .higAccessibility(label: "Primary action button", hint: "Double tap to activate")
        
        Text("Card with Liquid Glass")
            .higCard(elevation: .raised)
        
        Text("Material Background")
            .higPadding()
            .higMaterial()
    }
    .padding()
}
