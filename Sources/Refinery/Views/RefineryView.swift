//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


public struct RefineryView<Store: RefineryStore>: View {
    
    // MARK: Private
    
    @Binding private var displayRefinery: Bool
    
    @StateObject private var refinery: Refinery<Store>
    
    private let containerWidth: CGFloat
    
    // MARK: Lifecycle
    
    public init(with refinery: Refinery<Store>, displayRefinery: Binding<Bool>, containerWidth: CGFloat) {
        self._refinery = StateObject(wrappedValue: refinery)
        self._displayRefinery = displayRefinery
        self.containerWidth = containerWidth
    }
    
    // MARK: View
    
    public var body: some View {
        VStack(spacing: 0) {
            NavigationView {
                ScrollViewReader { scrollProxy in
                    withAnimation(.none) {
                        nodeList(with: scrollProxy)
                    }
                }
            }
            Divider()
            seeResultsButton()
        }
    }
    
    @ViewBuilder
    private func nodeList(with scrollProxy: ScrollViewProxy) -> some View {
        List(refinery.root.children) { node in
            if node.isVisible && !node.hideFromMenu {
                buildView(for: node)
                    .id(node.id)
            }
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 56)
        .navigationTitle(NSLocalizedString("Filter & Sort", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    refinery.reset()
                    withAnimation {
                        scrollProxy.scrollTo(refinery.root.children.first?.id, anchor: .top)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func seeResultsButton() -> some View {
        let seeResultsText: String = {
            if let estimatedItemsCount = refinery.estimatedItemsCount {
                return String(format: NSLocalizedString("See %i results", comment: ""), estimatedItemsCount)
            } else {
                return NSLocalizedString("See results", comment: "")
            }
        }()
        
        Button(seeResultsText) {
            displayRefinery = false
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }
    
    @ViewBuilder
    private func buildView(for node: RefineryNode) -> some View {
        if let boolNode = node as? BoolNode {
            BoolNodeView(with: boolNode)
                .padding(.vertical, 4)
//        } else if let rangeFilter = node as? ValueFilter {
//            ValueFilterView(node: rangeFilter, surface: .advanced)
//                .padding(.vertical, 4)
//        } else if let rangeFilter = node as? RangeFilter {
//            RangeFilterView(node: rangeFilter, surface: .advanced)
//                .padding(.vertical, 4)
//        } else if let selectionGroup = node as? SelectionGroup {
//            SelectionGroupView.InlineView(for: selectionGroup, containerWidth: containerWidth, surface: .advanced)
//                .padding(.vertical, 4)
        }
    }
}