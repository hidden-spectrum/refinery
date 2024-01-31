//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public final class BoolNode: RefineryNode {
    
    // MARK: Internal
    
    @Published var isAllOption: Bool = false
    @Published var isSelected: Bool = false
    
    // MARK: Lifecycle
    
    public init(isAllOption: Bool = false) {
        self.isAllOption = isAllOption
    }
}
