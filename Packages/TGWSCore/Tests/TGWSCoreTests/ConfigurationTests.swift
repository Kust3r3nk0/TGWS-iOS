import XCTest
@testable import TGWSCore

final class ConfigurationTests: XCTestCase {
    private let secret = "00112233445566778899aabbccddeeff"

    func testLocalLinkPaddedMode() throws {
        let config = try ProxyConfiguration(port: 1443, secretHex: secret)
        XCTAssertEqual(TelegramProxyLink.localLink(config: config)?.absoluteString,
                       "tg://proxy?server=127.0.0.1&port=1443&secret=dd\(secret)")
    }

    func testLocalLinkFakeTLS() throws {
        let config = try ProxyConfiguration(secretHex: secret, fakeTLSDomain: "example.com")
        XCTAssertEqual(TelegramProxyLink.localLink(config: config)?.absoluteString,
                       "tg://proxy?server=127.0.0.1&port=1443&secret=ee\(secret)6578616d706c652e636f6d")
    }

    func testInvalidPortRejected() {
        XCTAssertThrowsError(try ProxyConfiguration(port: 0, secretHex: secret))
        XCTAssertThrowsError(try ProxyConfiguration(port: 65536, secretHex: secret))
    }

    func testInvalidSecretRejected() {
        XCTAssertThrowsError(try ProxyConfiguration(secretHex: "not-a-secret"))
    }

    func testRelayOnlyNeedsRelay() {
        XCTAssertThrowsError(try ProxyConfiguration(secretHex: secret, mode: .relayOnly))
        XCTAssertNoThrow(try ProxyConfiguration(secretHex: secret, mode: .relayOnly,
                                                 relayURL: URL(string: "wss://relay.example.com/key/apiws")))
    }

    func testRelayOnlyRejectsCleartextAndCredentials() {
        XCTAssertThrowsError(try ProxyConfiguration(secretHex: secret, mode: .relayOnly,
                                                     relayURL: URL(string: "ws://relay.example.com/apiws")))
        XCTAssertThrowsError(try ProxyConfiguration(secretHex: secret, mode: .relayOnly,
                                                     relayURL: URL(string: "wss://user:pass@relay.example.com/apiws")))
    }

    func testDomainValidation() {
        XCTAssertTrue(ProxyConfiguration.validDomain("example.com"))
        XCTAssertFalse(ProxyConfiguration.validDomain("-invalid.example"))
        XCTAssertFalse(ProxyConfiguration.validDomain("example..com"))
        XCTAssertFalse(ProxyConfiguration.validDomain("пример.рф"))
    }
}
