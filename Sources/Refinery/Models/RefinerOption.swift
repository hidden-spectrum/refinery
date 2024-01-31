//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public class RefinerOption {

    // MARK: Public

    // MARK: Internal
    
    let displayText: String
    let value: String
    
    // MARK: Internal private(set)
    
    private(set) var hide: Bool = false

    // MARK: Private

    // MARK: Lifecycle

    public init(_ displayText: String, value: String) {
        self.displayText = displayText
        self.value = value
    }
    
    // MARK: Config
    
    func hidden() {
        hide = true
    }
}
