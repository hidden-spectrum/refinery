//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import Refinery


enum ExampleIds: Int {
    case showFilterOptions
    case filterOptionsGroup
}

enum SortOption: String {
    case nameAsc = "name_asc"
    case nameDesc = "name_desc"
    case oldest
    case newest
}


struct BasicStore: RefineryStore {

    // MARK: Internal
    
    var sortOption: String?
    var nameSearch: String?
}
