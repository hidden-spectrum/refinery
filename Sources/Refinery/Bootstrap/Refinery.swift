//
//  Copyright © 2024 Hidden Spectrum, LLC.
//


public final class Refinery<Store: RefineryStore> {
    
    // MARK: Public
    
    public let store: Store
    
    // MARK: Private
    
    private let refiners: [Refiner<Store>]
    
    // MARK: Lifecycle
    
    public init(store: Store, @RefineryBuilder _ refiners: () -> [Refiner<Store>]) {
        self.refiners = refiners()
        self.store = store
    }
}
