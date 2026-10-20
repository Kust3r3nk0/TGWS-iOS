import Foundation
/// Generating a local Telegram link does not mean the proxy is running.
public enum TelegramProxyLink {
    public static func localLink(config: ProxyConfiguration) -> URL? {
        let prefix = config.fakeTLSDomain.isEmpty ? "dd" : "ee"
        let domainHex = config.fakeTLSDomain.utf8.map { String(format: "%02x", $0) }.joined()
        let secret = prefix + config.secretHex + (config.fakeTLSDomain.isEmpty ? "" : domainHex)
        return URL(string: "tg://proxy?server=127.0.0.1&port=\(config.port)&secret=\(secret)")
    }
}
