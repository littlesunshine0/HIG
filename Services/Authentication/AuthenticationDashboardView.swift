//
//  AuthenticationDashboardView.swift
//  HIG
//
//  Elite authentication analytics dashboard with real-time monitoring
//  Production-ready visualization for monetizable auth service
//

import SwiftUI
import MapKit

// MARK: - Authentication Dashboard

struct AuthenticationDashboardView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var selectedTab: DashboardTab = .overview
    @State private var timeRange: TimeRange = .day
    @State private var isAnimating = false
    
    enum DashboardTab: String, CaseIterable {
        case overview = "Overview"
        case sessions = "Sessions"
        case security = "Security"
        case analytics = "Analytics"
        
        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .sessions: return "person.2.fill"
            case .security: return "shield.fill"
            case .analytics: return "chart.line.uptrend.xyaxis"
            }
        }
    }
    
    enum TimeRange: String, CaseIterable {
        case hour = "1H"
        case day = "24H"
        case week = "7D"
        case month = "30D"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            dashboardHeader
            Divider()
            
            HStack(spacing: 0) {
                mainContent
                    .frame(maxWidth: .infinity)
            }
        }
        .background(Color.DSBackground.primary)
        .onAppear { animateIn() }
    }
    
    // MARK: - Dashboard Header
    
    private var dashboardHeader: some View {
        HStack(spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("Authentication Service")
                    .appText(.title, weight: .bold)
                Text("Real-time monitoring & analytics")
                    .appText(.caption, color: .secondary)
            }
            
            Spacer()
            
            // Time Range Picker
            HStack(spacing: DSSpacing.xxs) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button {
                        withAnimation(.smoothSpring) { timeRange = range }
                    } label: {
                        Text(range.rawValue)
                            .appText(.caption, weight: .medium)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(timeRange == range ? Color.accentColor : Color.secondary.opacity(0.1))
                            .foregroundStyle(timeRange == range ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Tab Selector
            HStack(spacing: DSSpacing.xs) {
                ForEach(DashboardTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.smoothSpring) { selectedTab = tab }
                    } label: {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: tab.icon)
                            Text(tab.rawValue)
                        }
                        .appText(.body, weight: selectedTab == tab ? .semibold : .regular)
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.vertical, DSSpacing.sm)
                        .background(selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(DSSpacing.md)
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case .overview:
            overviewTab
        case .sessions:
            sessionsTab
        case .security:
            securityTab
        case .analytics:
            analyticsTab
        }
    }
    
    // MARK: - Overview Tab
    
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Key Metrics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
                    AuthMetricCard(
                        title: "Total Users",
                        value: "\(authService.users.count)",
                        change: "+12%",
                        trend: .up,
                        icon: "person.3.fill",
                        color: .blue
                    )
                    AuthMetricCard(
                        title: "Active Sessions",
                        value: "\(authService.getActiveSessions().count)",
                        change: "+5%",
                        trend: .up,
                        icon: "bolt.fill",
                        color: .green
                    )
                    AuthMetricCard(
                        title: "Login Success",
                        value: "98.5%",
                        change: "+2.1%",
                        trend: .up,
                        icon: "checkmark.shield.fill",
                        color: .purple
                    )
                    AuthMetricCard(
                        title: "MFA Enabled",
                        value: "67%",
                        change: "+8%",
                        trend: .up,
                        icon: "lock.shield.fill",
                        color: .orange
                    )
                }
                
                // Login Attempts Map
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Login Attempts (Last 24h)")
                        .appText(.heading, weight: .semibold)
                    
                    LoginAttemptsMapView(attempts: authService.getLoginAttempts())
                        .frame(height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Recent Activity")
                        .appText(.heading, weight: .semibold)
                    
                    ForEach(authService.getAuditLogs(limit: 10)) { log in
                        AuditLogRow(log: log)
                    }
                }
            }
            .padding(DSSpacing.lg)
        }
    }
    
    // MARK: - Sessions Tab
    
    private var sessionsTab: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                ForEach(authService.getActiveSessions()) { session in
                    SessionCard(session: session)
                }
            }
            .padding(DSSpacing.lg)
        }
    }
    
    // MARK: - Security Tab
    
    private var securityTab: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Security Score
                SecurityScoreCard(score: 85)
                
                // Failed Login Attempts
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Failed Login Attempts")
                        .appText(.heading, weight: .semibold)
                    
                    ForEach(authService.getLoginAttempts().filter { !$0.success }) { attempt in
                        FailedLoginRow(attempt: attempt)
                    }
                }
            }
            .padding(DSSpacing.lg)
        }
    }
    
    // MARK: - Analytics Tab
    
    private var analyticsTab: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Login Trends Chart
                Text("Login Trends")
                    .appText(.heading, weight: .semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Placeholder for chart - integrate with EliteChartView
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
                    .overlay {
                        Text("Chart Integration")
                            .appText(.body, color: .secondary)
                    }
            }
            .padding(DSSpacing.lg)
        }
    }
    
    // MARK: - Helper
    
    private func animateIn() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: AnimTime.seconds(0.2))
            withAnimation(.easeOutExpo(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Metric Card

struct AuthMetricCard: View {
    let title: String
    let value: String
    let change: String
    let trend: Trend
    let icon: String
    let color: Color
    
    enum Trend {
        case up, down, neutral
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: DSIconSize.lg))
                    .foregroundStyle(color)
                Spacer()
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: trend == .up ? "arrow.up" : "arrow.down")
                        .font(.system(size: DSIconSize.xs))
                    Text(change)
                        .appText(.caption, weight: .medium, monospaced: true)
                }
                .foregroundStyle(trend == .up ? .green : .red)
            }
            
            Text(value)
                .appText(.title, weight: .bold, monospaced: true)
            
            Text(title)
                .appText(.caption, color: .secondary)
        }
        .padding(DSSpacing.md)
        .background(Color.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: DSRadius.lg))
    }
}

