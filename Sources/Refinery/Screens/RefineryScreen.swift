//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


public struct RefineryScreen<Store: RefineryStore>: View {
    
    // MARK: Private
    
    @Binding private var display: Bool
    
    @StateObject private var refinery: Refinery<Store>
    
    private let style: Style
    
    private var actionButtonTitle: String {
        refinery.isInInitialState ? "Cancel" : "Apply"
    }
    private var fullViewNodes: [RefineryNode] {
        refinery.root.children.filter { $0.shouldShowInFullView }
    }
    
    // MARK: Lifecycle
    
    public init(with refinery: Refinery<Store>, display: Binding<Bool>, style: Style = Style()) {
        self._refinery = StateObject(wrappedValue: refinery)
        self._display = display
        self.style = style
    }
    
    // MARK: View
    
    public var body: some View {
        VStack(spacing: 0) {
            NavigationView {
                content()
                    .navigationTitle(refinery.root.title)
                    .navigationBarTitleDisplayMode(.inline)
            }
            seeResultsButton()
        }
    }
    
    @ViewBuilder
    private func content() -> some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                nodeList(with: scrollProxy)
            }
            .scrollContentBackground(.hidden)
            .background(style.backgroundColor)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private func nodeList(with scrollProxy: ScrollViewProxy) -> some View {
        VStack(spacing: 16) {
            ForEach(fullViewNodes) { node in
                if node.isVisible {
                    buildView(for: node)
                }
            }
        }
        .padding()
        .font(style.font)
        .frame(maxHeight: .infinity, alignment: .top)
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
            .font(style.font)
            .disabled(refinery.isInInitialState)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(actionButtonTitle) {
                refinery.apply()
                display = false
            }
            .font(style.font)
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
                display = false
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
        } else if let selectionGroup = node as? SelectionGroup {
            SelectionGroupView(for: selectionGroup)
        }
    }
}

public extension RefineryScreen {
    
     struct Style {
        
        // MARK: Internal
        
        let backgroundColor: Color?
        let font: Font?
        
        // MARK: Lifecycle
        
        public init(backgroundColor: Color? = nil, font: Font? = nil) {
            self.backgroundColor = backgroundColor
            self.font = font
        }
    }
}
