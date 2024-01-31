//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


public final class Refinery<Store: RefineryStore>: ObservableObject {
    
    // MARK: Public
    
    public let store: Store
    
    // MARK: Internal
    
    let refiners: [Refiner<Store>]
    
    // MARK: Lifecycle
    
    public init(store: Store, @RefineryBuilder _ refiners: () -> [Refiner<Store>]) {
        self.refiners = refiners()
        self.store = store
    }
}
