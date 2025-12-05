# How‑to — Build & Ship App Icons (v1.0)

This guide walks you from design to implementation using Icon Composer (or image stacks) and the runtime APIs in `AppIcons.swift`.

---

## 1) Design the Icon (All Platforms)

1. Start with **simple, centered** foreground geometry.
2. Build a **full‑bleed, opaque** background (solid or subtle vertical gradient).
3. Layer **crisp‑edged** foreground shapes; vary **opacity** to add depth.
4. Export **vectors** (SVG/PDF). Convert text to outlines. Use PNG for any raster/mesh artifacts.

---

## 2) Compose & Export

### iOS / iPadOS / macOS / watchOS — Icon Composer
1. Import foreground layers (prefer vectors).  
2. Define **background** (solid or gradient).  
3. Adjust **placement & transparency**; preview system effects.  
4. Define **appearance variants** (default, dark, clear, tinted).  
5. **Export** to Xcode asset catalog.

### tvOS / visionOS — Image Stacks
1. In Xcode, create a **New Image Stack** in the asset catalog.  
2. Add 2–5 **ordered layers** (tvOS) or 2–3 layers (visionOS).  
3. Preview **focus/parallax** (tvOS) and **depth** (visionOS).

---

## 3) Add Assets to Xcode

- Primary icon: `AppIcon` (or platform‑specific names Xcode suggests).
- Alternates: `AppIcon‑Alt‑<Name>` (one set per alternate).

**Masking** is applied by the system; don’t pre‑mask layers.

---

## 4) Configure Info.plist (Alternates)

For iOS/iPadOS/visionOS (compatible apps), add **CFBundleAlternateIcons**:

```xml
<key>CFBundleIcons</key>
<dict>
  <key>CFBundlePrimaryIcon</key>
  <dict>
    <key>CFBundleIconFiles</key>
    <array><string>AppIcon</string></array>
  </dict>
  <key>CFBundleAlternateIcons</key>
  <dict>
    <key>Blue</key>
    <dict><key>CFBundleIconFiles</key><array><string>AppIcon-Alt-Blue</string></array></dict>
    <key>Retro</key>
    <dict><key>CFBundleIconFiles</key><array><string>AppIcon-Alt-Retro</string></array></dict>
  </dict>
</dict>
```

> Each alternate must include required appearance variants (light/dark/clear/tinted) where supported.

---

## 5) Wire Up the Picker (SwiftUI)

Use `AppIconManager` and `AppIconPickerView` from **AppIcons.swift**.

```swift
struct SettingsAppearanceView: View {
    @StateObject private var icons = AppIconManager()

    var body: some View {
        Form {
            Section("App Icon") {
                AppIconPickerView(manager: icons)
            }
        }
        .onAppear { icons.reloadFromBundle() }
    }
}
```

---

## 6) QA & Review

- Validate **contrast, simplicity,** and **recognizability** at small sizes.
- Test on **device**: Home Screen, Settings, notifications, Spotlight.
- For tvOS: confirm **safe zone** under focus; no cropping.
- For visionOS: no faux concave backgrounds; depth looks natural.
- Verify alternate icon switching, including relaunch and caching.

---

## Troubleshooting

- **Feathered edges** look muddy under system highlights → use crisp edges.  
- **Pre‑masked layers** cause jaggies → supply unmasked, full‑bleed layers.  
- **Busy icon** lost at small sizes → reduce shapes; simplify palette.  
- **Alternates not appearing** → check Info.plist keys and asset names.  
- **Switching fails** → confirm platform support and `supportsAlternateIcons == true`.
