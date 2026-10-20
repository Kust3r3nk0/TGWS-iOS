import Foundation
import Security

struct KeychainStore {
    private let service = "io.github.kust3r3nk0.tgwsios"

    func read(_ name: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: name,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let value = item as? Data,
              let text = String(data: value, encoding: .utf8) else {
            throw KeychainFailure.readFailed(status)
        }
        return text
    }

    func write(_ text: String, name: String) throws {
        let lookup: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: name
        ]
        let data = Data(text.utf8)
        let updateStatus = SecItemUpdate(lookup as CFDictionary,
                                         [kSecValueData as String: data] as CFDictionary)
        if updateStatus == errSecSuccess { return }
        guard updateStatus == errSecItemNotFound else { throw KeychainFailure.writeFailed(updateStatus) }
        var insert = lookup
        insert[kSecValueData as String] = data
        insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let insertStatus = SecItemAdd(insert as CFDictionary, nil)
        guard insertStatus == errSecSuccess else { throw KeychainFailure.writeFailed(insertStatus) }
    }
}

enum KeychainFailure: Error {
    case readFailed(OSStatus)
    case writeFailed(OSStatus)
}
