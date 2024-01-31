//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public final class SelectRefiner<Store: RefineryStore>: Refiner<Store> {

    // MARK: Public
    
    public enum Mode {
        case single
        case multiple
    }

    // MARK: Internal
    
    let mode: Mode

    // MARK: Private

    // MARK: Lifecycle

    public init(_ displayText: String, storeKey: WritableKeyPath<Store, String?>, mode: Mode, @RefinerOptionsBuilder _ options: () -> [RefinerOption]) {
        self.mode = mode
        super.init(displayText, storeKey: storeKey, options)
    }
}
