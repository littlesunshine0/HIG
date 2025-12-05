//
//  AuthenticationSystem.swift
//  HIG
//
//  Authentication System - Login, registration, SSO, MFA, password recovery
//

import SwiftUI

struct AuthenticationSystemView: View {
    @State private var selectedTab = "Login"
    @State private var email = ""
    @State private var password = ""
    @State private var mfaCode = ""
    @State private var isLoading = false
    
    let tabs = ["Login", "Register", "SSO", "MFA", "Recovery"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "person.badge.key.fill").font(.title2).foregroundStyle(.blue)
                Text("Authentication System").font(.title2.bold())
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.blue.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "Login": LoginView(email: $email, password: $password, isLoading: $isLoading)
                case "Register": RegisterView()
                case "SSO": SSOView()
                case "MFA": MFAView(code: $mfaCode)
                case "Recovery": RecoveryView()
                default: EmptyView()
                }
            }
        }
    }
}

struct LoginView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isLoading: Bool
    @State private var rememberMe = false
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "person.circle.fill").font(.system(size: 80)).foregroundStyle(.blue)
                Text("Welcome Back").font(.title.bold())
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email).textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
                    
                    HStack {
                        Toggle("Remember me", isOn: $rememberMe).font(.caption)
                        Spacer()
                        Button("Forgot password?") {}.font(.caption)
                    }
                }
                .frame(width: 300)
                
                Button { isLoading = true } label: {
                    if isLoading { ProgressView().scaleEffect(0.8) }
                    else { Text("Sign In").frame(width: 280) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty)
                
                Divider().frame(width: 300)
                
                Text("Or continue with").font(.caption).foregroundStyle(.secondary)
                
                HStack(spacing: 16) {
                    SSOButton(provider: "Apple", icon: "apple.logo")
                    SSOButton(provider: "Google", icon: "g.circle.fill")
                    SSOButton(provider: "GitHub", icon: "chevron.left.forwardslash.chevron.right")
                }
            }
            .padding(40)
            Spacer()
        }
    }
}

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeTerms = false
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "person.badge.plus.fill").font(.system(size: 60)).foregroundStyle(.green)
                Text("Create Account").font(.title.bold())
                
                VStack(spacing: 12) {
                    TextField("Full Name", text: $name).textFieldStyle(.roundedBorder)
                    TextField("Email", text: $email).textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
                    SecureField("Confirm Password", text: $confirmPassword).textFieldStyle(.roundedBorder)
                    
                    // Password strength
                    HStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2).fill(i < passwordStrength ? strengthColor : Color.secondary.opacity(0.3)).frame(height: 4)
                        }
                    }
                    Text(strengthText).font(.caption2).foregroundStyle(.secondary)
                    
                    Toggle("I agree to Terms & Privacy Policy", isOn: $agreeTerms).font(.caption)
                }
                .frame(width: 300)
                
                Button("Create Account") {}.buttonStyle(.borderedProminent).frame(width: 300).disabled(!agreeTerms)
            }
            .padding(40)
            Spacer()
        }
    }
    
    var passwordStrength: Int {
        var strength = 0
        if password.count >= 8 { strength += 1 }
        if password.contains(where: { $0.isUppercase }) { strength += 1 }
        if password.contains(where: { $0.isNumber }) { strength += 1 }
        if password.contains(where: { "!@#$%^&*".contains($0) }) { strength += 1 }
        return strength
    }
    
    var strengthColor: Color {
        switch passwordStrength {
        case 0...1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .green
        }
    }
    
    var strengthText: String {
        switch passwordStrength {
        case 0...1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        default: return "Strong"
        }
    }
}

struct SSOView: View {
    let providers = [
        ("Apple", "apple.logo", Color.primary),
        ("Google", "g.circle.fill", Color.red),
        ("Microsoft", "window.ceiling", Color.blue),
        ("GitHub", "chevron.left.forwardslash.chevron.right", Color.purple),
        ("Okta", "shield.fill", Color.blue),
        ("Auth0", "lock.shield.fill", Color.orange),
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Single Sign-On").font(.title.bold())
            Text("Connect with your identity provider").foregroundStyle(.secondary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                ForEach(providers, id: \.0) { provider in
                    Button {
                    } label: {
                        HStack {
                            Image(systemName: provider.1).foregroundStyle(provider.2)
                            Text("Continue with \(provider.0)")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: 500)
            
            Divider()
            
            Text("Enterprise SSO").font(.headline)
            TextField("Enter your company domain", text: .constant("")).textFieldStyle(.roundedBorder).frame(width: 300)
            Button("Continue") {}.buttonStyle(.bordered)
        }
        .padding()
    }
}

struct MFAView: View {
    @Binding var code: String
    @State private var mfaMethod = "Authenticator"
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill").font(.system(size: 60)).foregroundStyle(.green)
            Text("Two-Factor Authentication").font(.title.bold())
            
            Picker("Method", selection: $mfaMethod) {
                Text("Authenticator App").tag("Authenticator")
                Text("SMS").tag("SMS")
                Text("Email").tag("Email")
            }
            .pickerStyle(.segmented)
            .frame(width: 350)
            
            if mfaMethod == "Authenticator" {
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 12).fill(Color.white).frame(width: 150, height: 150)
                        .overlay(Image(systemName: "qrcode").font(.system(size: 100)))
                    Text("Scan with your authenticator app").font(.caption)
                }
            }
            
            VStack(spacing: 8) {
                Text("Enter verification code").font(.subheadline)
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { i in
                        TextField("", text: .constant(i < code.count ? String(code[code.index(code.startIndex, offsetBy: i)]) : ""))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 45, height: 50)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Button("Verify") {}.buttonStyle(.borderedProminent).frame(width: 300)
            Button("Use backup code") {}.font(.caption)
        }
        .padding()
    }
}

struct RecoveryView: View {
    @State private var email = ""
    @State private var sent = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: sent ? "checkmark.circle.fill" : "key.fill").font(.system(size: 60)).foregroundStyle(sent ? .green : .orange)
            Text(sent ? "Check Your Email" : "Reset Password").font(.title.bold())
            Text(sent ? "We've sent recovery instructions to your email" : "Enter your email to receive reset instructions").foregroundStyle(.secondary).multilineTextAlignment(.center)
            
            if !sent {
                TextField("Email", text: $email).textFieldStyle(.roundedBorder).frame(width: 300)
                Button("Send Reset Link") { sent = true }.buttonStyle(.borderedProminent).frame(width: 300)
            } else {
                Button("Open Email App") {}.buttonStyle(.borderedProminent)
                Button("Resend Email") {}.buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

struct SSOButton: View {
    let provider: String
    let icon: String
    
    var body: some View {
        Button {} label: {
            Image(systemName: icon).font(.title2).frame(width: 50, height: 50)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
        }
        .buttonStyle(.plain)
    }
}

#Preview { AuthenticationSystemView().frame(width: 800, height: 600) }
