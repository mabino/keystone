import Foundation
import Observation

@MainActor
class KeyService {
    let sshDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".ssh")
    
    func discoverLocalKeys() -> [SSHKey] {
        let files = try? FileManager.default.contentsOfDirectory(at: sshDir, includingPropertiesForKeys: nil)
        return (files ?? []).compactMap { url in
            let name = url.lastPathComponent
            // Pattern: id_* or *_id_*
            if name.hasPrefix("id_") || name.contains("_id_") {
                return SSHKey(name: name, url: url, isPublic: name.hasSuffix(".pub"))
            }
            return nil
        }
    }
    
    func discoverStoredKeys(mountPoint: URL) -> [SSHKey] {
        let files = try? FileManager.default.contentsOfDirectory(at: mountPoint, includingPropertiesForKeys: nil)
        return (files ?? []).compactMap { url in
            let name = url.lastPathComponent
            if name.hasPrefix("id_") || name.contains("_id_") {
                return SSHKey(name: name, url: url, isPublic: name.hasSuffix(".pub"))
            }
            return nil
        }
    }
    
    func pack(keys: [SSHKey], to mountPoint: URL) throws -> (packed: Int, skipped: Int) {
        var packed = 0
        var skipped = 0
        
        for key in keys {
            let target = mountPoint.appendingPathComponent(key.name)
            if FileManager.default.fileExists(atPath: target.path) {
                skipped += 1
            } else {
                try FileManager.default.copyItem(at: key.url, to: target)
                packed += 1
            }
        }
        return (packed, skipped)
    }
    
    func restore(keys: [SSHKey], from mountPoint: URL) throws -> (restored: Int, skipped: Int) {
        var restored = 0
        var skipped = 0
        
        for key in keys {
            let target = sshDir.appendingPathComponent(key.name)
            if FileManager.default.fileExists(atPath: target.path) {
                skipped += 1
            } else {
                try FileManager.default.copyItem(at: key.url, to: target)
                // Set permissions
                let attributes: [FileAttributeKey: Any] = [
                    .posixPermissions: key.isPublic ? 0o644 : 0o600
                ]
                try FileManager.default.setAttributes(attributes, ofItemAtPath: target.path)
                restored += 1
            }
        }
        
        try updateConfigLocal()
        return (restored, skipped)
    }
    
    private func updateConfigLocal() throws {
        let configLocalUrl = sshDir.appendingPathComponent("config_local")
        var content = "Host *\n"
        
        let localKeys = discoverLocalKeys()
        for key in localKeys where !key.isPublic {
            content += "  IdentityFile ~/.ssh/\(key.name)\n"
        }
        
        try content.write(to: configLocalUrl, atomically: true, encoding: .utf8)
    }
    
    func wipe(mountPoint: URL) throws {
        let files = try? FileManager.default.contentsOfDirectory(at: mountPoint, includingPropertiesForKeys: nil)
        for url in files ?? [] {
            try FileManager.default.removeItem(at: url)
        }
    }
}
