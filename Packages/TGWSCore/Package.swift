// swift-tools-version: 6.0
import PackageDescription

let package = Package(name: "TGWSCore", platforms: [.iOS(.v17)], products: [.library(name: "TGWSCore", targets: ["TGWSCore"])], targets: [.target(name: "TGWSCore"), .testTarget(name: "TGWSCoreTests", dependencies: ["TGWSCore"])])
