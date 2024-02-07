//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import Refinery
import SwiftUI


extension BasicExampleView {
    
    final class ViewModel: ObservableObject {
        
        // MARK: Internal
        
        let refinery: Refinery<BasicStore>
        
        var store = BasicStore()
        
        // MARK: Private
        
        private enum ExampleIds: Int {
            case showFilterOptions
            case filterOptionsGroup
        }
        
        private enum SortOption: String {
            case nameAsc = "name_asc"
            case nameDesc = "name_desc"
            case oldest
            case newest
        }
        
        // MARK: Lifecycle
        
        init() {
            self.refinery = Refinery(title: "Basic Refinery", store: &store) {
                BoolNode(title: "Show Filter Options")
                    .assignId(ExampleIds.showFilterOptions)
                SelectionGroup(title: "Sort", method: .single(allowsEmptySelection: false)) {
                    BoolNode(title: "Name A-Z")
                        .initialSelection()
                        .storeValue(SortOption.nameAsc)
                    BoolNode(title: "Name Z-A")
                        .storeValue(SortOption.nameDesc)
                    BoolNode(title: "Newest")
                        .storeValue(SortOption.newest)
                    BoolNode(title: "Oldest")
                        .storeValue(SortOption.oldest)
                }
                .style(.inline)
                .assignId(ExampleIds.filterOptionsGroup)
                .assignStorage(to: \BasicStore.sortOption)
                .show(when: ExampleIds.showFilterOptions, meetsCondition: .selected)
            }
        }
        
        func linkStore() {
            refinery.onStoreUpdated {
                print(self.store.sortOption)
                return 0
            }
        }
    }
}
