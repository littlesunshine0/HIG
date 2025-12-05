//
//  HIGAppIcon.swift
//  HIG
//
//  Custom App Icon for HIG Documentation Assistant
//  100% HIG-Compliant with Liquid Glass Design System
//
//  Design Concept:
//  - Open book shape representing documentation
//  - Liquid Glass material effect
//  - Apple-inspired rounded corners
//  - Gradient reflecting the purple/blue HIG brand
//

import SwiftUI

// MARK: - App Icon Shape

/// Custom book-shaped path for the HIG app icon
struct HIGBookShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        
        // Book spine (center)
        let spineWidth = w * 0.08
        let spineX = (w - spineWidth) / 2
        
        // Page curves
        let pageInset = w * 0.08
        let topInset = h * 0.12
        let bottomInset = h * 0.12
        let cornerRadius = w * 0.06
        
        // Left page
        path.move(to: CGPoint(x: spineX, y: topInset))
        
        // Left page top edge (curved outward)
        path.addQuadCurve(
            to: CGPoint(x: pageInset + cornerRadius, y: topInset),
            control: CGPoint(x: spineX - w * 0.05, y: topInset - h * 0.02)
        )
        
        // Left page top-left corner
        path.addArc(
            tangent1End: CGPoint(x: pageInset, y: topInset),
            tangent2End: CGPoint(x: pageInset, y: topInset + cornerRadius),
            radius: cornerRadius
        )
        
        // Left page left edge
        path.addLine(to: CGPoint(x: pageInset, y: h - bottomInset - cornerRadius))
        
        // Left page bottom-left corner
        path.addArc(
            tangent1End: CGPoint(x: pageInset, y: h - bottomInset),
            tangent2End: CGPoint(x: pageInset + cornerRadius, y: h - bottomInset),
            radius: cornerRadius
        )
        
        // Left page bottom edge (curved outward)
        path.addQuadCurve(
            to: CGPoint(x: spineX, y: h - bottomInset),
            control: CGPoint(x: spineX - w * 0.05, y: h - bottomInset + h * 0.02)
        )
        
        path.closeSubpath()
        
        // Right page
        path.move(to: CGPoint(x: spineX + spineWidth, y: topInset))
        
        // Right page top edge (curved outward)
        path.addQuadCurve(
            to: CGPoint(x: w - pageInset - cornerRadius, y: topInset),
            control: CGPoint(x: spineX + spineWidth + w * 0.05, y: topInset - h * 0.02)
        )
        
        // Right page top-right corner
        path.addArc(
            tangent1End: CGPoint(x: w - pageInset, y: topInset),
            tangent2End: CGPoint(x: w - pageInset, y: topInset + cornerRadius),
            radius: cornerRadius
        )
        
        // Right page right edge
        path.addLine(to: CGPoint(x: w - pageInset, y: h - bottomInset - cornerRadius))
        
        // Right page bottom-right corner
        path.addArc(
            tangent1End: CGPoint(x: w - pageInset, y: h - bottomInset),
            tangent2End: CGPoint(x: w - pageInset - cornerRadius, y: h - bottomInset),
            radius: cornerRadius
        )
        
        // Right page bottom edge (curved outward)
        path.addQuadCurve(
            to: CGPoint(x: spineX + spineWidth, y: h - bottomInset),
            control: CGPoint(x: spineX + spineWidth + w * 0.05, y: h - bottomInset + h * 0.02)
        )
        
        path.closeSubpath()
        
        return path
    }
}

/// Book spine shape
struct HIGSpineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        
        let spineWidth = w * 0.08
        let spineX = (w - spineWidth) / 2
        let topInset = h * 0.10
        let bottomInset = h * 0.10
        
        // Spine rectangle with slight curve
        path.move(to: CGPoint(x: spineX, y: topInset))
        path.addLine(to: CGPoint(x: spineX + spineWidth, y: topInset))
        path.addLine(to: CGPoint(x: spineX + spineWidth, y: h - bottomInset))
        path.addLine(to: CGPoint(x: spineX, y: h - bottomInset))
        path.closeSubpath()
        
        return path
    }
}

/// Page lines decoration
struct HIGPageLinesShape: Shape {
    let lineCount: Int
    let isLeftPage: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        
        let spineWidth = w * 0.08
        let spineX = (w - spineWidth) / 2
        let pageInset = w * 0.08
        let topInset = h * 0.12
        let bottomInset = h * 0.12
        
