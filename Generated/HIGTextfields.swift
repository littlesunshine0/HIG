//
//  HIGTextFields.swift
//  Generated from Apple Human Interface Guidelines
//
//  HIG-compliant text input components
//
//  Generated: 2025-11-25
//

import SwiftUI

// MARK: - HIG Text Fields

/// Standard text field with label
struct HIGTextField: View {
    let label: String
    @Binding var text: String
    var prompt: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(label, text: $text, prompt: Text(prompt))
                .textFieldStyle(.roundedBorder)
        }
    }
}

/// Secure text field for passwords
struct HIGSecureField: View {
    let label: String
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Group {
                    if isVisible {
                        TextField(label, text: $text)
                    } else {
                        SecureField(label, text: $text)
                    }
                }
                .textFieldStyle(.roundedBorder)

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isVisible ? "Hide password" : "Show password")
            }
        }
    }
}

/// Multi-line text editor
struct HIGTextEditor: View {
    let label: String
    @Binding var text: String
    var minHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.quaternary, lineWidth: 1)
                )
        }
    }
}

/// Search field with HIG styling
struct HIGSearchField: View {
    @Binding var text: String
    var prompt: String = "Search"
    var onSubmit: () -> Void = {}

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(prompt, text: $text)
                .textFieldStyle(.plain)
                .onSubmit(onSubmit)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview("HIG Text Fields") {
    Form {
        HIGTextField(label: "Name", text: .constant(""), prompt: "Enter your name")
        HIGSecureField(label: "Password", text: .constant(""))
        HIGTextEditor(label: "Notes", text: .constant(""))
        HIGSearchField(text: .constant(""))
    }
    .padding()
}
