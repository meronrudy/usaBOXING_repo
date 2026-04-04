// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PeakmodoroShared",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "PeakmodoroShared",
            targets: ["PeakmodoroShared"]
        ),
        .executable(
            name: "PeakmodoroValidation",
            targets: ["PeakmodoroValidation"]
        )
    ],
    targets: [
        .target(
            name: "PeakmodoroShared",
            path: "Sources/PeakmodoroShared"
        ),
        .executableTarget(
            name: "PeakmodoroValidation",
            dependencies: ["PeakmodoroShared"],
            path: "Validation"
        )
    ]
)
