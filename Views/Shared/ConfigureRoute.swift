import Foundation

/// Distinct value type for pushing to Configure, so it can be registered as
/// its own `navigationDestination` separate from Technique's own (Home ->
/// Technique detail also pushes a bare `Technique` value, for the detail
/// screen itself — reusing the same type for both destinations would make
/// SwiftUI route every push to whichever destination was registered first).
struct ConfigureRoute: Hashable {
    let technique: Technique
}
