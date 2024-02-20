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
        Refinery("Basic Refinery") {
            TextNode("Name")
                .assignStorage(to: \BasicStore.nameSearch)
            BoolNode("Show Filter Options")
                .assignId(ExampleIds.showFilterOptions)
            SelectionGroup("Sort", method: .single(allowsEmptySelection: false)) {
                BoolNode("Name A-Z")
                    .initialSelection()
                    .value(SortOption.nameAsc)
                BoolNode("Name Z-A")
                    .value(SortOption.nameDesc)
                BoolNode( "Newest")
                    .value(SortOption.newest)
                BoolNode("Oldest")
                    .value(SortOption.oldest)
            }
            .style(.inline)
            .assignId(ExampleIds.filterOptionsGroup)
            .assignStorage(to: \BasicStore.sortOption)
            .show(when: ExampleIds.showFilterOptions, meetsCondition: .selected)
        }
        .onApply { store in
            dump(store)
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
