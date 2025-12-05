import SwiftUI

/// External API Documentation for third-party developers
struct ExternalAPIDocumentation: View {
    @State private var selectedEndpoint: APIEndpointDoc?
    @State private var apiKey = "sk_live_..."
    @State private var showKeyGenerator = false
    
    var body: some View {
        NavigationSplitView {
            List(APIEndpointDoc.allEndpoints, selection: $selectedEndpoint) { endpoint in
                EndpointListItem(endpoint: endpoint)
            }
            .navigationTitle("API Documentation")
        } detail: {
            if let endpoint = selectedEndpoint {
                EndpointDetailView(endpoint: endpoint)
            } else {
                APIOverviewView()
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Generate API Key") {
                    showKeyGenerator = true
                }
            }
        }
        .sheet(isPresented: $showKeyGenerator) {
            APIKeyGeneratorSheet()
        }
    }
}

// MARK: - API Overview
struct APIOverviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeroSection()
                QuickStartSection()
                AuthenticationSection()
                RateLimitsSection()
                SDKSection()
            }
            .padding()
        }
    }
}

struct HeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HIG API")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Build powerful applications with our RESTful API")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 16) {
                InfoBadge(label: "REST", icon: "network")
                InfoBadge(label: "JSON", icon: "doc.text")
                InfoBadge(label: "OAuth 2.0", icon: "lock.shield")
            }
        }
    }
}

struct InfoBadge: View {
    let label: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(label)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.accentColor.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct QuickStartSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.title2)
                .fontWeight(.semibold)
            
            CodeBlock(code: """
            curl https://api.hig.app/v1/users \\
              -H "Authorization: Bearer YOUR_API_KEY" \\
              -H "Content-Type: application/json"
            """)
            
            Text("Get your API key from the dashboard to start making requests.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct AuthenticationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Authentication")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("All API requests require authentication using Bearer tokens:")
                .foregroundStyle(.secondary)
            
            CodeBlock(code: """
            Authorization: Bearer sk_live_your_api_key_here
            """)
        }
    }
}

struct RateLimitsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rate Limits")
                .font(.title2)
                .fontWeight(.semibold)
            
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                GridRow {
                    Text("Plan").fontWeight(.semibold)
                    Text("Requests/Hour").fontWeight(.semibold)
                    Text("Burst").fontWeight(.semibold)
                }
                Divider()
                GridRow {
                    Text("Free")
                    Text("100")
                    Text("10")
                }
                GridRow {
                    Text("Basic")
                    Text("1,000")
                    Text("50")
                }
                GridRow {
                    Text("Pro")
                    Text("10,000")
                    Text("200")
                }
                GridRow {
                    Text("Enterprise")
                    Text("Unlimited")
                    Text("Unlimited")
                }
            }
            .font(.system(.body, design: .monospaced))
        }
    }
}

struct SDKSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Official SDKs")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                SDKCard(name: "JavaScript", icon: "js.circle.fill", color: .yellow)
                SDKCard(name: "Python", icon: "p.circle.fill", color: .blue)
                SDKCard(name: "Swift", icon: "swift", color: .orange)
                SDKCard(name: "Go", icon: "g.circle.fill", color: .cyan)
            }
        }
    }
}

struct SDKCard: View {
    let name: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(name)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Endpoint Detail
struct EndpointDetailView: View {
    let endpoint: APIEndpointDoc
    @State private var selectedLanguage: CodeLanguage = .curl
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        MethodBadge(method: endpoint.method)
                        Text(endpoint.path)
                            .font(.system(.title3, design: .monospaced))
                    }
                    
                    Text(endpoint.description)
                        .foregroundStyle(.secondary)
                }
                
                // Request
                VStack(alignment: .leading, spacing: 12) {
                    Text("Request")
                        .font(.headline)
                    
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(CodeLanguage.allCases, id: \.self) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    CodeBlock(code: endpoint.exampleRequest(language: selectedLanguage))
                }
                
                // Parameters
                if !endpoint.parameters.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Parameters")
                            .font(.headline)
                        
                        ForEach(endpoint.parameters) { param in
                            ParameterRow(parameter: param)
                        }
                    }
                }
                
                // Response
                VStack(alignment: .leading, spacing: 12) {
                    Text("Response")
                        .font(.headline)
                    
                    CodeBlock(code: endpoint.exampleResponse)
                }
            }
            .padding()
        }
    }
}

struct MethodBadge: View {
    let method: String
    