        let lineInset = w * 0.04
        let lineSpacing = (h - topInset - bottomInset - h * 0.1) / CGFloat(lineCount + 1)
        
        for i in 1...lineCount {
            let y = topInset + h * 0.05 + lineSpacing * CGFloat(i)
            
            if isLeftPage {
                let startX = pageInset + lineInset
                let endX = spineX - lineInset
                path.move(to: CGPoint(x: startX, y: y))
                path.addLine(to: CGPoint(x: endX, y: y))
            } else {
                let startX = spineX + spineWidth + lineInset
                let endX = w - pageInset - lineInset
                path.move(to: CGPoint(x: startX, y: y))
                path.addLine(to: CGPoint(x: endX, y: y))
            }
        }
        
        return path
    }
}

// MARK: - App Icon View

/// The complete HIG App Icon view with Liquid Glass styling
struct HIGAppIconView: View {
    let size: CGFloat
    var showLines: Bool = true
    var animated: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Shadow/glow layer
            HIGBookShape()
                .fill(Color.purple.opacity(0.3))
                .blur(radius: size * 0.08)
                .offset(y: size * 0.02)
            
            // Book pages - base layer
            HIGBookShape()
                .fill(
                    LinearGradient(
                        colors: pageGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Book pages - glass overlay
            HIGBookShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.15 : 0.4),
                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Book pages - border
            HIGBookShape()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.2),
                            Color.purple.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.015
                )
            
            // Spine
            HIGSpineShape()
                .fill(
                    LinearGradient(
                        colors: spineGradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Spine highlight
            HIGSpineShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.clear,
                            Color.black.opacity(0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Page lines (optional)
            if showLines {
                // Left page lines
                HIGPageLinesShape(lineCount: 4, isLeftPage: true)
                    .stroke(
                        Color.purple.opacity(0.3),
                        style: StrokeStyle(lineWidth: size * 0.012, lineCap: .round)
                    )
                
                // Right page lines
                HIGPageLinesShape(lineCount: 4, isLeftPage: false)
                    .stroke(
                        Color.blue.opacity(0.3),
                        style: StrokeStyle(lineWidth: size * 0.012, lineCap: .round)
                    )
            }
            
            // Inner glow
            HIGBookShape()
                .stroke(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.8
                    ),
                    lineWidth: size * 0.02
                )
                .blur(radius: size * 0.01)
        }
        .frame(width: size, height: size)
        .onAppear {
            if animated {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    animationPhase = 1
                }
            }
        }
    }
    
    // MARK: - Colors
    
    private var pageGradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.2, green: 0.15, blue: 0.3),
                Color(red: 0.15, green: 0.15, blue: 0.25),
                Color(red: 0.1, green: 0.12, blue: 0.2)
            ]
        } else {
            return [
                Color(red: 0.95, green: 0.93, blue: 1.0),
                Color(red: 0.92, green: 0.92, blue: 0.98),
                Color(red: 0.88, green: 0.9, blue: 0.96)
            ]
        }
    }
    
    private var spineGradientColors: [Color] {
        [
            Color.purple.opacity(0.8),
            Color.purple.opacity(0.6),
            Color.blue.opacity(0.7)
        ]
    }
}

// MARK: - Icon Outline Only

/// Outline-only version of the app icon for loading states
struct HIGAppIconOutline: View {
    let size: CGFloat
    var lineWidth: CGFloat?
    var animated: Bool = false
    
    @State private var trimEnd: CGFloat = 0
    @State private var glowPhase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var strokeWidth: CGFloat {
        lineWidth ?? (size * 0.02)
    }
    
