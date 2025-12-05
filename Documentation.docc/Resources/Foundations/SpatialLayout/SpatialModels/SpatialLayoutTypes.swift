// SpatialLayoutTypes.swift
import Foundation
import simd

#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(RealityKit)
import RealityKit
#endif

// MARK: - Protocols (Library-facing)

public protocol FieldOfViewManaging: AnyObject {
    var currentRegion: FOVRegion { get set }
    var contentCenteringEnabled: Bool { get set }
    var recenterThresholdDegrees: Double { get set }

    func isCriticalContentVisible() -> Bool
    func centerImportantContent(animated: Bool)
    func recenter(using source: RecenterSource)
    func recenter()
    func updateFOV(from headPose: simd_float4x4)
}

public protocol SpatialAnchorManaging: AnyObject {
    var activeAnchors: [UUID: AnchorSpec] { get }
    var defaultPlacement: AnchorPlacementStyle { get set }

    @discardableResult func createAnchor(spec: AnchorSpec) -> UUID
    @discardableResult func createAnchor(at position: simd_float3, orientation: simd_quatf, uprightPreferred: Bool) -> UUID
    func resolveAnchor(id: UUID) -> AnchorSpec?
    func removeAnchor(id: UUID)
    func placeWindow(at anchorID: UUID)
    func placeVolume(at anchorID: UUID)
}

public protocol DepthManaging: AnyObject {
    var adaptiveDepthEnabled: Bool { get set }
    var defaultPolicy: DepthPolicy { get set }

    func applyDepth(toWindow id: String, layer: DepthLayer)
    #if canImport(RealityKit)
    func applyDepth(toEntity entity: Entity, layer: DepthLayer)
    func setOcclusion(_ enabled: Bool, for entity: Entity)
    #endif
    func updateDepthForMovement(delta: simd_float3)
}

public protocol ScalingManaging: AnyObject {
    var currentRule: ScalingRule { get set }
    var legibilityDistanceRange: ClosedRange<Float> { get set }

    func scale(forZDistance meters: Float) -> Float
    func applyScale(toWindow id: String, zDistance: Float)
    #if canImport(RealityKit)
    func applyScale(toEntity entity: Entity, zDistance: Float)
    #endif
}

public protocol GestureHandling: AnyObject {
    var hoverSpec: HoverSpec { get set }
    var policy: GesturePolicy { get set }

    func configureIndirectGestures()
    func configureDirectGesturesIfAllowed()
    func applyHoverSpacing(to views: [AnyView])
    func handleDwellSelection(for viewID: String, dwellTime: TimeInterval)
}

public protocol VolumeManaging: AnyObject {
    var volumes: [String: VolumeSpec] { get }
    var defaultSize: CGSize { get set }

    func createVolume(_ spec: VolumeSpec)
    func updateVolume(_ spec: VolumeSpec)
    func removeVolume(id: String)
    #if canImport(RealityKit)
    func attach(entity: Entity, toVolume id: String)
    #endif
    func setDepthLayer(forVolume id: String, layer: DepthLayer)
}

public protocol BestPracticesEnforcing: AnyObject {
    var limits: PolicyLimits { get set }
    var violations: [String] { get }

    func evaluateWindowCount(_ count: Int)
    func evaluateVolumeCount(_ count: Int)
    func evaluateDepthPolicies(_ policies: [DepthPolicy])
    func evaluateInteractionDensity(views: Int, area: CGRect)
    func generateReport() -> String
}

// MARK: - Models and Enums

public struct FOVRegion: Sendable, Equatable {
    public var horizontalDegrees: Double
    public var verticalDegrees: Double
    public var priority: Int
    public init(horizontalDegrees: Double, verticalDegrees: Double, priority: Int) {
        self.horizontalDegrees = horizontalDegrees
        self.verticalDegrees = verticalDegrees
        self.priority = priority
    }
}

public enum RecenterSource: Sendable {
    case digitalCrown, command, programmatic
}

