// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-pdf-html-render",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "PDF HTML Rendering", targets: ["PDF HTML Rendering"]),
        .library(
            name: "PDF HTML Rendering Test Support",
            targets: ["PDF HTML Rendering Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-compositions/swift-html-render.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-pdf-render.git", branch: "main"),
        .package(
            url: "https://github.com/swift-compositions/swift-copy-on-write.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-compositions/swift-css.git", branch: "main"),
        .package(url: "https://github.com/swift-standards/swift-html-standard.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-4648.git", branch: "main"),
        .package(
            url: "https://github.com/swift-molecules/swift-layout.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dictionary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dictionary-ordered.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-stack.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-property.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ownership.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ownership-shared.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-hash-table.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-column.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-linear.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-byte.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "PDF HTML Rendering",
            dependencies: [
                .product(name: "HTML Rendering Core", package: "swift-html-render"),
                .product(name: "PDF Rendering", package: "swift-pdf-render"),
                .product(name: "Copy on Write", package: "swift-copy-on-write"),
                .product(name: "CSS", package: "swift-css"),
                .product(name: "HTML Standard", package: "swift-html-standard"),
                .product(name: "RFC 4648", package: "swift-rfc-4648"),
                .product(name: "Layout", package: "swift-layout"),
                .product(name: "Dictionary", package: "swift-dictionary"),
                .product(
                    name: "Dictionary Ordered",
                    package: "swift-dictionary-ordered"
                ),
                .product(name: "Dictionary Ordered Primitive", package: "swift-dictionary-ordered"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Stack", package: "swift-stack"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "Ownership", package: "swift-ownership"),
                .product(name: "Ownership Shared Primitive", package: "swift-ownership-shared"),
                .product(name: "Hash Indexed Primitive", package: "swift-hash-table"),
                .product(name: "Column", package: "swift-column"),
                .product(name: "Buffer Linear Primitive", package: "swift-buffer-linear"),
            ]
        ),
        .target(
            name: "PDF HTML Rendering Test Support",
            dependencies: [
                .target(name: "PDF HTML Rendering"),
                .product(name: "HTML Rendering Core Test Support", package: "swift-html-render"),
                .product(name: "PDF Rendering Test Support", package: "swift-pdf-render"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "PDF HTML Rendering Tests",
            dependencies: [
                .target(name: "PDF HTML Rendering"),
                .product(name: "HTML Rendering", package: "swift-html-render"),
                .target(name: "PDF HTML Rendering Test Support"),
            ],
            path: "Tests/PDF HTML Rendering Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
