// swift-tools-version:5.9
import PackageDescription

// ===========================================================================
// Swift Language Test Suite — Editor Feature Testing
// Exercises: syntax highlighting, bracket matching, code folding,
//            indentation, auto-completion, diagnostics, go-to-definition,
//            find-references, renaming, formatting (swift-format), and more.
// ===========================================================================

let package = Package(
    name: "LanguageTests",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "LanguageTests", targets: ["LanguageTests"])
    ],
    targets: [
        .target(
            name: "LanguageTests",
            path: "Sources/LanguageTests"
        ),
        .testTarget(
            name: "LanguageTestsTests",
            dependencies: ["LanguageTests"],
            path: "Tests/LanguageTestsTests"
        )
    ]
)
