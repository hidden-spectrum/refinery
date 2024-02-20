//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


public struct RefineryPopoverView<Store: RefineryStore>: View {
    
    // MARK: Private
    
    @Binding private var display: Bool
    
    @StateObject private var refinery: Refinery<Store>
    
    private var popoverNodes: [RefineryNode] {
        refinery.root.children.filter { $0.shouldShowInPopover }
    }
    
    // MARK: Lifecycle
    
    public init(with refinery: Refinery<Store>, display: Binding<Bool>) {
        self._refinery = StateObject(wrappedValue: refinery)
        self._display = display
    }
    
    // MARK: View
    
    public var body: some View {
        ForEach(popoverNodes) { node in
            VStack {
                if node.isVisible {
                    buildView(for: node)
                }
            }
        }
        .presentationCompactAdaptation(.popover)
        .onDisappear {
            refinery.apply()
        }
        .padding()
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
