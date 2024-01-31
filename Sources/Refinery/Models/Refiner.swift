//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public class Refiner<Store: RefineryStore> {

    // MARK: Public

    // MARK: Internal
    
    var value: String?
    
    // MARK: Internal private(set)
    
    

    // MARK: Private
    
    private let options: [RefinerOption]
    private let storeKey: WritableKeyPath<Store, String?>

    // MARK: Lifecycle

    public init(storeKey: WritableKeyPath<Store, String?>, @RefinerOptionsBuilder _ options: () -> [RefinerOption]) {
        self.options = options()
        self.storeKey = storeKey
    }
}
