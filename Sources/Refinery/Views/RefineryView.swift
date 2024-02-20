//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


public struct RefineryView<Store: RefineryStore>: View {
    
    // MARK: Private
    
    @Binding private var displayRefinery: Bool
    
    @StateObject private var refinery: Refinery<Store>
    
    private var fullViewNodes: [RefineryNode] {
        refinery.root.children.filter { $0.shouldShowInFullView }
    }
    
    // MARK: Lifecycle
    
    public init(with refinery: Refinery<Store>, displayRefinery: Binding<Bool>) {
        self._refinery = StateObject(wrappedValue: refinery)
        self._displayRefinery = displayRefinery
    }
    
    // MARK: View
    
    public var body: some View {
        VStack(spacing: 0) {
            NavigationView {
                ScrollViewReader { scrollProxy in
                    nodeList(with: scrollProxy)
                }
            }
            seeResultsButton()
        }
    }
    
    @ViewBuilder
    private func nodeList(with scrollProxy: ScrollViewProxy) -> some View {
        Form {
            ForEach(fullViewNodes) { node in
                if node.isVisible {
                    buildView(for: node)
                }
            }
        }
        .navigationTitle(NSLocalizedString("Filter & Sort", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent(with: scrollProxy) }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent(with scrollProxy: ScrollViewProxy) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Reset") {
                refinery.reset()
                withAnimation {
                    scrollProxy.scrollTo(refinery.root.children.first?.id, anchor: .top)
                }
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Apply") {
                refinery.apply()
                displayRefinery = false
            }
        }
    }
    
    @ViewBuilder
    private func seeResultsButton() -> some View {
        if refinery.showSeeResultsButton {
            Divider()
            
            let seeResultsText: String = {
                if let estimatedItemsCount = refinery.estimatedItemsCount {
                    return String(format: NSLocalizedString("See %i results", comment: ""), estimatedItemsCount)
                } else {
                    return NSLocalizedString("See results", comment: "")
                }
            }()
            
            Button(seeResultsText) {
                refinery.apply()
                displayRefinery = false
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
    }
    
    @ViewBuilder
    private func buildView(for node: RefineryNode) -> some View {
        if let boolNode = node as? BoolNode {
            BoolNodeView(with: boolNode)
        } else if let textNode = node as? TextNode {
            TextNodeView(with: textNode)
//        } else if let rangeFilter = node as? ValueFilter {
//            ValueFilterView(node: rangeFilter, surface: .advanced)
//                .padding(.vertical, 4)
//        } else if let rangeFilter = node as? RangeFilter {
//            RangeFilterView(node: rangeFilter, surface: .advanced)
//                .padding(.vertical, 4)
        } else if let selectionGroup = node as? SelectionGroup {
            SelectionGroupView(for: selectionGroup)
        }
    }
}
