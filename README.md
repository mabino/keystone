# 🔑 Keystone: Private Key Manager

A colorful, interactive, and secure way to manage your private SSH keys across macOS devices using an encrypted iCloud-synced DMG.

## ✨ Features
- **iCloud Sync**: Uses an encrypted DMG (`keystone.dmg`) stored in your iCloud Drive.
- **Biometric Security**: Integrated with **Touch ID** via macOS Local Authentication.
- **Keychain Integration**: Seamlessly unlocks your DMG using your Apple Keychain.
- **XDG Compliant**: Follows modern standards for binary and configuration locations.

## 🚀 Installation (XDG Standard)

Install or update Keystone to your local user binary directory:

```bash
mkdir -p "${XDG_BIN_HOME:-$HOME/.local/bin}" && \
curl -fsSL https://raw.githubusercontent.com/mabino/keystone/main/keystone -o "${XDG_BIN_HOME:-$HOME/.local/bin}/keystone" && \
chmod +x "${XDG_BIN_HOME:-$HOME/.local/bin}/keystone"
```

*Note: Ensure `~/.local/bin` is in your `$PATH`.*

## 🛠 Usage
Simply run:
```bash
keystone
```

## 🗑 Removal
```bash
rm "${XDG_BIN_HOME:-$HOME/.local/bin}/keystone"
```