    var body: some View {
        ZStack {
            // Glow effect behind
            if animated && !reduceMotion {
                HIGBookShape()
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.5), .blue.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: strokeWidth * 3,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .blur(radius: 8)
                    .opacity(0.5 + glowPhase * 0.3)
            }
            
            // Book outline
            HIGBookShape()
                .trim(from: 0, to: animated ? trimEnd : 1)
                .stroke(
                    LinearGradient(
                        colors: [.purple, .blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: strokeWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            
            // Spine outline
            HIGSpineShape()
                .trim(from: 0, to: animated ? trimEnd : 1)
                .stroke(
                    Color.purple.opacity(0.6),
                    style: StrokeStyle(
                        lineWidth: strokeWidth * 0.8,
                        lineCap: .round
                    )
                )
        }
        .frame(width: size, height: size)
        .onAppear {
            if animated && !reduceMotion {
                withAnimation(.easeInOut(duration: 1.5)) {
                    trimEnd = 1
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    glowPhase = 1
                }
            } else {
                trimEnd = 1
            }
        }
    }
}

// MARK: - Animated App Icon

/// App icon with shimmer and glow animations
struct HIGAnimatedAppIcon: View {
    let size: CGFloat
    var showLines: Bool = true
    
    @State private var shimmerPhase: CGFloat = 0
    @State private var glowIntensity: CGFloat = 0.3
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack {
            // Animated glow
            if !reduceMotion {
                HIGBookShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(glowIntensity),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: size * 0.2,
                            endRadius: size * 0.8
                        )
                    )
                    .blur(radius: size * 0.15)
            }
            
            // Base icon
            HIGAppIconView(size: size, showLines: showLines)
            
            // Shimmer overlay
            if !reduceMotion {
                HIGBookShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.3),
                                .clear
                            ],
                            startPoint: UnitPoint(x: shimmerPhase - 0.3, y: shimmerPhase - 0.3),
                            endPoint: UnitPoint(x: shimmerPhase + 0.3, y: shimmerPhase + 0.3)
                        )
                    )
                    .mask(HIGBookShape())
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            guard !reduceMotion else { return }
            
            // Shimmer animation
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.5
            }
            
            // Glow pulse
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                glowIntensity = 0.5
            }
        }
    }
}

// MARK: - Mini App Icon

/// Compact app icon for toolbars and small spaces
struct HIGMiniAppIcon: View {
    let size: CGFloat
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Simplified book shape
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Inner highlight
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            
            // Spine line
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: size * 0.08)
            
            // Page lines
            VStack(spacing: size * 0.08) {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: size * 0.25, height: 1)
                }
            }
            .offset(x: size * 0.15)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.15))
    }
}

// MARK: - White Outline Only (for dark backgrounds)

/// Pure white outline version - perfect for dark backgrounds, splash screens
struct HIGAppIconWhiteOutline: View {
    let size: CGFloat
    var lineWidth: CGFloat?
    var animated: Bool = false
    
    @State private var trimEnd: CGFloat = 0
    @State private var glowPhase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var strokeWidth: CGFloat {
        lineWidth ?? (size * 0.02)
    }
    
