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
            url: "https://github.com/swift-molecules/swift-copy-on-write.git",
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
            url: "https://github.com/swift-atoms/swift-property.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ownership.git",
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
            url: "https://github.com/swift-molecules/swift-buffer-linear.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-byte.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-atoms/swift-buffer.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-buffer-ring.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-memory.git", branch: "main", traits: ["Cursor", "Lock", "Map", "Shared"]),
        .package(url: "https://github.com/swift-molecules/swift-memory-allocation.git", branch: "main", traits: ["MemoryAllocatorArena", "MemoryInline", "MemorySmall"]),
        .package(url: "https://github.com/swift-atoms/swift-storage.git", branch: "main", traits: ["Generational", "Memory"]),
        .package(url: "https://github.com/swift-atoms/swift-store.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main", traits: ["Coder", "Parser", "Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-coder.git", branch: "main", traits: ["Carrier", "Map"]),
        .package(url: "https://github.com/swift-atoms/swift-ratio.git", branch: "main", traits: ["Bit", "Difference", "Ordinal"]),
        .package(url: "https://github.com/swift-atoms/swift-span.git", branch: "main", traits: ["Byte", "Iterator"]),
        .package(url: "https://github.com/swift-atoms/swift-finite.git", branch: "main", traits: ["Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-affine.git", branch: "main", traits: ["Tagged", "Vector"]),
        .package(url: "https://github.com/swift-atoms/swift-binary.git", branch: "main", traits: ["Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-collection.git", branch: "main", traits: ["Repetition", "Search"]),
        .package(url: "https://github.com/swift-atoms/swift-coordinate.git", branch: "main", traits: ["Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-cyclic.git", branch: "main", traits: ["Index", "Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-difference.git", branch: "main", traits: ["Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-displacement.git", branch: "main", traits: ["Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-formatter.git", branch: "main", traits: ["Conversions", "Number", "Radix", "Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-geometry.git", branch: "main", traits: ["Affine"]),
        .package(url: "https://github.com/swift-atoms/swift-iterator.git", branch: "main", traits: ["Repetition", "Search"]),
        .package(url: "https://github.com/swift-atoms/swift-parser.git", branch: "main", traits: ["Always", "Append", "Choice", "Either", "Iterator", "IteratorLeaves", "Map", "Optic", "Pair", "Predicate", "Product", "Repetition", "Skip"]),
        .package(url: "https://github.com/swift-atoms/swift-point.git", branch: "main", traits: ["Affine", "Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-predicate.git", branch: "main", traits: ["Always"]),
        .package(url: "https://github.com/swift-atoms/swift-renderer.git", branch: "main", traits: ["Document"]),
        .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main", traits: ["Always", "Byte", "Either", "Map", "Optic", "Pair", "Repetition"]),
        .package(url: "https://github.com/swift-atoms/swift-text.git", branch: "main", traits: ["Byte", "Casing"]),
        .package(url: "https://github.com/swift-atoms/swift-time.git", branch: "main", traits: ["Affine"]),
        .package(url: "https://github.com/swift-atoms/swift-translation.git", branch: "main", traits: ["Affine"]),
        .package(url: "https://github.com/swift-atoms/swift-direction.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "PDF HTML Rendering",
            dependencies: [
                .product(name: "HTML Rendering Core", package: "swift-html-render"),
                .product(name: "PDF Rendering", package: "swift-pdf-render"),
                .product(name: "Copy on Write Macro", package: "swift-copy-on-write"),
                .product(name: "CSS", package: "swift-css"),
                .product(name: "HTML Standard", package: "swift-html-standard"),
                .product(name: "RFC 4648", package: "swift-rfc-4648"),
                .product(name: "Layout", package: "swift-layout"),
                .product(name: "Direction", package: "swift-direction"),
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
                .product(name: "Buffer Linear Primitive", package: "swift-buffer-linear"),
                .product(name: "Buffer", package: "swift-buffer"),
                .product(name: "Buffer Linear Bounded Primitive", package: "swift-buffer-linear"),
                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring"),
                .product(name: "Memory Allocator Pool", package: "swift-memory-allocation"),
                .product(name: "Memory Pool", package: "swift-memory-allocation"),
                .product(name: "Memory Allocator", package: "swift-memory-allocation"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Storage", package: "swift-storage"),
                .product(name: "Store", package: "swift-store"),
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
                .product(name: "Binary", package: "swift-binary"),
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
