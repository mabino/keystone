import Foundation
import LocalAuthentication
import Observation

@MainActor
@Observable
class AuthenticationService {
    var isAuthenticated = false
    
    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Keystone")
                self.isAuthenticated = success
                return success
            } catch {
                print("Authentication failed: \(error.localizedDescription)")
                return false
            }
        } else {
            // Fallback for devices without Touch ID
            return true
        }
    }
}
