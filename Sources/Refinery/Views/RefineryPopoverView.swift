//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


@available(iOS 16.4, *)
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
        .padding()
    }
    
    @ViewBuilder
    private func buildView(for node: RefineryNode) -> some View {
        if let boolNode = node as? BoolNode {
            BoolNodeView(with: boolNode)
        } else if node is TextNode {
            preconditionFailure("TextNode not supported in RefineryPopoverView")
        } else if let selectionGroup = node as? SelectionGroup {
            SelectionGroupView(for: selectionGroup, context: .popover)
                .onChange(of: selectionGroup.selectedChildren) { _ in
                    refinery.apply()
                }
        }
    }
}
