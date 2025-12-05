# HIG Package

This repository contains the DocuChat Human Interface Guidelines (HIG) prototype along with a lightweight Swift package for working with the bundled guideline content.

## Swift package

The package target, `HIGPackage`, exposes strongly typed models for the `hig_combined.json` dataset and a loader that decodes the file with sensible defaults (ISO8601 dates, URLs, and topic grouping by category). The package is organized in a standard Swift Package Manager layout:

```
Package.swift
Sources/
  HIGPackage/
    HIGDataLoader.swift
    Models/
      HIGDocument.swift
Tests/
  HIGPackageTests/
    Fixtures/
      sample_hig.json
    HIGDataLoaderTests.swift
```

### Usage

Add the package to your `Package.swift` dependencies:

```swift
.package(path: "../HIG")
```

Then import and load the guideline document:

```swift
import HIGPackage

let url = Bundle.module.url(forResource: "hig_combined", withExtension: "json")!
let document = try HIGDataLoader.load(from: url)
let foundations = HIGDataLoader.topics(for: "Foundations", in: document)
```

### Command-line executable

The repository also ships with a small executable, `hig-cli`, that loads the bundled data and surfaces simple commands for
listing categories or searching topics. Build and run it with the Swift Package Manager:

```bash
swift run hig-cli --help
```

### Running tests

From the repository root, run the package tests:

```bash
swift test
```

The tests exercise decoding, category filtering, and simple search over the guideline topics using a bundled fixture.
