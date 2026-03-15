import SwiftUI

struct ContentView: View {
    @State private var diskManager = DiskManager()
    @State private var authService = AuthenticationService()
    @State private var keyService = KeyService()
    
    @State private var status = KeystoneStatus()
    @State private var storedKeys: [SSHKey] = []
    @State private var showingPassphrasePrompt = false
    @State private var passphrase = ""
    @State private var currentError: String?
    @State private var lastMessage: String?
    @State private var showingWipeConfirmation = false
    @State private var wipeConfirmationInput = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Status Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Status")
                        .font(.headline)
                    
                    StatusRow(title: "iCloud Drive", isActive: status.iCloudMounted)
                    StatusRow(title: "Encrypted DMG", isActive: status.dmgDetected, info: status.dmgDetected ? "Detected" : "Missing")
                    StatusRow(title: "Apple Keychain", isActive: status.keychainPassphraseStored, info: status.keychainPassphraseStored ? "Stored" : "Not Stored")
                    StatusRow(title: "DMG State", isActive: status.dmgState == .unlocked, info: status.dmgState == .unlocked ? "Unlocked" : "Locked")
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                if let message = lastMessage {
                    Text(message)
                        .foregroundColor(.green)
                        .font(.callout)
                }
                
                if let error = currentError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.callout)
                }
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: { Task { await unlockAndList() } }) {
                        Label("List Stored Keys", systemImage: "list.bullet")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: { Task { await packLocalKeys() } }) {
                        Label("Pack Local Keys to iCloud", systemImage: "archivebox")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { Task { await restoreKeys() } }) {
                        Label("Restore Keys to Device", systemImage: "arrow.down.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showingWipeConfirmation = true }) {
                        Label("Wipe Stored Keys", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                if !storedKeys.isEmpty {
                    List(storedKeys) { key in
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.cyan)
                            Text(key.displayName)
                            Spacer()
                            if key.isPublic {
                                Text("Public").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("🔑 Keystone")
            .toolbar {
                Button("Refresh") { refreshStatus() }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
        .onAppear { refreshStatus() }
        .sheet(isPresented: $showingPassphrasePrompt) {
            PassphrasePrompt(passphrase: $passphrase, onCommit: {
                showingPassphrasePrompt = false
                Task { await performInitialMount() }
            }, onCancel: { showingPassphrasePrompt = false })
        }
        .alert("⚠️ DANGER: WIPE STORE", isPresented: $showingWipeConfirmation) {
            TextField("Type WIPE to confirm", text: $wipeConfirmationInput)
            Button("Cancel", role: .cancel) { wipeConfirmationInput = "" }
            Button("WIPE", role: .destructive) { Task { await performWipe() } }
                .disabled(wipeConfirmationInput != "WIPE")
        } message: {
            Text("This will permanently delete ALL keys stored in your encrypted DMG. This action is irreversible.")
        }
    }
    
    func refreshStatus() {
        status = diskManager.checkStatus()
        if status.dmgState == .unlocked {
            storedKeys = keyService.discoverStoredKeys(mountPoint: diskManager.mountPoint)
        } else {
            storedKeys = []
        }
    }
    
    func unlockAndList() async {
        currentError = nil
        if status.dmgState == .unlocked {
            refreshStatus()
            return
        }
        
        if status.dmgState == .missing {
            showingPassphrasePrompt = true // To create
            return
        }
        
        guard await authService.authenticate() else { return }
        
        if status.keychainPassphraseStored {
            do {
                try await diskManager.mount()
                refreshStatus()
                lastMessage = "Keystone unlocked!"
            } catch {
                currentError = "Failed to unlock: \(error.localizedDescription)"
            }
        } else {
            showingPassphrasePrompt = true
        }
    }
    
    func performInitialMount() async {
        guard await authService.authenticate() else { return }
        
        do {
            if status.dmgState == .missing {
                try await diskManager.create(passphrase: passphrase)
                lastMessage = "DMG Created!"
            }
            
            try await diskManager.mount(passphrase: passphrase)
            _ = KeychainService.shared.savePassphrase(passphrase)
            refreshStatus()
            lastMessage = "Keystone unlocked and passphrase saved!"
        } catch {
            currentError = "Error: \(error.localizedDescription)"
        }
        passphrase = ""
    }
    
    func packLocalKeys() async {
        await unlockAndList()
        guard status.dmgState == .unlocked else { return }
        
        let localKeys = keyService.discoverLocalKeys()
        do {
            let result = try keyService.pack(keys: localKeys, to: diskManager.mountPoint)
            lastMessage = "Packed \(result.packed) keys, \(result.skipped) skipped."
            refreshStatus()
        } catch {
            currentError = "Pack failed: \(error.localizedDescription)"
        }
    }
    
    func restoreKeys() async {
        await unlockAndList()
        guard status.dmgState == .unlocked else { return }
        
        do {
            let result = try keyService.restore(keys: storedKeys, from: diskManager.mountPoint)
            lastMessage = "Restored \(result.restored) keys, \(result.skipped) skipped."
        } catch {
            currentError = "Restore failed: \(error.localizedDescription)"
        }
    }
    
    func performWipe() async {
        guard status.dmgState == .unlocked else { return }
        do {
            try keyService.wipe(mountPoint: diskManager.mountPoint)
            lastMessage = "Keystone store wiped."
            refreshStatus()
        } catch {
            currentError = "Wipe failed: \(error.localizedDescription)"
        }
        wipeConfirmationInput = ""
    }
}

struct StatusRow: View {
    let title: String
    let isActive: Bool
    var info: String? = nil
    
    var body: some View {
        HStack {
            Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isActive ? .green : .red)
            Text(title)
            Spacer()
            if let info = info {
                Text(info)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PassphrasePrompt: View {
    @Binding var passphrase: String
    var onCommit: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔑 Passphrase Required")
                .font(.headline)
            SecureField("Enter Passphrase", text: $passphrase)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel", action: onCancel)
                Spacer()
                Button("OK", action: onCommit)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
