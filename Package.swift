// swift-tools-version: 6.4

import PackageDescription

extension String {
    static let pdfHTMLRendering: Self = "PDF HTML Rendering"
    var tests: Self { self + " Tests" }
}

extension Target.Dependency {
    static var pdfHTMLRendering: Self { .target(name: .pdfHTMLRendering) }
}

extension Target.Dependency {
    static var htmlRenderingCore: Self {
        .product(name: "HTML Rendering Core", package: "swift-html-render")
    }
    static var htmlRendering: Self {
        .product(name: "HTML Rendering", package: "swift-html-render")
    }
    static var htmlRenderingCoreTestSupport: Self {
        .product(name: "HTML Rendering Core Test Support", package: "swift-html-render")
    }
    static var pdfRenderingTestSupport: Self {
        .product(name: "PDF Rendering Test Support", package: "swift-pdf-render")
    }
    static var pdfRendering: Self {
        .product(name: "PDF Rendering", package: "swift-pdf-render")
    }
    static var copyOnWrite: Self {
        .product(name: "Copy on Write", package: "swift-copy-on-write")
    }
    static var css: Self {
        .product(name: "CSS", package: "swift-css")
    }
    static var htmlStandard: Self {
        .product(name: "HTML Standard", package: "swift-html-standard")
    }
    static var rfc4648: Self {
        .product(name: "RFC 4648", package: "swift-rfc-4648")
    }
    static var layoutPrimitives: Self {
        .product(name: "Layout", package: "swift-layout")
    }
    static var dictionaryPrimitives: Self {
        .product(name: "Dictionary", package: "swift-dictionary")
    }
    static var stackPrimitives: Self {
        .product(name: "Stack", package: "swift-stack")
    }
    static var propertyPrimitives: Self {
        .product(name: "Property", package: "swift-property")
    }
    static var standardLibraryExtensions: Self {
        .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    }
    static var ownershipMutablePrimitives: Self {
        .product(name: "Ownership Mutable", package: "swift-ownership")
    }
    static var sharedPrimitive: Self {
        .product(name: "Ownership Shared Primitive", package: "swift-ownership-shared")
    }
    static var hashIndexedPrimitive: Self {
        .product(name: "Hash Indexed Primitive", package: "swift-hash-table")
    }
    static var hashPrimitives: Self {
        .product(name: "Hash", package: "swift-hash")
    }
    static var columnPrimitives: Self {
        .product(name: "Column", package: "swift-column")
    }
    static var bufferLinearPrimitive: Self {
        .product(name: "Buffer Linear Primitive", package: "swift-buffer-linear")
    }
    static var dictionaryOrderedPrimitive: Self {
        .product(
            name: "Dictionary Ordered Primitive",
            package: "swift-dictionary-ordered"
        )
    }
    static var bytePrimitives: Self {
        .product(name: "Byte", package: "swift-byte")
    }
}

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
        .library(name: .pdfHTMLRendering, targets: [.pdfHTMLRendering]),
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
            url: "https://github.com/swift-molecules/swift-standard-library-extensions.git",
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
            url: "https://github.com/swift-molecules/swift-hash.git",
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
            name: .pdfHTMLRendering,
            dependencies: [
                .htmlRenderingCore,
                .pdfRendering,
                .copyOnWrite,
                .css,
                .htmlStandard,
                .rfc4648,
                .layoutPrimitives,
                .dictionaryPrimitives,
                .product(
                    name: "Dictionary Ordered",
                    package: "swift-dictionary-ordered"
                ),
                .dictionaryOrderedPrimitive,
                .bytePrimitives,
                .stackPrimitives,
                .propertyPrimitives,
                .standardLibraryExtensions,
                .ownershipMutablePrimitives,
                .sharedPrimitive,
                .hashIndexedPrimitive,
                .hashPrimitives,
                .columnPrimitives,
                .bufferLinearPrimitive,
            ]
        ),
        .target(
            name: "PDF HTML Rendering Test Support",
            dependencies: [
                .pdfHTMLRendering,
                .htmlRenderingCoreTestSupport,
                .pdfRenderingTestSupport,
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: .pdfHTMLRendering.tests,
            dependencies: [
                .pdfHTMLRendering,
                .htmlRendering,
                "PDF HTML Rendering Test Support",
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
