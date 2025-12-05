import SwiftUI
import Charts
import Combine

/// Elite API Gateway Dashboard with real-time monitoring
struct APIGatewayDashboardView: View {
    @StateObject private var gateway = APIGatewayViewModel()
    @State private var selectedTimeRange: TimeRange = .hour
    @State private var selectedEndpoint: String?
    @State private var showSettings = false
    
    enum TimeRange: String, CaseIterable {
        case minute = "1m"
        case hour = "1h"
        case day = "24h"
        case week = "7d"
    }
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
        } content: {
            mainDashboard
        } detail: {
            detailView
        }
        .navigationTitle("API Gateway")
        .toolbar {
            ToolbarItem {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            GatewaySettingsSheet()
        }
    }
    
    private var sidebarContent: some View {
        List(selection: $selectedEndpoint) {
            Section("Overview") {
                APIStatCard(
                    title: "Requests/min",
                    value: String(format: "%.1f", gateway.stats.requestsPerMinute),
                    trend: .up,
                    color: .blue
                )
                
                APIStatCard(
                    title: "Avg Latency",
                    value: String(format: "%.0fms", gateway.stats.averageLatency * 1000),
                    trend: .down,
                    color: .green
                )
                
                APIStatCard(
                    title: "Error Rate",
                    value: String(format: "%.2f%%", gateway.stats.errorRate * 100),
                    trend: gateway.stats.errorRate > 0.05 ? .up : .down,
                    color: gateway.stats.errorRate > 0.05 ? .red : .green
                )
            }
            
            Section("Top Endpoints") {
                ForEach(gateway.topEndpoints, id: \.self) { endpoint in
                    EndpointRow(endpoint: endpoint)
                        .tag(endpoint)
                }
            }
            
            Section("Rate Limits") {
                ForEach(gateway.rateLimitStatus, id: \.clientId) { status in
                    RateLimitRow(status: status)
                }
            }
        }
    }

    private var mainDashboard: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time range picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Request volume chart
                RequestVolumeChart(data: gateway.requestVolume)
                    .frame(height: 200)
                    .padding()
                
                // Latency distribution
                LatencyChart(data: gateway.latencyDistribution)
                    .frame(height: 200)
                    .padding()
                
                // Status code breakdown
                StatusCodeChart(data: gateway.statusCodes)
                    .frame(height: 200)
                    .padding()
                
                // Recent requests table
                RecentRequestsTable(requests: gateway.recentRequests)
                    .padding()
            }
        }
    }
    
    private var detailView: some View {
        Group {
            if let endpoint = selectedEndpoint {
                APIEndpointDetailView(endpoint: endpoint)
            } else {
                ContentUnavailableView(
                    "Select an Endpoint",
                    systemImage: "network",
                    description: Text("Choose an endpoint to view detailed metrics")
                )
            }
        }
    }
}

// MARK: - Supporting Views
struct APIStatCard: View {
    let title: String
    let value: String
    let trend: Trend
    let color: Color
    
    enum Trend {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                
                Image(systemName: trend.icon)
                    .foregroundStyle(trend == .up ? .red : .green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct EndpointRow: View {
    let endpoint: String
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.right.circle.fill")
                .foregroundStyle(.blue)
            Text(endpoint)
                .font(.system(.body, design: .monospaced))
        }
    }
}

struct RateLimitRow: View {
    let status: RateLimitStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(status.clientId)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ProgressView(value: status.usage, total: status.limit)
                .tint(status.usage > status.limit * 0.8 ? .red : .green)
            
            Text("\(Int(status.usage))/\(Int(status.limit))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}


// MARK: - Charts
struct RequestVolumeChart: View {
    let data: [RequestDataPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Request Volume")
                .font(.headline)
            
            Chart(data) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Requests", point.count)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Requests", point.count)
                )
                .foregroundStyle(.blue.opacity(0.2))
                .interpolationMethod(.catmullRom)
            }
        }
    }
}

struct LatencyChart: View {
    let data: [LatencyDataPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Latency Distribution")
                .font(.headline)
            
            Chart(data) { point in
                BarMark(
                    x: .value("Latency", point.bucket),
                    y: .value("Count", point.count)
                )
                .foregroundStyle(.green)
            }
        }
    }
}

struct StatusCodeChart: View {
    let data: [StatusCodeData]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Status Codes")
                .font(.headline)
            
            Chart(data) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Status", item.code))
                .cornerRadius(4)
            }
        }
    }
}

struct RecentRequestsTable: View {
    let requests: [APIRequestLog]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Requests")
                .font(.headline)
            
            Table(requests) {
                TableColumn("Time") { req in
                    Text(req.timestamp, style: .time)
                }
                TableColumn("Method") { req in
                    Text(req.method)
                        .font(.system(.body, design: .monospaced))
                }
                TableColumn("Endpoint") { req in
                    Text(req.endpoint)
                        .font(.system(.caption, design: .monospaced))
                }
                TableColumn("Status") { req in
                    APIStatusBadge(code: req.statusCode)
                }
                TableColumn("Latency") { req in
                    Text(String(format: "%.0fms", req.duration * 1000))
                }
            }
        }
    }
}

