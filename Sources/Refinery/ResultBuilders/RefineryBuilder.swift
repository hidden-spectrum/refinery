//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


@resultBuilder
public struct RefineryBuilder {
    public static func buildBlock<Store: RefineryStore>(_ components: Refiner<Store>...) -> [Refiner<Store>] {
        return components
    }
}
