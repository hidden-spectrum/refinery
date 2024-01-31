//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public enum NodeLinkCondition: Equatable {
    case enabled
    case visible
    case selected
    case rangeReachesMin(Double)
    case rangeReachesMax(Double)
}
