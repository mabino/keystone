# 🔑 Keystone: Private Key Manager

A colorful, interactive, and secure way to manage your private SSH keys across macOS devices using an encrypted iCloud-synced DMG.

## ✨ Features
- **iCloud Sync**: Uses an encrypted DMG (`keystone.dmg`) stored in your iCloud Drive.
- **Biometric Security**: Integrated with **Touch ID** via macOS Local Authentication.
- **Keychain Integration**: Seamlessly unlocks your DMG using your Apple Keychain.
- **CLI & Interactive**: Supports both a beautiful menu and direct command-line arguments.
- **XDG Compliant**: Installs to `~/.local/bin`.

## 🚀 Quick Install

Install directly to your user binary directory:

```bash
curl -fsSL https://raw.githubusercontent.com/mabino/keystone/main/keystone | zsh -s -- --install
```

## 🛠 Usage

### Interactive Menu
Simply run:
```bash
keystone
```

### CLI Arguments
| Option | Description |
| :--- | :--- |
| `-h`, `--help` | Show help message |
| `--install` | Install/Update keystone to `~/.local/bin` |
| `--remove` | Uninstall keystone |
| `--list` | List stored keys and exit |
| `--pack` | Pack local keys to iCloud and exit |
| `--restore` | Restore keys to this device and exit |
| `--wipe` | Wipe stored keys (Dangerous!) |

## 🏗 Development
This project uses **ShellCheck** via GitHub Actions to ensure script quality.

## 🗑 Removal
```bash
keystone --remove
```
