//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct SelectionGroupView: View {

    // MARK: Public

    // MARK: Internal

    // MARK: Private
    
    @StateObject
    private var selectionGroup: SelectionGroup

    // MARK: Lifecycle

    init(for selectionGroup: SelectionGroup) {
        _selectionGroup = StateObject(wrappedValue: selectionGroup)
    }
    
    // MARK: View
    
    var body: some View {
        switch selectionGroup.style {
        case .inline:
            inlineGroup()
        case .disclosure:
            disclosureGroup()
        default:
            EmptyView()
        }
    }
    
    // MARK: Inline
    
    @ViewBuilder
    private func inlineGroup() -> some View {
        Section(selectionGroup.title) {
            ForEach(selectionGroup.children) { option in
                boolNodeRow(with: option)
            }
        }
    }
    
    @ViewBuilder
    private func disclosureGroup() -> some View {
        Text("TBD")
    }
    
    @ViewBuilder
    private func boolNodeRow(with node: RefineryNode) -> some View {
        if let boolNode = node as? BoolNode {
            HStack {
                Text(boolNode.title)
                Spacer()
                if boolNode.isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                }
            }
            .frame(minHeight: 24)
            .contentShape(Rectangle())
            .onTapGesture {
                boolNode.isSelected.toggle()
            }
        }
    }
}
