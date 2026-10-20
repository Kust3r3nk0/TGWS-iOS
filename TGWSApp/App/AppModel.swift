import Foundation
import SwiftUI
import TGWSCore

/// UI state only. No active MTProto transport has been implemented or tested.
@MainActor
final class AppModel: ObservableObject {
    @Published var port = "1443"
    @Published var secret = ""
    @Published var relayURL = ""
    @Published var fakeTLSDomain = ""
    @Published var mode: TransportMode = .direct
    @Published var feedback = ""

    let runtimeReady = false
    let sourceRevision = "Starter / engine pending"
    private let vault = KeychainStore()

    init() {
        let storedPort = UserDefaults.standard.integer(forKey: "tgws.port")
        if storedPort > 0 { port = String(storedPort) }
        mode = TransportMode(rawValue: UserDefaults.standard.string(forKey: "tgws.mode") ?? "") ?? .direct
        do {
            secret = try vault.read("secret") ?? ""
            relayURL = try vault.read("relayURL") ?? ""
            fakeTLSDomain = try vault.read("fakeTLSDomain") ?? ""
        } catch {
            feedback = "Не удалось прочитать защищённые настройки. Они не были сброшены."
        }
    }

    func saveConfiguration() {
        do {
            guard let numericPort = Int(port) else { throw ConfigurationError.invalidPort }
            if !relayURL.isEmpty && URL(string: relayURL) == nil {
                throw ConfigurationError.invalidRelayURL
            }
            _ = try ProxyConfiguration(
                port: numericPort,
                secretHex: secret,
                mode: mode,
                relayURL: relayURL.isEmpty ? nil : URL(string: relayURL),
                fakeTLSDomain: fakeTLSDomain
            )
            try vault.write(secret, name: "secret")
            try vault.write(relayURL, name: "relayURL")
            try vault.write(fakeTLSDomain, name: "fakeTLSDomain")
            UserDefaults.standard.set(numericPort, forKey: "tgws.port")
            UserDefaults.standard.set(mode.rawValue, forKey: "tgws.mode")
            feedback = "Параметры сохранены. Сетевое ядро в этом стартовом проекте ещё не реализовано."
        } catch {
            feedback = "Проверьте порт, 32 HEX-символа секрета, домен и WSS-реле."
        }
    }
}
