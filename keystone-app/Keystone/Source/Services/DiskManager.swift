import Foundation
import Observation

@MainActor
@Observable
class DiskManager {
    let iCloudPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
    let dmgName = "keystone.dmg"
    let mountPoint = URL(fileURLWithPath: "/Volumes/Keystone")
    
    var dmgPath: URL {
        iCloudPath.appendingPathComponent(dmgName)
    }
    
    func checkStatus() -> KeystoneStatus {
        var status = KeystoneStatus()
        status.iCloudMounted = FileManager.default.fileExists(atPath: iCloudPath.path)
        status.dmgDetected = FileManager.default.fileExists(atPath: dmgPath.path)
        status.keychainPassphraseStored = KeychainService.shared.isStored()
        status.mountPointExists = FileManager.default.fileExists(atPath: mountPoint.path)
        
        if !status.dmgDetected {
            status.dmgState = .missing
        } else if status.mountPointExists {
            status.dmgState = .unlocked
        } else {
            status.dmgState = .locked
        }
        
        return status
    }
    
    func mount(passphrase: String? = nil) async throws {
        let actualPass = passphrase ?? KeychainService.shared.getPassphrase()
        guard let pass = actualPass else {
            throw NSError(domain: "DiskManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No passphrase provided"])
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        process.arguments = ["attach", dmgPath.path, "-mountpoint", mountPoint.path, "-stdinpass"]
        
        let pipe = Pipe()
        process.standardInput = pipe
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        
        try process.run()
        
        if let data = (pass + "\0").data(using: .utf8) {
            pipe.fileHandleForWriting.write(data)
            try pipe.fileHandleForWriting.close()
        }
        
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw NSError(domain: "DiskManager", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Failed to mount DMG"])
        }
    }
    
    func unmount() async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        process.arguments = ["detach", mountPoint.path, "-quiet"]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        
        try process.run()
        process.waitUntilExit()
    }
    
    func create(passphrase: String) async throws {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("keystone_tmp")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        process.arguments = [
            "create", "-size", "10m", "-fs", "HFS+", "-volname", "Keystone",
            "-encryption", "AES-256", "-srcfolder", tempDir.path,
            "-format", "UDRW", dmgPath.path, "-stdinpass"
        ]
        
        let pipe = Pipe()
        process.standardInput = pipe
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        
        try process.run()
        
        if let data = (passphrase + "\0").data(using: .utf8) {
            pipe.fileHandleForWriting.write(data)
            try pipe.fileHandleForWriting.close()
        }
        
        process.waitUntilExit()
        try? FileManager.default.removeItem(at: tempDir)
        
        if process.terminationStatus != 0 {
            throw NSError(domain: "DiskManager", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Failed to create DMG"])
        }
    }
}
