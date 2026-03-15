# 🔑 Keystone: Private Key Manager

Manage private SSH keys across macOS devices using an encrypted, iCloud-synced disk image (DMG).

## ✨ Features

- **iCloud Storage**: Uses an encrypted DMG stored in your iCloud Drive.
- **Biometric Security**: Integrated with **Touch ID** via macOS Local Authentication.
- **Keychain Integration**: Unlocks DMG using Apple Keychain.

## 🚀 Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/mabino/keystone/main/keystone | zsh -s -- --install
```

## 🛠 Usage

### Interactive Menu

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

## 🗑 Removal
```bash
keystone --remove
```
