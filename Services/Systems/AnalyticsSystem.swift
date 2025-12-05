//
//  AnalyticsSystem.swift
//  HIG
//
//  Analytics System - Event tracking, metrics, insights
//

import SwiftUI

struct AnalyticsSystemView: View {
    @State private var selectedTab = "Dashboard"
    @State private var timeRange = "7 days"
    
    let tabs = ["Dashboard", "Events", "Funnels", "Cohorts"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill").font(.title2).foregroundStyle(.purple)
                Text("Analytics System").font(.title2.bold())
                Spacer()
                
                Picker("Time Range", selection: $timeRange) {
                    Text("Today").tag("Today")
                    Text("7 days").tag("7 days")
                    Text("30 days").tag("30 days")
                    Text("90 days").tag("90 days")
                }
                .frame(width: 120)
            }
            .padding()
            .background(.regularMaterial)
            
            // Tabs
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 20).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.purple.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            // Content
            ScrollView {
                switch selectedTab {
                case "Dashboard": AnalyticsDashboard()
                case "Events": EventsView()
                case "Funnels": FunnelsView()
                case "Cohorts": CohortsView()
                default: EmptyView()
                }
            }
        }
    }
}

struct AnalyticsDashboard: View {
    var body: some View {
        VStack(spacing: 20) {
            // KPIs
            HStack(spacing: 16) {
                KPICard(title: "Total Users", value: "12,458", change: "+12%", icon: "person.2.fill", color: .blue)
                KPICard(title: "Active Users", value: "8,234", change: "+8%", icon: "person.fill.checkmark", color: .green)
                KPICard(title: "Sessions", value: "45,678", change: "+15%", icon: "chart.line.uptrend.xyaxis", color: .purple)
                KPICard(title: "Avg. Duration", value: "4m 32s", change: "+5%", icon: "clock.fill", color: .orange)
            }
            
            // Charts
            HStack(spacing: 16) {
                // Line Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("User Activity").font(.headline)
                    AnalyticsLineChart()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                
                // Pie Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Traffic Sources").font(.headline)
                    AnalyticsPieChart()
                }
                .padding()
                .frame(width: 300)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            }
            
            // Top Pages
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Top Pages").font(.headline)
                    TopPagesTable()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("User Demographics").font(.headline)
                    DemographicsChart()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            }
        }
        .padding()
    }
}

struct KPICard: View {
    let title: String
    let value: String
    let change: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon).foregroundStyle(color)
                Spacer()
                Text(change).font(.caption).foregroundStyle(change.hasPrefix("+") ? .green : .red)
            }
            
            Text(value).font(.title.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
    }
}

struct AnalyticsLineChart: View {
    let data: [Double] = [30, 45, 35, 50, 65, 55, 70, 80, 75, 90, 85, 95]
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 100
            let stepX = geometry.size.width / CGFloat(data.count - 1)
            
            ZStack {
                // Grid lines
                ForEach(0..<5, id: \.self) { i in
                    Path { path in
                        let y = geometry.size.height * CGFloat(i) / 4
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }
                
                // Line
                Path { path in
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height * (1 - CGFloat(value) / maxValue)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.purple, lineWidth: 2)
                
                // Area
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height * (1 - CGFloat(value) / maxValue)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(LinearGradient(colors: [Color.purple.opacity(0.3), Color.purple.opacity(0)], startPoint: .top, endPoint: .bottom))
            }
        }
        .frame(height: 200)
    }
}

struct AnalyticsPieChart: View {
    let data: [(String, Double, Color)] = [
        ("Direct", 35, .blue),
        ("Organic", 28, .green),
        ("Referral", 20, .orange),
        ("Social", 12, .purple),
        ("Other", 5, .secondary),
    ]
    
    var body: some View {
        HStack {
            // Pie
            ZStack {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    AnalyticsPieSlice(startAngle: startAngle(for: index), endAngle: endAngle(for: index))
                        .fill(item.2)
                }
            }
            .frame(width: 120, height: 120)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(data, id: \.0) { item in
                    HStack(spacing: 8) {
                        Circle().fill(item.2).frame(width: 10, height: 10)
                        Text(item.0).font(.caption)
                        Spacer()
                        Text("\(Int(item.1))%").font(.caption.bold())
                    }
                }
            }
        }
    }
    
    func startAngle(for index: Int) -> Angle {
        let total = data.prefix(index).reduce(0) { $0 + $1.1 }
        return .degrees(total * 3.6 - 90)
    }
    
    func endAngle(for index: Int) -> Angle {
        let total = data.prefix(index + 1).reduce(0) { $0 + $1.1 }
        return .degrees(total * 3.6 - 90)
    }
}