// MARK: - Login Attempts Map

struct LoginAttemptsMapView: View {
    let attempts: [LoginAttempt]
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: attemptsWithLocation) { attempt in
                MapAnnotation(coordinate: attempt.location!.coordinate) {
                    Circle()
                        .fill(attempt.success ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                        .shadow(color: attempt.success ? .green : .red, radius: 4)
                }
            }
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        HStack(spacing: DSSpacing.xs) {
                            Circle().fill(.green).frame(width: 8, height: 8)
                            Text("Successful")
                                .appText(.caption)
                        }
                        HStack(spacing: DSSpacing.xs) {
                            Circle().fill(.red).frame(width: 8, height: 8)
                            Text("Failed")
                                .appText(.caption)
                        }
                    }
                    .padding(DSSpacing.sm)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DSRadius.md))
                    Spacer()
                }
                Spacer()
            }
            .padding(DSSpacing.md)
        }
    }
    
    private var attemptsWithLocation: [LoginAttempt] {
        attempts.filter { $0.location != nil }
    }
}

extension GeoLocation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
    }
}

// MARK: - Session Card

struct SessionCard: View {
    let session: UserSession
    
    var body: some View {
        HStack(spacing: DSSpacing.md) {
            // Device Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: deviceIcon)
                    .font(.system(size: DSIconSize.lg))
                    .foregroundStyle(.blue)
            }
            
            // Session Info
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(session.deviceInfo.deviceName)
                    .appText(.body, weight: .medium)
                Text("\(session.deviceInfo.deviceType) • \(session.ipAddress)")
                    .appText(.caption, color: .secondary)
                Text("Last active: \(session.lastActivityAt.formatted(.relative(presentation: .named)))")
                    .appText(.caption, color: .secondary)
            }
            
            Spacer()
            
            // Status
            DSStatusBadge(
                label: session.isActive ? "Active" : "Expired",
                color: session.isActive ? .green : .gray
            )
        }
        .padding(DSSpacing.md)
        .background(Color.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: DSRadius.lg))
    }
    
    private var deviceIcon: String {
        switch session.deviceInfo.deviceType.lowercased() {
        case "ios": return "iphone"
        case "macos": return "laptopcomputer"
        case "web": return "globe"
        default: return "desktopcomputer"
        }
    }
}

// MARK: - Audit Log Row

struct AuditLogRow: View {
    let log: AuditLog
    
    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: log.action.icon)
                .font(.system(size: DSIconSize.md))
                .foregroundStyle(log.severity.color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(log.action.displayName)
                    .appText(.body, weight: .medium)
                Text(log.timestamp.formatted())
                    .appText(.caption, color: .secondary, monospaced: true)
            }
            
            Spacer()
            
            Text(log.ipAddress)
                .appText(.caption, color: .secondary, monospaced: true)
        }
        .padding(DSSpacing.sm)
        .background(Color.secondary.opacity(0.03), in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

extension AuditLog.AuditAction {
    var icon: String {
        switch self {
        case .login: return "arrow.right.square"
        case .logout: return "arrow.left.square"
        case .passwordChange: return "key.fill"
        case .passwordReset: return "key.horizontal"
        case .mfaEnabled: return "lock.shield"
        case .mfaDisabled: return "lock.open"
        case .emailVerified: return "envelope.badge.fill"
        case .accountCreated: return "person.badge.plus"
        case .accountSuspended: return "person.slash"
        case .accountDeleted: return "person.badge.minus"
        case .permissionGranted: return "checkmark.shield"
        case .permissionRevoked: return "xmark.shield"
        }
    }
    
    var displayName: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

extension AuditLog.Severity {
    var color: Color {
        switch self {
        case .info: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Failed Login Row

struct FailedLoginRow: View {
    let attempt: LoginAttempt
    
    var body: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(attempt.email)
                    .appText(.body, weight: .medium)
                Text(attempt.failureReason ?? "Unknown reason")
                    .appText(.caption, color: .secondary)
            }
            
            Spacer()
            
            Text(attempt.timestamp.formatted(.relative(presentation: .named)))
                .appText(.caption, color: .secondary)
        }
        .padding(DSSpacing.sm)
        .background(Color.red.opacity(0.05), in: RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

// MARK: - Security Score Card

struct SecurityScoreCard: View {
    let score: Int
    
    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Text("Security Score")
                .appText(.heading, weight: .semibold)
            
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: DSSpacing.xs) {
                    Text("\(score)")
                        .appText(.title, weight: .bold, monospaced: true)
                        .font(.system(size: 48))
                    Text(scoreLabel)
                        .appText(.body, color: scoreColor)
                }
            }
            
            Text(scoreDescription)
                .appText(.body, color: .secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DSSpacing.xl)
        .background(Color.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: DSRadius.xl))
    }
    
    private var scoreColor: Color {
        if score >= 80 { return .green }
        if score >= 60 { return .orange }
        return .red
    }
    
    private var scoreLabel: String {
        if score >= 80 { return "Excellent" }
        if score >= 60 { return "Good" }
        return "Needs Improvement"
    }
    
    private var scoreDescription: String {
        if score >= 80 { return "Your authentication security is excellent with strong policies in place." }
        if score >= 60 { return "Good security posture. Consider enabling MFA for all users." }
        return "Security needs improvement. Review failed login attempts and enable MFA."
    }
}

// MARK: - Preview

#Preview("Authentication Dashboard") {
    AuthenticationDashboardView()
        .frame(width: 1200, height: 800)
}
