# 🔑 Keystone Native: Implementation Plan

This plan outlines the transition from the `keystone` Zsh script to a native macOS application built with **Swift** and **SwiftUI**. The goal is to provide a high-fidelity, biometric-first experience for managing private keys.

## 🏗 Architectural Overview

- **Language**: Swift 6
- **Framework**: SwiftUI (macOS 14+)
- **Security**: LocalAuthentication (Touch ID/Apple Watch), Security Framework (Keychain)
- **Disk Management**: `Process` wrapper for `hdiutil` (DiskImages framework)
- **Filesystem**: `FileManager` with `NSMetadataQuery` for iCloud synchronization tracking

---

## 🚀 Implementation Phases

### Phase 1: Foundation & Models
- [ ] **Data Models**: Define `SSHKey` and `KeystoneStatus` types.
- [ ] **Environment Configuration**: Robust detection of iCloud Drive and XDG paths.
- [ ] **Process Wrapper**: Create a `DiskManager` utility to wrap `hdiutil` commands (attach, detach, create) with async/await support.

### Phase 2: Security Layer
- [ ] **Biometric Service**: Implement `AuthenticationService` using `LAContext`.
- [ ] **Keychain Wrapper**: implement `KeychainService` to handle `kSecClassGenericPassword` entries for the DMG passphrase, ensuring parity with the script's `-s` service matching.

### Phase 3: Keystone Core Logic
- [ ] **Discovery Engine**: Implement the expanded globbing logic `(id_*|*_id_*)` using `FileManager`.
- [ ] **Pack/Restore Logic**: Native Swift implementation of additive restoration (checking for conflicts before writing).
- [ ] **Config Manager**: Logic to parse and update `~/.ssh/config_local`.

### Phase 4: Modern SwiftUI Interface
- [ ] **Visual Dashboard**: A "Status" view with live indicators for iCloud, Keychain, and DMG state.
- [ ] **Interactive Actions**:
    - Animated "Unlock" button triggered by biometric success.
    - List view for stored keys with "Copy Public Key" shortcuts.
    - Progress indicators for batch packing/restoring.
- [ ] **Safety UI**: A high-friction confirmation dialog for the "Wipe" action (mirroring the `WIPE` confirmation string).

### Phase 5: CLI Parity & Extras
- [ ] **CLI Shim**: Bundle a lightweight CLI version of the app within the `.app` package.
- [ ] **Installation Tool**: A "Install CLI to Path" feature within the App Settings.
- [ ] **Menu Bar Mode**: Option to run as a Menu Bar extra for quick access to key listing.

---

## 🎨 Design Goals (Rich Aesthetics)

- **Vibrant Status**: Use `SymbolVariants` and hierarchical colors (Green/Yellow/Red) for status checks.
- **Glassmorphism**: Utilize `VisualEffectView` for sidebar and background materials.
- **Modern Icon**: A high-quality "Tahoe" style squircle icon with a metallic key and iCloud gradient.
- **Feedback Loops**: Haptic feedback on biometric success and subtle animations during DMG mounting.

## 🛠 Script-to-Swift Mapping Reference

| Script Logic | Swift Equivalent |
| :--- | :--- |
| `zparseopts` | `ArgumentParser` (for CLI) or `Toggle` (for UI) |
| `security add-generic-password` | `SecItemAdd` / `SecItemUpdate` |
| `hdiutil attach -stdinpass` | `Process` with `Pipe` into `standardInput` |
| `id_*\|*_id_*` | `FileManager.contentsOfDirectory` + `NSPredicate` |
| `chmod 600` | `FileManager.setAttributes([.posixPermissions: 0o600])` |
| `print_header` | SwiftUI `VStack` with custom `HeaderView` |
