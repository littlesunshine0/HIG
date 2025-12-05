# App Icons — Index (v1.0)

This index catalogs the types, assets, and developer entry points that support app icon design, export, and runtime selection.

---

## Files

- **AppIcons.swift** — Cross‑platform helpers for alternate icons (where supported), SwiftUI picker, and plist interrogation.
- **AppIconsArticle.md** — Design & implementation overview (this topic’s companion article).
- **HowTo‑AppIcons.md** — Step‑by‑step workflow (design → Icon Composer / image stack → asset catalog → Info.plist → code).
- **Asset Catalog** (Xcode) — `AppIcon` and optional alternates; tvOS/visionOS image stacks.

---

## Types (AppIcons.swift)

### `enum AppIconVariant: String, CaseIterable, Identifiable`
- **Cases**: `.primary` + custom cases for each alternate (name must match Info.plist / asset names).
- **Properties**: `id`, `displayName`, `assetName`.

### `final class AppIconManager: ObservableObject`
- **Published**:
  - `current: AppIconVariant` — current app icon selection (where supported; `.primary` otherwise).
  - `available: [AppIconVariant]` — resolved from Info.plist (`CFBundleAlternateIcons`).
- **Functions**:
  - `supportsAlternateIcons() -> Bool`
  - `apply(_ variant: AppIconVariant, completion: @escaping (Result<Void, Error>) -> Void)`
  - `reloadFromBundle()` — refresh available variants.
  - `alternateIconNamesInBundle() -> [String]` — reads `CFBundleAlternateIcons` keys.
- **Notes**: Uses `UIApplication` where available (iOS/visionOS). Gracefully no‑ops on unsupported platforms.

### `struct AppIconPickerView: View`
- SwiftUI list/grid to preview and select from `AppIconManager.available`.

---

## Asset & Plist Surfaces

### Asset Catalog
- `AppIcon` (primary).  
- `AppIcon‑Alt‑<Name>` (per alternate).  
- **tvOS/visionOS**: image stacks with layered foregrounds.

### Info.plist (iOS/iPadOS/visionOS)
```
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
> Each alternate must include its own appearance variants where applicable.

---

## Testing

- Verify masking and highlights on device in all appearances (default/dark/clear/tinted) where supported.
- On tvOS: check safe zone with focus/parallax.
- On visionOS: confirm depth & embossed alpha behavior.
- Exercise alternate icon switching; ensure persistent selection and no stale caches (relaunch).
