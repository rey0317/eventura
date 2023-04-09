import Foundation

class KeychainWrapper {
    func save(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            if let data = dataTypeRef as? Data, let value = String(data: data, encoding: .utf8) {
                return value
            }
        }
        return nil
    }
    
    func saveKeys(walletAddress: String, publicKey: String, privateKey: String) {
        save(walletAddress, forKey: "walletAddress")
        save(publicKey, forKey: "publicKey")
        save(privateKey, forKey: "privateKey")
    }
    
    func getKeys() -> (walletAddress: String?, publicKey: String?, privateKey: String?) {
        let walletAddress = get("walletAddress")
        let publicKey = get("publicKey")
        let privateKey = get("privateKey")
        
        return (walletAddress, publicKey, privateKey)
    }
}