struct AnalyticsPieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

struct TopPagesTable: View {
    let pages = [
        ("/home", "12,458", "45%"),
        ("/products", "8,234", "32%"),
        ("/about", "4,567", "18%"),
        ("/contact", "2,345", "12%"),
        ("/blog", "1,890", "8%"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Page").font(.caption.bold()).frame(maxWidth: .infinity, alignment: .leading)
                Text("Views").font(.caption.bold()).frame(width: 80)
                Text("Bounce").font(.caption.bold()).frame(width: 60)
            }
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.1))
            
            ForEach(pages, id: \.0) { page in
                HStack {
                    Text(page.0).font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                    Text(page.1).font(.caption).frame(width: 80)
                    Text(page.2).font(.caption).frame(width: 60)
                }
                .padding(.vertical, 6)
                Divider()
            }
        }
    }
}

struct DemographicsChart: View {
    let data = [
        ("18-24", 15),
        ("25-34", 35),
        ("35-44", 25),
        ("45-54", 15),
        ("55+", 10),
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(data, id: \.0) { item in
                HStack {
                    Text(item.0).font(.caption).frame(width: 50, alignment: .leading)
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.purple)
                            .frame(width: geometry.size.width * CGFloat(item.1) / 100)
                    }
                    .frame(height: 20)
                    Text("\(item.1)%").font(.caption).frame(width: 40)
                }
            }
        }
    }
}

struct EventsView: View {
    let events = [
        ("page_view", "45,678", "Active"),
        ("button_click", "23,456", "Active"),
        ("form_submit", "12,345", "Active"),
        ("purchase", "5,678", "Active"),
        ("signup", "2,345", "Active"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Events").font(.headline)
                Spacer()
                Button("Create Event") {}.buttonStyle(.borderedProminent).tint(.purple)
            }
            
            List {
                ForEach(events, id: \.0) { event in
                    HStack {
                        Image(systemName: "bolt.fill").foregroundStyle(.purple)
                        VStack(alignment: .leading) {
                            Text(event.0).font(.subheadline)
                            Text("\(event.1) occurrences").font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(event.2).font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color.green.opacity(0.2)))
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct FunnelsView: View {
    let steps = [
        ("Visit Homepage", 10000, 100),
        ("View Product", 6500, 65),
        ("Add to Cart", 3200, 32),
        ("Checkout", 1800, 18),
        ("Purchase", 1200, 12),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Conversion Funnel").font(.headline)
                Spacer()
                Button("Create Funnel") {}.buttonStyle(.bordered)
            }
            
            VStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack {
                        Text(step.0).font(.subheadline).frame(width: 150, alignment: .leading)
                        
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.purple.opacity(Double(step.2) / 100 + 0.3))
                                .frame(width: geometry.size.width * CGFloat(step.2) / 100)
                        }
                        .frame(height: 40)
                        
                        VStack(alignment: .trailing) {
                            Text("\(step.1)").font(.subheadline.bold())
                            Text("\(step.2)%").font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(width: 80)
                    }
                    
                    if index < steps.count - 1 {
                        HStack {
                            Spacer().frame(width: 150)
                            Image(systemName: "arrow.down").foregroundStyle(.secondary)
                            Text("-\(steps[index].2 - steps[index + 1].2)%").font(.caption).foregroundStyle(.red)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
        }
        .padding()
    }
}

struct CohortsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cohort Analysis").font(.headline)
                Spacer()
                Button("Create Cohort") {}.buttonStyle(.bordered)
            }
            
            // Cohort Table
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Week").font(.caption.bold()).frame(width: 80)
                    ForEach(0..<8, id: \.self) { i in
                        Text("W\(i)").font(.caption.bold()).frame(width: 60)
                    }
                }
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.1))
                
                ForEach(0..<6, id: \.self) { row in
                    HStack(spacing: 0) {
                        Text("Nov \(row + 1)").font(.caption).frame(width: 80)
                        ForEach(0..<(8 - row), id: \.self) { col in
                            let value = max(10, 100 - col * 12 - row * 5)
                            Text("\(value)%")
                                .font(.caption2)
                                .frame(width: 60, height: 30)
                                .background(Color.purple.opacity(Double(value) / 100))
                        }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
        }
        .padding()
    }
}

#Preview {
    AnalyticsSystemView()
        .frame(width: 1100, height: 800)
}
