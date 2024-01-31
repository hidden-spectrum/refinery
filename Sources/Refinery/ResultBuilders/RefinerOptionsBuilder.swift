//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


@resultBuilder
public struct RefinerOptionsBuilder {
    public static func buildBlock(_ components: RefinerOption...) -> [RefinerOption] {
        return components
    }
    
    public static func buildArray(_ components: [[RefinerOption]]) -> [RefinerOption] {
        components.flatMap { $0 }
    }
    
    public static func buildBlock(_ components: [RefinerOption]...) -> [RefinerOption] {
        components.flatMap { $0 }
    }
}
