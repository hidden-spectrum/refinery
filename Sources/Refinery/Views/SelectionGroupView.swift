//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct SelectionGroupView: View {

    // MARK: Private
    
    @StateObject private var selectionGroup: SelectionGroup
    
    private let context: DisplayContext

    // MARK: Lifecycle

    init(for selectionGroup: SelectionGroup, context: DisplayContext = .fullView) {
        _selectionGroup = StateObject(wrappedValue: selectionGroup)
        self.context = context
    }
    
    // MARK: View
    
    var body: some View {
        Group {
            switch selectionGroup.style {
            case .inline:
                inlineGroup()
            case .menu:
                menuGroup()
            }
        }
    }
    
    // MARK: Inline
    
    @ViewBuilder
    private func inlineGroup() -> some View {
        Section(selectionGroup.title) {
            ForEach(selectionGroup.boolChildren) { option in
                optionRow(with: option)
            }
        }
    }
    
    @ViewBuilder
    private func menuGroup() -> some View {
        Section(header: Text(selectionGroup.title).font(.caption)) {
            Menu(selectionGroup.selectedChildren.first?.title ?? "Select") {
                ForEach(selectionGroup.boolChildren) { node in
                    Button {
                        node.isSelected.toggle()
                    } label: {
                        optionView(for: node)
                    }
                }
            }
            .contentShape(Rectangle())
        }
    }
    
    @ViewBuilder
    private func optionView(for node: BoolNode) -> some View {
        HStack {
            Text(node.title)
            Spacer()
            if node.isSelected {
                Image(systemName: "checkmark")
                    .font(.caption)
            }
        }
    }
    
    @ViewBuilder
    private func optionRow(with node: BoolNode) -> some View {
        optionView(for: node)
            .frame(minHeight: 24)
            .contentShape(Rectangle())
            .onTapGesture {
                node.isSelected.toggle()
            }
    }
}
