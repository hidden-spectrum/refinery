//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Refinery
import SwiftUI


struct BasicExampleView: View {
    
    // MARK: Private
    
    @State private var displayRefinery = false
    
    @StateObject var refinery: Refinery<BasicStore>
    
    // MARK: Lifecycle
    
    init() {
        _refinery = StateObject(wrappedValue: Self.buildRefinery())
    }
    
    static func buildRefinery() -> Refinery<BasicStore> {
        Refinery(title: "Basic Refinery") {
            TextNode(title: "Name")
                .assignStorage(to: \BasicStore.nameSearch)
            BoolNode(title: "Show Filter Options")
                .assignId(ExampleIds.showFilterOptions)
            SelectionGroup(title: "Sort", method: .single(allowsEmptySelection: false)) {
                BoolNode(title: "Name A-Z")
                    .initialSelection()
                    .value(SortOption.nameAsc)
                BoolNode(title: "Name Z-A")
                    .value(SortOption.nameDesc)
                BoolNode(title: "Newest")
                    .value(SortOption.newest)
                BoolNode(title: "Oldest")
                    .value(SortOption.oldest)
            }
            .style(.inline)
            .assignId(ExampleIds.filterOptionsGroup)
            .assignStorage(to: \BasicStore.sortOption)
            .show(when: ExampleIds.showFilterOptions, meetsCondition: .selected)
        }
        .onStoreUpdated { store in
            dump(store)
            return 0
        }
    }
    
    // MARK: View
    
    var body: some View {
        Button("Show Refinery") {
            displayRefinery.toggle()
        }
        .popover(isPresented: $displayRefinery, content: {
            RefineryView(with: refinery, displayRefinery: $displayRefinery)
        })
    }
}


#Preview {
    BasicExampleView()
}
