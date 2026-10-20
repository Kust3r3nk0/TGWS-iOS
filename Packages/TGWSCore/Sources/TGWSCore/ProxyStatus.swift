import Foundation

public enum ProxyPhase: String, Sendable {
    case unimplemented, stopped, starting, listening, active, stopping, error
}
public enum DiagnosticCategory: String, Sendable {
    case lifecycle, network, transport, telegram
}
/// Never include keys, endpoint paths, IP addresses, or Telegram payloads.
public struct DiagnosticEvent: Sendable, Equatable {
    public let category: DiagnosticCategory
    public let code: String
    public init(category: DiagnosticCategory, code: String) {
        self.category = category
        self.code = code
    }
}
/// No fake engine is provided by the starter.
public protocol ProxyRuntime: Sendable {
    func start(_ configuration: ProxyConfiguration) async throws
    func stop() async
}
