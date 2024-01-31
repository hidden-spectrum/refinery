//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public class SelectRefiner<Store: RefineryStore>: Refiner<Store> {

    // MARK: Public
    
    public enum Mode {
        case single
        case multiple
    }

    // MARK: Internal
    
    let mode: Mode

    // MARK: Private

    // MARK: Lifecycle

    public init(storeKey: WritableKeyPath<Store, String?>, mode: Mode, @RefinerOptionsBuilder _ options: () -> [RefinerOption<Store>]) {
        self.mode = mode
        super.init(storeKey: storeKey, options)
    }
}
