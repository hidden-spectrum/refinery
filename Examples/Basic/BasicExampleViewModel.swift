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
        
        // MARK: Lifecycle
        
        init() {
            self.refinery = Refinery(title: "Basic Refinery", store: &store) {
                BoolNode(title: "Show Filter Options")
                    .assignId(ExampleIds.showFilterOptions)
                SelectionGroup(title: "Sort", method: .single) {
                    BoolNode(title: "Name A-Z")
                    BoolNode(title: "Name Z-A")
                    BoolNode(title: "Newest")
                    BoolNode(title: "Oldest")
                }
                .style(.inline)
                .assignId(ExampleIds.filterOptionsGroup)
                .assignStorage(to: \BasicStore.sortOption)
                .show(when: ExampleIds.showFilterOptions, meetsCondition: .selected)
            }
        }
    }
}