    var color: Color {
        switch method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        Text(method)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct ParameterRow: View {
    let parameter: APIParameter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(parameter.name)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                
                Text(parameter.type)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
                
                if parameter.required {
                    Text("required")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            
            Text(parameter.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CodeBlock: View {
    let code: String
    
    var body: some View {
        ScrollView(.horizontal) {
            Text(code)
                .font(.system(.body, design: .monospaced))
                .padding()
        }
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct EndpointListItem: View {
    let endpoint: APIEndpointDoc
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                MethodBadge(method: endpoint.method)
                Text(endpoint.path)
                    .font(.system(.caption, design: .monospaced))
            }
            Text(endpoint.title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}


// MARK: - API Key Generator
struct APIKeyGeneratorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var keyName = ""
    @State private var selectedPermissions: Set<String> = []
    @State private var generatedKey: String?
    
    var body: some View {
        NavigationStack {
            Form {
                if let key = generatedKey {
                    Section("Your API Key") {
                        Text(key)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                        
                        Text("Save this key securely. You won't be able to see it again.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } else {
                    Section("Key Information") {
                        TextField("Key Name", text: $keyName)
                    }
                    
                    Section("Permissions") {
                        ForEach(["read", "write", "delete", "admin"], id: \.self) { permission in
                            Toggle(permission, isOn: Binding(
                                get: { selectedPermissions.contains(permission) },
                                set: { isOn in
                                    if isOn {
                                        selectedPermissions.insert(permission)
                                    } else {
                                        selectedPermissions.remove(permission)
                                    }
                                }
                            ))
                        }
                    }
                }
            }
            .navigationTitle("Generate API Key")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if generatedKey == nil {
                        Button("Generate") {
                            generatedKey = "sk_live_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
                        }
                    } else {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }
}

// MARK: - Models
struct APIEndpointDoc: Identifiable, Hashable {
    let id: UUID
    let method: String
    let path: String
    let title: String
    let description: String
    let parameters: [APIParameter]
    let exampleResponse: String
    
    init(method: String, path: String, title: String, description: String, parameters: [APIParameter], exampleResponse: String) {
        self.id = UUID()
        self.method = method
        self.path = path
        self.title = title
        self.description = description
        self.parameters = parameters
        self.exampleResponse = exampleResponse
    }
    
    static func == (lhs: APIEndpointDoc, rhs: APIEndpointDoc) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func exampleRequest(language: CodeLanguage) -> String {
        switch language {
        case .curl:
            return """
            curl -X \(method) https://api.hig.app\(path) \\
              -H "Authorization: Bearer YOUR_API_KEY" \\
              -H "Content-Type: application/json"
            """
        case .javascript:
            return """
            const response = await fetch('https://api.hig.app\(path)', {
              method: '\(method)',
              headers: {
                'Authorization': 'Bearer YOUR_API_KEY',
                'Content-Type': 'application/json'
              }
            });
            const data = await response.json();
            """
        case .python:
            return """
            import requests
            
            response = requests.\(method.lowercased())(
                'https://api.hig.app\(path)',
                headers={'Authorization': 'Bearer YOUR_API_KEY'}
            )
            data = response.json()
            """
        case .swift:
            return """
            let url = URL(string: "https://api.hig.app\(path)")!
            var request = URLRequest(url: url)
            request.httpMethod = "\(method)"
            request.setValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            """
        }
    }
    
    static let allEndpoints: [APIEndpointDoc] = [
        APIEndpointDoc(
            method: "GET",
            path: "/v1/users",
            title: "List Users",
            description: "Retrieve a list of all users",
            parameters: [
                APIParameter(name: "limit", type: "integer", description: "Number of results to return", required: false),
                APIParameter(name: "offset", type: "integer", description: "Pagination offset", required: false)
            ],
            exampleResponse: """
            {
              "users": [
                {
                  "id": "usr_123",
                  "email": "user@example.com",
                  "created_at": "2025-01-01T00:00:00Z"
                }
              ],
              "total": 1,
              "has_more": false
            }
            """
        ),
        APIEndpointDoc(
            method: "POST",
            path: "/v1/users",
            title: "Create User",
            description: "Create a new user",
            parameters: [
                APIParameter(name: "email", type: "string", description: "User email address", required: true),
                APIParameter(name: "name", type: "string", description: "User full name", required: true)
            ],
            exampleResponse: """
            {
              "id": "usr_123",
              "email": "user@example.com",
              "name": "John Doe",
              "created_at": "2025-01-01T00:00:00Z"
            }
            """
        ),
        APIEndpointDoc(
            method: "GET",
            path: "/v1/analytics",
            title: "Get Analytics",
            description: "Retrieve analytics data",
            parameters: [
                APIParameter(name: "start_date", type: "string", description: "Start date (ISO 8601)", required: true),
                APIParameter(name: "end_date", type: "string", description: "End date (ISO 8601)", required: true)
            ],
            exampleResponse: """
            {
              "metrics": {
                "total_requests": 12453,
                "unique_users": 342,
                "average_latency": 45.2
              },
              "period": {
                "start": "2025-01-01",
                "end": "2025-01-31"
              }
            }
            """
        ),
        APIEndpointDoc(
            method: "GET",
            path: "/v1/billing/usage",
            title: "Get Usage",
            description: "Retrieve current billing usage",
            parameters: [],
            exampleResponse: """
            {
              "current_period": {
                "start": "2025-01-01",
                "end": "2025-01-31"
              },
              "usage": {
                "requests": 6745,
                "limit": 10000,
                "overage": 0
              },
              "cost": {
                "base": 29.00,
                "overage": 0.00,
                "total": 29.00
              }
            }
            """
        )
    ]
}

struct APIParameter: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let description: String
    let required: Bool
}

enum CodeLanguage: String, CaseIterable {
    case curl = "cURL"
    case javascript = "JavaScript"
    case python = "Python"
    case swift = "Swift"
}
