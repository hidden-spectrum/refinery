//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public class RefinerOption {

    // MARK: Public

    // MARK: Internal
    
    let value: String
    
    // MARK: Internal private(set)
    
    private(set) var hide: Bool = false

    // MARK: Private

    // MARK: Lifecycle

    public init(value: String) {
        self.value = value
    }
    
    // MARK: Config
    
    func hidden() {
        hide = true
    }
}