    var body: some View {
        ZStack {
            // Glow effect behind (optional)
            if animated && !reduceMotion {
                HIGBookShape()
                    .stroke(
                        Color.white.opacity(0.3),
                        style: StrokeStyle(
                            lineWidth: strokeWidth * 3,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .blur(radius: 8)
                    .opacity(0.3 + glowPhase * 0.2)
            }
            
            // Book outline - pure white
            HIGBookShape()
                .trim(from: 0, to: animated ? trimEnd : 1)
                .stroke(
                    Color.white,
                    style: StrokeStyle(
                        lineWidth: strokeWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            
            // Spine outline - pure white
            HIGSpineShape()
                .trim(from: 0, to: animated ? trimEnd : 1)
                .stroke(
                    Color.white.opacity(0.8),
                    style: StrokeStyle(
                        lineWidth: strokeWidth * 0.8,
                        lineCap: .round
                    )
                )
        }
        .frame(width: size, height: size)
        .onAppear {
            if animated && !reduceMotion {
                withAnimation(.easeInOut(duration: 1.5)) {
                    trimEnd = 1
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    glowPhase = 1
                }
            } else {
                trimEnd = 1
            }
        }
    }
}

// MARK: - Black Outline Only (for light backgrounds)

/// Pure black outline version - perfect for light backgrounds, documents
struct HIGAppIconBlackOutline: View {
    let size: CGFloat
    var lineWidth: CGFloat?
    var animated: Bool = false
    
    @State private var trimEnd: CGFloat = 0
    @State private var glowPhase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var strokeWidth: CGFloat {
        lineWidth ?? (size * 0.02)
    }
    
    var body: some View {
        ZStack {
            // Subtle shadow effect behind (optional)
            if animated && !reduceMotion {
                HIGBookShape()
                    .stroke(
                        Color.black.opacity(0.2),
                        style: StrokeStyle(
                            lineWidth: strokeWidth * 3,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .blur(radius: 8)
                    .opacity(0.2 + glowPhase * 0.1)
            }
            
            // Book outline - pure black
            HIGBookShape()
                .trim(from: 0, to: animated ? trimEnd : 1)
                .stroke(
                    Color.black,
                    style: StrokeStyle(
                        lineWidth: strokeWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            
            // Spine outline - pure black
            HIGSpineShape()
                .trim(from: 0, to: animated ? trimEnd : 1)
                .stroke(
                    Color.black.opacity(0.8),
                    style: StrokeStyle(
                        lineWidth: strokeWidth * 0.8,
                        lineCap: .round
                    )
                )
        }
        .frame(width: size, height: size)
        .onAppear {
            if animated && !reduceMotion {
                withAnimation(.easeInOut(duration: 1.5)) {
                    trimEnd = 1
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    glowPhase = 1
                }
            } else {
                trimEnd = 1
            }
        }
    }
}

// MARK: - Monochrome Icon (for system tray, menu bar)

/// Monochrome version that adapts to system tint
struct HIGAppIconMonochrome: View {
    let size: CGFloat
    var color: Color = .primary
    
    var body: some View {
        ZStack {
            // Simplified book shape
            HIGBookShape()
                .fill(color.opacity(0.2))
            
            // Book outline
            HIGBookShape()
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: size * 0.015,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            
            // Spine
            HIGSpineShape()
                .fill(color.opacity(0.4))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Template Icon (for menu bar, status bar)

/// Template icon that works with system appearance
struct HIGAppIconTemplate: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Book outline only - will be tinted by system
            HIGBookShape()
                .stroke(
                    Color.primary,
                    style: StrokeStyle(
                        lineWidth: size * 0.02,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            
            // Spine
            HIGSpineShape()
                .stroke(
                    Color.primary.opacity(0.7),
                    style: StrokeStyle(
                        lineWidth: size * 0.015,
                        lineCap: .round
                    )
                )
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Flat Icon (for notifications, badges)

/// Flat version without gradients or effects
struct HIGAppIconFlat: View {
    let size: CGFloat
    var backgroundColor: Color = .purple
    var foregroundColor: Color = .white
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(backgroundColor)
            
            // Book shape
            HIGBookShape()
                .fill(foregroundColor.opacity(0.9))
                .padding(size * 0.15)
            
            // Spine
            HIGSpineShape()
                .fill(foregroundColor.opacity(0.6))
                .padding(size * 0.15)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
    }
}

// MARK: - App Icon Set Generator

/// Generates all required icon sizes for macOS app bundle
struct HIGAppIconSet: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Full color icons
                iconSection(title: "Full Color Icons") {
                    iconRow(sizes: [16, 32, 64, 128, 256, 512, 1024]) { size in
                        HIGAppIconView(size: size, showLines: size >= 64)
                    }
                }
                
                // White outline icons
                iconSection(title: "White Outline (Dark Backgrounds)") {
                    iconRow(sizes: [16, 32, 64, 128, 256]) { size in
                        HIGAppIconWhiteOutline(size: size)
                            .background(Color.black)
                    }
                }
                
                // Black outline icons
                iconSection(title: "Black Outline (Light Backgrounds)") {
                    iconRow(sizes: [16, 32, 64, 128, 256]) { size in
                        HIGAppIconBlackOutline(size: size)
                            .background(Color.white)
                    }
                }
                
                // Monochrome icons
                iconSection(title: "Monochrome (System Tray)") {
                    iconRow(sizes: [16, 18, 20, 22, 24, 32]) { size in
                        HIGAppIconMonochrome(size: size)
                    }
                }
                
                // Template icons
                iconSection(title: "Template (Menu Bar)") {
                    iconRow(sizes: [16, 18, 20, 22]) { size in
                        HIGAppIconTemplate(size: size)
                    }
                }
                
                // Flat icons
                iconSection(title: "Flat (Notifications)") {
                    iconRow(sizes: [32, 48, 64, 128]) { size in
                        HIGAppIconFlat(size: size)
                    }
                }
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
    
    @ViewBuilder
    private func iconSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            content()
            
            Divider()
        }
    }
    
    @ViewBuilder
    private func iconRow<Content: View>(
        sizes: [CGFloat],
        @ViewBuilder icon: @escaping (CGFloat) -> Content
    ) -> some View {
        HStack(spacing: 20) {
            ForEach(sizes, id: \.self) { size in
                VStack(spacing: 8) {
                    icon(size)
                        .frame(width: size, height: size)
                    
                    Text("\(Int(size))px")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

// MARK: - Branding Components

/// App name with gradient text - "DocuChat"
struct HIGAppName: View {
    var fontSize: CGFloat = 32
    var fontWeight: Font.Weight = .semibold
    
    var body: some View {
        Text("DocuChat")
            .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

/// App tagline - "Your AI Documentation Assistant"
struct HIGAppTagline: View {
    var fontSize: CGFloat = 14
    
    var body: some View {
        Text("Your AI Documentation Assistant")
            .font(.system(size: fontSize, weight: .regular, design: .rounded))
            .foregroundStyle(.secondary)
    }
}

/// Complete branding stack with icon, name, and tagline
struct HIGBrandingStack: View {
    var iconSize: CGFloat = 80
    var nameSize: CGFloat = 32
    var taglineSize: CGFloat = 14
    var spacing: CGFloat = 12
    var showIcon: Bool = true
    var showTagline: Bool = true
    
    var body: some View {
        VStack(spacing: spacing) {
            if showIcon {
                HIGAppIconView(size: iconSize, showLines: iconSize >= 64)
            }
            
            HIGAppName(fontSize: nameSize)
            
            if showTagline {
                HIGAppTagline(fontSize: taglineSize)
            }
        }
    }
}

// MARK: - Previews

#Preview("App Icon - Full") {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            HIGAppIconView(size: 128)
            HIGAppIconView(size: 128, showLines: false)
        }
        
        HStack(spacing: 40) {
            HIGAppIconView(size: 64)
            HIGAppIconView(size: 64, showLines: false)
        }
    }
    .padding(40)
    .background(Color(.windowBackgroundColor))
}

#Preview("App Icon - Outline") {
    VStack(spacing: 40) {
        HIGAppIconOutline(size: 128, animated: true)
        HIGAppIconOutline(size: 64)
    }
    .padding(40)
    .background(Color(.windowBackgroundColor))
}

#Preview("White Outline Only") {
    VStack(spacing: 40) {
        HIGAppIconWhiteOutline(size: 160, animated: true)
        HIGAppIconWhiteOutline(size: 128)
        HIGAppIconWhiteOutline(size: 64)
    }
    .padding(40)
    .background(Color.black)
}

#Preview("Black Outline Only") {
    VStack(spacing: 40) {
        HIGAppIconBlackOutline(size: 160, animated: true)
        HIGAppIconBlackOutline(size: 128)
        HIGAppIconBlackOutline(size: 64)
    }
    .padding(40)
    .background(Color.white)
}

#Preview("Monochrome Variants") {
    HStack(spacing: 30) {
        VStack(spacing: 20) {
            Text("Light Mode")
                .font(.caption)
            HIGAppIconMonochrome(size: 64)
            HIGAppIconTemplate(size: 64)
        }
        
        VStack(spacing: 20) {
            Text("Dark Mode")
                .font(.caption)
            HIGAppIconMonochrome(size: 64)
                .environment(\.colorScheme, .dark)
            HIGAppIconTemplate(size: 64)
                .environment(\.colorScheme, .dark)
        }
    }
    .padding(40)
}

#Preview("All Icon Variants") {
    HIGAppIconSet()
}

#Preview("Branding Components") {
    VStack(spacing: 40) {
        // Full branding stack
        HIGBrandingStack()
        
        Divider()
        
        // Individual components
        VStack(spacing: 20) {
            HIGAppName(fontSize: 48)
            HIGAppName(fontSize: 32)
            HIGAppName(fontSize: 24)
        }
        
        Divider()
        
        VStack(spacing: 20) {
            HIGAppTagline(fontSize: 16)
            HIGAppTagline(fontSize: 14)
            HIGAppTagline(fontSize: 12)
        }
        
        Divider()
        
        // Different sizes
        HStack(spacing: 40) {
            HIGBrandingStack(iconSize: 64, nameSize: 24, taglineSize: 12)
            HIGBrandingStack(iconSize: 80, nameSize: 32, taglineSize: 14)
            HIGBrandingStack(iconSize: 100, nameSize: 40, taglineSize: 16)
        }
    }
    .padding(40)
    .background(Color(.windowBackgroundColor))
}

#Preview("App Icon - Dark Mode") {
    VStack(spacing: 40) {
        HIGAppIconView(size: 128)
        HIGAppIconOutline(size: 128)
    }
    .padding(40)
    .background(Color.black)
    .environment(\.colorScheme, .dark)
}