public struct AnchorSpec: Sendable, Equatable {
    public var id: UUID
    public var position: simd_float3
    public var orientation: simd_quatf
    public var uprightPreferred: Bool
    public var angledOffset: simd_float3?
    public init(id: UUID = UUID(),
                position: simd_float3,
                orientation: simd_quatf,
                uprightPreferred: Bool,
                angledOffset: simd_float3? = nil) {
        self.id = id
        self.position = position
        self.orientation = orientation
        self.uprightPreferred = uprightPreferred
        self.angledOffset = angledOffset
    }
}

public enum AnchorPlacementStyle: Sendable {
    case upright, angled
}

public enum DepthLayer: Sendable {
    case background, midground, foreground, overlay, adaptive
}

// Internal tuning struct (keep non-public if desired)
public struct DepthPolicy: Sendable, Equatable {
    public var zIndex: Int
    public var occlusionEnabled: Bool
    public var shadowStyle: String
    public init(zIndex: Int = 0, occlusionEnabled: Bool = false, shadowStyle: String = "none") {
        self.zIndex = zIndex
        self.occlusionEnabled = occlusionEnabled
        self.shadowStyle = shadowStyle
    }
}

public enum ScalingMode: Sendable {
    case fixed, dynamicDistance, lifeSize
}

public struct ScalingRule: Sendable, Equatable {
    public var mode: ScalingMode
    public var minScale: Float
    public var maxScale: Float
    public var lifeSizeEnabled: Bool
    public init(mode: ScalingMode, minScale: Float = 0.5, maxScale: Float = 2.0, lifeSizeEnabled: Bool = false) {
        self.mode = mode
        self.minScale = minScale
        self.maxScale = maxScale
        self.lifeSizeEnabled = lifeSizeEnabled
    }
}

public struct HoverSpec: Sendable, Equatable {
    public var minSpacing: CGFloat
    public var activationDelay: TimeInterval
    public var highlightStyle: String
    public init(minSpacing: CGFloat = 12, activationDelay: TimeInterval = 0.5, highlightStyle: String = "default") {
        self.minSpacing = minSpacing
        self.activationDelay = activationDelay
        self.highlightStyle = highlightStyle
    }
}

public struct GesturePolicy: Sendable, Equatable {
    public var indirectPriority: Bool
    public var directAllowed: Bool
    public var dwellSelectionEnabled: Bool
    public init(indirectPriority: Bool = true, directAllowed: Bool = false, dwellSelectionEnabled: Bool = false) {
        self.indirectPriority = indirectPriority
        self.directAllowed = directAllowed
        self.dwellSelectionEnabled = dwellSelectionEnabled
    }
}

public enum VolumeContentKind: Sendable {
    case realityView, customEntityGraph
}

public struct VolumeSpec: Sendable, Equatable {
    public var id: String
    public var size: CGSize
    public var anchorID: UUID?
    public var contentKind: VolumeContentKind
    public init(id: String, size: CGSize, anchorID: UUID? = nil, contentKind: VolumeContentKind) {
        self.id = id
        self.size = size
        self.anchorID = anchorID
        self.contentKind = contentKind
    }
}

public struct SafeHoverZone: Sendable, Equatable {
    public var radius: CGFloat
    public var margin: CGFloat
    public init(radius: CGFloat = 24, margin: CGFloat = 8) {
        self.radius = radius
        self.margin = margin
    }
}

public struct PolicyLimits: Sendable, Equatable {
    public var maxWindows: Int
    public var maxVolumes: Int
    public var maxInteractiveDensity: CGFloat // views per screen area unit
    public var minHoverSpacing: CGFloat
    public init(maxWindows: Int = 4, maxVolumes: Int = 2, maxInteractiveDensity: CGFloat = 0.001, minHoverSpacing: CGFloat = 12) {
        self.maxWindows = maxWindows
        self.maxVolumes = maxVolumes
        self.maxInteractiveDensity = maxInteractiveDensity
        self.minHoverSpacing = minHoverSpacing
    }
}