struct APIStatusBadge: View {
    let code: Int
    
    var color: Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .blue
        case 400..<500: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        Text("\(code)")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct APIEndpointDetailView: View {
    let endpoint: String
    
    var body: some View {
        List {
            Section("Endpoint Info") {
                LabeledContent("Path", value: endpoint)
                LabeledContent("Method", value: "GET, POST")
                LabeledContent("Rate Limit", value: "1000/hour")
            }
            
            Section("Performance") {
                LabeledContent("Avg Latency", value: "45ms")
                LabeledContent("P95 Latency", value: "120ms")
                LabeledContent("P99 Latency", value: "250ms")
            }
            
            Section("Usage") {
                LabeledContent("Total Requests", value: "12,453")
                LabeledContent("Success Rate", value: "99.2%")
                LabeledContent("Error Rate", value: "0.8%")
            }
        }
    }
}

struct GatewaySettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Rate Limiting") {
                    Toggle("Enable Rate Limiting", isOn: .constant(true))
                    Stepper("Default Limit: 1000/hour", value: .constant(1000))
                }
                
                Section("Caching") {
                    Toggle("Enable Response Caching", isOn: .constant(true))
                    Stepper("Cache TTL: 5 minutes", value: .constant(5))
                }
                
                Section("Monitoring") {
                    Toggle("Enable Metrics", isOn: .constant(true))
                    Toggle("Enable Logging", isOn: .constant(true))
                }
            }
            .navigationTitle("Gateway Settings")
            .toolbar {
                ToolbarItem {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - View Model
@MainActor
class APIGatewayViewModel: ObservableObject {
    @Published var stats = APIStats(totalRequests: 0, averageLatency: 0, errorRate: 0, requestsPerMinute: 0)
    @Published var requestVolume: [RequestDataPoint] = []
    @Published var latencyDistribution: [LatencyDataPoint] = []
    @Published var statusCodes: [StatusCodeData] = []
    @Published var recentRequests: [APIRequestLog] = []
    @Published var topEndpoints: [String] = []
    @Published var rateLimitStatus: [RateLimitStatus] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        stats = APIStats(totalRequests: 1234, averageLatency: 0.045, errorRate: 0.008, requestsPerMinute: 42.5)
        
        requestVolume = (0..<60).map { i in
            RequestDataPoint(timestamp: Date().addingTimeInterval(Double(-i * 60)), count: Int.random(in: 30...80))
        }
        
        latencyDistribution = [
            LatencyDataPoint(bucket: "0-50ms", count: 450),
            LatencyDataPoint(bucket: "50-100ms", count: 320),
            LatencyDataPoint(bucket: "100-200ms", count: 180),
            LatencyDataPoint(bucket: "200-500ms", count: 45),
            LatencyDataPoint(bucket: "500ms+", count: 5)
        ]
        
        statusCodes = [
            StatusCodeData(code: "200", count: 980),
            StatusCodeData(code: "201", count: 120),
            StatusCodeData(code: "400", count: 45),
            StatusCodeData(code: "401", count: 30),
            StatusCodeData(code: "500", count: 8)
        ]
        
        recentRequests = (0..<20).map { i in
            APIRequestLog(
                timestamp: Date().addingTimeInterval(Double(-i * 30)),
                method: ["GET", "POST", "PUT", "DELETE"].randomElement()!,
                endpoint: ["/api/v1/users", "/api/v1/data", "/api/v1/analytics"].randomElement()!,
                statusCode: [200, 201, 400, 401, 500].randomElement()!,
                duration: Double.random(in: 0.01...0.5)
            )
        }
        
        topEndpoints = ["/api/v1/users", "/api/v1/data", "/api/v1/analytics", "/api/v1/auth/login"]
        
        rateLimitStatus = [
            RateLimitStatus(clientId: "client_123", usage: 450, limit: 1000),
            RateLimitStatus(clientId: "client_456", usage: 890, limit: 1000),
            RateLimitStatus(clientId: "client_789", usage: 120, limit: 100)
        ]
    }
}

// MARK: - Data Models
struct RequestDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let count: Int
}

struct LatencyDataPoint: Identifiable {
    let id = UUID()
    let bucket: String
    let count: Int
}

struct StatusCodeData: Identifiable {
    let id = UUID()
    let code: String
    let count: Int
}

struct APIRequestLog: Identifiable {
    let id = UUID()
    let timestamp: Date
    let method: String
    let endpoint: String
    let statusCode: Int
    let duration: TimeInterval
}

struct RateLimitStatus {
    let clientId: String
    let usage: Double
    let limit: Double
}
