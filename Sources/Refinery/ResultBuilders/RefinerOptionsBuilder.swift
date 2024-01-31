//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


@resultBuilder
public struct RefinerOptionsBuilder {
    public static func buildBlock<Store: RefineryStore>(_ components: RefinerOption<Store>...) -> [RefinerOption<Store>] {
        return components
    }
}
