//
//  LocalizationSystem.swift
//  HIG
//
//  Localization (i18n) System - Translations, currency, time zones
//

import SwiftUI

struct LocalizationSystemView: View {
    @State private var selectedTab = "Translations"
    @State private var selectedLanguage = "en"
    
    let tabs = ["Translations", "Languages", "Formatting", "Import/Export"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "globe").font(.title2).foregroundStyle(.teal)
                Text("Localization System").font(.title2.bold())
                Spacer()
                Text("12 languages • 1,245 strings").font(.caption).foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        Text(tab).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.teal.opacity(0.2) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(.regularMaterial)
            
            Divider()
            
            Group {
                switch selectedTab {
                case "Translations": TranslationsView(selectedLanguage: $selectedLanguage)
                case "Languages": LanguagesView()
                case "Formatting": FormattingView()
                case "Import/Export": ImportExportView()
                default: EmptyView()
                }
            }
        }
    }
}

struct TranslationsView: View {
    @Binding var selectedLanguage: String
    @State private var searchText = ""
    
    let translations: [(String, String, String, String)] = [
        ("welcome.title", "Welcome", "Bienvenido", "Willkommen"),
        ("welcome.subtitle", "Get started", "Comenzar", "Loslegen"),
        ("button.save", "Save", "Guardar", "Speichern"),
        ("button.cancel", "Cancel", "Cancelar", "Abbrechen"),
        ("error.network", "Network error", "Error de red", "Netzwerkfehler"),
    ]
    
    var body: some View {
        HSplitView {
            // Keys List
            VStack(spacing: 0) {
                HStack {
                    TextField("Search keys...", text: $searchText).textFieldStyle(.roundedBorder)
                    Button { } label: { Image(systemName: "plus") }.buttonStyle(.bordered)
                }
                .padding()
                
                Divider()
                
                List {
                    ForEach(translations, id: \.0) { t in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(t.0).font(.caption.monospaced())
                            Text(t.1).font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 250)
            
            // Translation Editor
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Edit Translation").font(.headline)
                    Spacer()
                    Picker("Language", selection: $selectedLanguage) {
                        Text("English").tag("en")
                        Text("Spanish").tag("es")
                        Text("German").tag("de")
                        Text("French").tag("fr")
                    }
                    .frame(width: 150)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key").font(.caption).foregroundStyle(.secondary)
                    TextField("", text: .constant("welcome.title")).textFieldStyle(.roundedBorder).disabled(true)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("English (Base)").font(.caption).foregroundStyle(.secondary)
                    TextField("", text: .constant("Welcome")).textFieldStyle(.roundedBorder).disabled(true)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Translation").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Button("Auto-translate") {}.buttonStyle(.bordered).controlSize(.small)
                    }
                    TextEditor(text: .constant("Bienvenido"))
                        .frame(height: 80)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Context / Notes").font(.caption).foregroundStyle(.secondary)
                    TextField("Add context for translators...", text: .constant("")).textFieldStyle(.roundedBorder)
                }
                
                Spacer()
                
                HStack {
                    Button("Revert") {}.buttonStyle(.bordered)
                    Spacer()
                    Button("Save") {}.buttonStyle(.borderedProminent).tint(.teal)
                }
            }
            .padding()
        }
    }
}

struct LanguagesView: View {
    let languages = [
        ("English", "en", 100, true),
        ("Spanish", "es", 98, true),
        ("German", "de", 95, true),
        ("French", "fr", 92, true),
        ("Japanese", "ja", 85, true),
        ("Chinese", "zh", 78, false),
        ("Portuguese", "pt", 65, false),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Languages").font(.headline)
                Spacer()
                Button("Add Language") {}.buttonStyle(.borderedProminent).tint(.teal)
            }
            
            List {
                ForEach(languages, id: \.1) { lang in
                    HStack {
                        Text(lang.0).font(.subheadline)
                        Text(lang.1).font(.caption).foregroundStyle(.secondary).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Color(.controlBackgroundColor)))
                        
                        Spacer()
                        
                        // Progress
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(lang.2)%").font(.caption)
                            ProgressView(value: Double(lang.2) / 100).frame(width: 100)
                                .tint(lang.2 == 100 ? .green : (lang.2 > 80 ? .blue : .orange))
                        }
                        
                        Toggle("", isOn: .constant(lang.3)).labelsHidden()
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct FormattingView: View {
    @State private var dateFormat = "MM/dd/yyyy"
    @State private var timeFormat = "12h"
    @State private var currency = "USD"
    @State private var timezone = "America/New_York"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Regional Formatting").font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Date Format").frame(width: 120, alignment: .leading)
                    Picker("", selection: $dateFormat) {
                        Text("MM/dd/yyyy").tag("MM/dd/yyyy")
                        Text("dd/MM/yyyy").tag("dd/MM/yyyy")
                        Text("yyyy-MM-dd").tag("yyyy-MM-dd")
                    }
                    Text("Preview: 11/27/2024").font(.caption).foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Time Format").frame(width: 120, alignment: .leading)
                    Picker("", selection: $timeFormat) {
                        Text("12-hour").tag("12h")
                        Text("24-hour").tag("24h")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    Text("Preview: 2:30 PM").font(.caption).foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Currency").frame(width: 120, alignment: .leading)
                    Picker("", selection: $currency) {
                        Text("USD ($)").tag("USD")
                        Text("EUR (€)").tag("EUR")
                        Text("GBP (£)").tag("GBP")
                        Text("JPY (¥)").tag("JPY")
                    }
                    Text("Preview: $1,234.56").font(.caption).foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Timezone").frame(width: 120, alignment: .leading)
                    Picker("", selection: $timezone) {
                        Text("Eastern (ET)").tag("America/New_York")
                        Text("Pacific (PT)").tag("America/Los_Angeles")
                        Text("UTC").tag("UTC")
                        Text("Central European").tag("Europe/Paris")
                    }
                }
                
                Divider()
                
                Text("Number Formatting").font(.subheadline)
                HStack {
                    Text("Decimal: 1,234.56").font(.caption)
                    Text("•").foregroundStyle(.secondary)
                    Text("Percentage: 45.5%").font(.caption)
                    Text("•").foregroundStyle(.secondary)
                    Text("Large: 1.2M").font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            Spacer()
        }
        .padding()
    }
}

struct ImportExportView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Import
            VStack(spacing: 16) {
                Image(systemName: "square.and.arrow.down.fill").font(.system(size: 40)).foregroundStyle(.teal)
                Text("Import Translations").font(.headline)
                Text("Supported formats: JSON, XLIFF, CSV, PO").font(.caption).foregroundStyle(.secondary)
                
                HStack {
                    Button("Import JSON") {}.buttonStyle(.bordered)
                    Button("Import XLIFF") {}.buttonStyle(.bordered)
                    Button("Import CSV") {}.buttonStyle(.bordered)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            // Export
            VStack(spacing: 16) {
                Image(systemName: "square.and.arrow.up.fill").font(.system(size: 40)).foregroundStyle(.blue)
                Text("Export Translations").font(.headline)
                Text("Export all or selected languages").font(.caption).foregroundStyle(.secondary)
                
                HStack {
                    Button("Export JSON") {}.buttonStyle(.bordered)
                    Button("Export XLIFF") {}.buttonStyle(.bordered)
                    Button("Export All") {}.buttonStyle(.borderedProminent).tint(.teal)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
        }
        .padding()
    }
}

#Preview { LocalizationSystemView().frame(width: 1000, height: 700) }
