import Foundation

public enum TransportMode: String, CaseIterable, Codable, Sendable, Identifiable {
    case direct = "DIRECT"
    case relayOnly = "RELAY_ONLY"
    case autoCloudflare = "AUTO_CLOUDFLARE"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .direct: "Прямой"
        case .relayOnly: "Только реле"
        case .autoCloudflare: "Автоматический Cloudflare"
        }
    }
}

public enum ConfigurationError: Error, Equatable, Sendable {
    case invalidPort
    case invalidSecret
    case invalidFakeTLSDomain
    case missingRelay
    case invalidRelayURL
}

/// In-memory validated configuration. Never persist secrets in UserDefaults.
public struct ProxyConfiguration: Sendable, Equatable {
    public let port: Int
    public let secretHex: String
    public let mode: TransportMode
    public let relayURL: URL?
    public let fakeTLSDomain: String

    public init(
        port: Int = 1443,
        secretHex: String,
        mode: TransportMode = .direct,
        relayURL: URL? = nil,
        fakeTLSDomain: String = ""
    ) throws {
        guard (1...65535).contains(port) else { throw ConfigurationError.invalidPort }
        guard secretHex.count == 32,
              secretHex.utf8.allSatisfy({ ($0 >= 48 && $0 <= 57) || ($0 >= 65 && $0 <= 70) || ($0 >= 97 && $0 <= 102) }) else {
            throw ConfigurationError.invalidSecret
        }
        guard Self.validDomain(fakeTLSDomain) else { throw ConfigurationError.invalidFakeTLSDomain }
        if mode == .relayOnly && relayURL == nil { throw ConfigurationError.missingRelay }
        if let relayURL {
            guard relayURL.scheme == "wss",
                  relayURL.host != nil,
                  relayURL.user == nil,
                  relayURL.password == nil,
                  relayURL.fragment == nil else { throw ConfigurationError.invalidRelayURL }
        }
        self.port = port
        self.secretHex = secretHex.lowercased()
        self.mode = mode
        self.relayURL = relayURL
        self.fakeTLSDomain = fakeTLSDomain.lowercased()
    }

    /// Conservative ASCII FQDN check.
    public static func validDomain(_ domain: String) -> Bool {
        if domain.isEmpty { return true }
        guard domain.utf8.count <= 253, !domain.hasSuffix("."), !domain.hasPrefix(".") else { return false }
        let labels = domain.split(separator: ".", omittingEmptySubsequences: false)
        return labels.count >= 2 && labels.allSatisfy { label in
            guard !label.isEmpty, label.utf8.count <= 63, label.first != "-", label.last != "-" else { return false }
            return label.utf8.allSatisfy { c in
                (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || (c >= 48 && c <= 57) || c == 45
            }
        }
    }
}
