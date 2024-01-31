//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public class Refiner<Store: RefineryStore> {

    // MARK: Public

    // MARK: Internal
    
    let displayText: String
    let options: [RefinerOption]
    
    // MARK: Internal private(set)
    
    private(set) var hide: Bool = false
    private(set) var value: String?

    // MARK: Private
    
    private let storeKey: WritableKeyPath<Store, String?>

    // MARK: Lifecycle

    init(_ displayText: String, storeKey: WritableKeyPath<Store, String?>, @RefinerOptionsBuilder _ options: () -> [RefinerOption]) {
        self.displayText = displayText
        self.options = options()
        self.storeKey = storeKey
    }
    
    // MARK: Config
    
    public func hidden() -> Self {
        hide = true
        return self
    }
}

extension Refiner: Identifiable {
    public var id: Int { storeKey.hashValue }
}
