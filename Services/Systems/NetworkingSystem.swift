//
//  NetworkingSystem.swift
//  HIG
//
//  Networking System - API clients, WebSocket, GraphQL
//

import SwiftUI

struct NetworkingSystemView: View {
    @State private var selectedTab = "REST"
    @State private var requests: [NetworkRequest] = NetworkRequest.samples
    @State private var selectedRequest: NetworkRequest?
    @State private var isLoading = false
    @State private var responseBody = ""
    
    let tabs = ["REST", "WebSocket", "GraphQL", "gRPC"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "network").font(.title2).foregroundStyle(.blue)
                Text("Networking System").font(.title2.bold())
                Spacer()
                
                Picker("", selection: $selectedTab) {
                    ForEach(tabs, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
                .frame(width: 350)
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            HSplitView {
                // Request List
                VStack(spacing: 0) {
                    HStack {
                        Text("Requests").font(.headline)
                        Spacer()
                        Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered)
                    }
                    .padding()
                    
                    Divider()
                    
                    List(requests, selection: $selectedRequest) { request in
                        RequestRow(request: request).tag(request)
                    }
                    .listStyle(.plain)
                }
                .frame(minWidth: 280)
                
                // Request Builder
                VStack(spacing: 0) {
                    if let request = selectedRequest {
                        RequestBuilderView(request: request, isLoading: $isLoading, responseBody: $responseBody)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "arrow.left.arrow.right").font(.system(size: 60)).foregroundStyle(.secondary)
                            Text("Select a request").foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}

struct RequestRow: View {
    let request: NetworkRequest
    
    var body: some View {
        HStack(spacing: 12) {
            Text(request.method.rawValue)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 4).fill(request.method.color))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(request.name).font(.subheadline)
                Text(request.endpoint).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RequestBuilderView: View {
    let request: NetworkRequest
    @Binding var isLoading: Bool
    @Binding var responseBody: String
    
    @State private var url = ""
    @State private var method: HTTPMethod = .get
    @State private var headers: [(String, String)] = [("Content-Type", "application/json")]
    @State private var requestBody = ""
    @State private var selectedTab = "Headers"
    
    var body: some View {
        VStack(spacing: 0) {
            // URL Bar
            HStack {
                Picker("", selection: $method) {
                    ForEach(HTTPMethod.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .frame(width: 100)
                
                TextField("Enter URL", text: $url)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
                
                Button {
                    sendRequest()
                } label: {
                    if isLoading {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Text("Send")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
            }
            .padding()
            
            Divider()
            
            // Tabs
            HStack(spacing: 0) {
                ForEach(["Headers", "Body", "Auth", "Params"], id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Text(tab)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTab == tab ? Color.blue.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            // Tab Content
            Group {
                switch selectedTab {
                case "Headers": HeadersEditor(headers: $headers)
                case "Body": BodyEditor(requestBody: $requestBody)
                case "Auth": AuthEditor()
                case "Params": ParamsEditor()
                default: EmptyView()
                }
            }
            .frame(height: 200)
            
            Divider()
            
            // Response
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Response").font(.headline)
                    Spacer()
                    if !responseBody.isEmpty {
                        Text("200 OK").font(.caption).foregroundStyle(.green)
                        Text("• 245ms").font(.caption).foregroundStyle(.secondary)
                    }
                }
                
                ScrollView {
                    Text(responseBody.isEmpty ? "No response yet" : responseBody)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(responseBody.isEmpty ? .secondary : .primary)
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.textBackgroundColor)))
            }
            .padding()
        }
        .onAppear {
            url = request.endpoint
            method = request.method
        }
    }
    
    func sendRequest() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            responseBody = """
            {
              "status": "success",
              "data": {
                "id": 1,
                "name": "Sample Response",
                "timestamp": "\(Date())"
              }
            }
            """
            isLoading = false
        }
    }
}

struct HeadersEditor: View {
    @Binding var headers: [(String, String)]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(headers.indices, id: \.self) { index in
                HStack {
                    TextField("Key", text: Binding(get: { headers[index].0 }, set: { headers[index].0 = $0 }))
                        .textFieldStyle(.roundedBorder)
                    TextField("Value", text: Binding(get: { headers[index].1 }, set: { headers[index].1 = $0 }))
                        .textFieldStyle(.roundedBorder)
                    Button { headers.remove(at: index) } label: { Image(systemName: "minus.circle") }.buttonStyle(.plain)
                }
            }
            Button { headers.append(("", "")) } label: { Label("Add Header", systemImage: "plus") }.buttonStyle(.bordered)
        }
        .padding()
    }
}

struct BodyEditor: View {
    @Binding var requestBody: String
    
    var body: some View {
        TextEditor(text: $requestBody)
            .font(.system(.caption, design: .monospaced))
            .padding()
    }
}

struct AuthEditor: View {
    @State private var authType = "Bearer Token"
    @State private var token = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Type", selection: $authType) {
                Text("None").tag("None")
                Text("Bearer Token").tag("Bearer Token")
                Text("Basic Auth").tag("Basic Auth")
                Text("API Key").tag("API Key")
            }
            
            if authType == "Bearer Token" {
                TextField("Token", text: $token).textFieldStyle(.roundedBorder)
            }
        }
        .padding()
    }
}

struct ParamsEditor: View {
    @State private var params: [(String, String)] = []
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(params.indices, id: \.self) { index in
                HStack {
                    TextField("Key", text: Binding(get: { params[index].0 }, set: { params[index].0 = $0 }))
                        .textFieldStyle(.roundedBorder)
                    TextField("Value", text: Binding(get: { params[index].1 }, set: { params[index].1 = $0 }))
                        .textFieldStyle(.roundedBorder)
                }
            }
            Button { params.append(("", "")) } label: { Label("Add Parameter", systemImage: "plus") }.buttonStyle(.bordered)
        }
        .padding()
    }
}

enum HTTPMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    
    var color: Color {
        switch self {
        case .get: return .green
        case .post: return .blue
        case .put: return .orange
        case .patch: return .purple
        case .delete: return .red
        }
    }
}

struct NetworkRequest: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let endpoint: String
    let method: HTTPMethod
    
    static var samples: [NetworkRequest] {
        [
            NetworkRequest(name: "Get Users", endpoint: "https://api.example.com/users", method: .get),
            NetworkRequest(name: "Create User", endpoint: "https://api.example.com/users", method: .post),
            NetworkRequest(name: "Update User", endpoint: "https://api.example.com/users/1", method: .put),
            NetworkRequest(name: "Delete User", endpoint: "https://api.example.com/users/1", method: .delete),
            NetworkRequest(name: "Get Products", endpoint: "https://api.example.com/products", method: .get),
        ]
    }
}

#Preview {
    NetworkingSystemView()
        .frame(width: 1000, height: 700)
}
