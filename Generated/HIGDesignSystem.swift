//
//  HIGDesignSystem.swift
//  HIG
//
//  Auto-generated HIG Design System
//  Generated: 2025-11-26T03:56:20.009415
//
//  This file contains all HIG design tokens, guidelines, and Swift implementations.
//  DO NOT EDIT MANUALLY - regenerate using: python scripts/generate_hig_config.py
//

import SwiftUI

// MARK: - HIG Design Tokens

/// All design tokens from Apple Human Interface Guidelines
public enum HIG {
    
    // MARK: - Touch Targets [accessibility]
    
    /// Minimum touch target for iOS/iPadOS/macOS (44pt)
    public static let minTouchTarget: CGFloat = 44
    
    /// Minimum touch target for visionOS (60pt)
    public static let minTouchTargetVision: CGFloat = 60
    
    /// Minimum touch target for watchOS (38pt)
    public static let minTouchTargetWatch: CGFloat = 38
    
    // MARK: - Spacing [layout]
    
    /// Padding around bezeled controls (12pt)
    public static let bezelPadding: CGFloat = 12
    
    /// Padding around non-bezeled elements (24pt)
    public static let nonBezelPadding: CGFloat = 24
    
    /// Standard content padding (16pt)
    public static let contentPadding: CGFloat = 16
    
    /// Compact padding (8pt)
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
    
    /// Window corner radius (12pt)
    public static let windowRadius: CGFloat = 12
    
    /// Card/panel radius (16pt)
    public static let cardRadius: CGFloat = 16
    
    /// Control radius (8pt)
    public static let controlRadius: CGFloat = 8
    
    /// Small radius (6pt)
    public static let smallRadius: CGFloat = 6
    
    /// Bubble/chip radius (20pt)
    public static let bubbleRadius: CGFloat = 20
    
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
    
    // MARK: - Typography
    
    /// Maximum preview lines (3)
    public static let maxPreviewLines: Int = 3
    
    // MARK: - Accessibility Contrast
    
    /// Minimum contrast ratio for text (4.5:1 WCAG AA)
    public static let minContrastRatioText: Double = 4.5
    
    /// Minimum contrast ratio for large text (3.0:1 WCAG AA)
    public static let minContrastRatioLargeText: Double = 3.0
}

// MARK: - HIG Required Environments

/// Template for required environment variables in HIG-compliant views
///
/// Add these to your view struct:
/// ```swift
/// @Environment(\.colorScheme) private var colorScheme
/// @Environment(\.accessibilityReduceMotion) private var reduceMotion
/// @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
/// @Environment(\.dynamicTypeSize) private var dynamicTypeSize
/// ```

// MARK: - Preview

#Preview("HIG Design System") {
    VStack(spacing: HIG.sectionSpacing) {
        Text("HIG Design System")
            .font(.largeTitle)
        
        Text("Touch Target: \(Int(HIG.minTouchTarget))pt")
        Text("Content Padding: \(Int(HIG.contentPadding))pt")
        Text("Card Radius: \(Int(HIG.cardRadius))pt")
        
        Button("HIG Button") { }
            .higTouchTarget()
            .higCard()
    }
    .padding()
}
