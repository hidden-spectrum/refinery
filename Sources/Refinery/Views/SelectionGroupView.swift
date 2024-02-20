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
            case .disclosure:
                disclosureGroup()
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: Inline
    
    @ViewBuilder
    private func inlineGroup() -> some View {
        Section(selectionGroup.title) {
            ForEach(selectionGroup.boolChildren) { option in
                boolNodeRow(with: option)
            }
        }
    }
    
    @ViewBuilder
    private func disclosureGroup() -> some View {
        Text("TBD")
    }
    
    @ViewBuilder
    private func boolNodeRow(with node: BoolNode) -> some View {
        HStack {
            Text(node.title)
            Spacer()
            if node.isSelected {
                Image(systemName: "checkmark")
                    .font(.caption)
            }
        }
        .frame(minHeight: 24)
        .contentShape(Rectangle())
        .onTapGesture {
            node.isSelected.toggle()
        }
    }
}
