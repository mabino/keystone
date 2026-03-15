import Foundation

struct SSHKey: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL
    let isPublic: Bool
    
    var displayName: String {
        name.replacingOccurrences(of: ".pub", with: "")
    }
}

enum DMGState {
    case missing
    case locked
    case unlocked
}

struct KeystoneStatus {
    var iCloudMounted: Bool = false
    var dmgDetected: Bool = false
    var keychainPassphraseStored: Bool = false
    var dmgState: DMGState = .missing
    var mountPointExists: Bool = false
}
