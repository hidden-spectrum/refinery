//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


public enum SelectGroupMethod {
    case single(allowsEmptySelection: Bool)
    case multiple
}

extension SelectGroupMethod: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .single(let allowsEmptySelection):
            "single(allowsEmptySelection: \(allowsEmptySelection)"
        case .multiple:
            "multiple"
        }
    }
}


public final class SelectionGroup: RefineryNode {
    
    // MARK: Public
    
    public enum Style {
        case inline
        case menu
    }
    
    public var selectedChildren: [BoolNode] {
        boolChildren.filter { $0.isSelected }
    }
    
    // MARK: Internal
    
    let method: SelectGroupMethod
    
    var allOption: RefineryNode? {
        children.first(where: { ($0 as? BoolNode)?.isAllOption == true })
    }
    var boolChildren: [BoolNode] {
        children.compactMap({ $0 as? BoolNode })
    }
    var selectedIndexes: [Int] {
        children
            .enumerated()
            .filter { ($0.element as? BoolNode)?.isSelected ?? false }
            .map { Int($0.offset) + 1 }
    }
    
    // MARK: Private(set)
    
    private(set) var style: Style = .inline
    
    // MARK: Private
    
    let logger = Logger(subsystem: "io.hiddenspectrum.refinery", category: "SelectionGroup")
    
    // MARK: Lifecycle
    
    public init(_ title: String, method: SelectGroupMethod, @RefineryBuilder _ builder: () -> [RefineryNode]) {
        let nodes = builder()
        assert(!nodes.contains { !($0 is BoolNode) }, "SelectionGroup can only contain BoolNode types")
        self.method = method
        super.init(title: title, children: nodes)
    }
    
    // MARK: Configuration
    
    public func style(_ style: Style) -> Self {
        self.style = style
        return self
    }
    
    // MARK: RefineryNode
    
    override var hasValue: Bool {
        !selectedChildren.isEmpty
    }
    
    override var isInInitialState: Bool {
        children.allSatisfy { $0.isInInitialState }
    }
    
    override func setupObservers() {
        super.setupObservers()
        
        $isEnabled
            .removeDuplicates()
            .sink { [unowned self] newValue in
                self.children.forEach { $0.isEnabled = newValue }
            }
            .store(in: &cancellables)
        
        $isVisible
            .removeDuplicates()
            .filter { $0 == false }
            .sink { [unowned self] _ in
                self.evaluateLinks()
            }
            .store(in: &cancellables)
    }
    
    override func updateValue<Store: RefineryStore>(in store: inout Store) {
        guard let storeKeyPath else {
            return
        }
        
        if !isEnabled || !isVisible {
            let nilValue: String? = nil
            store.update(nilValue, at: storeKeyPath)
            return
        }
        
        let storeValues = selectedChildren.compactMap { $0.storeValue }
        switch method {
        case .multiple:
            store.update(storeValues.isEmpty ? nil : storeValues, at: storeKeyPath)
        case .single:
            store.update(storeValues.first, at: storeKeyPath)
        }
    }
    
    override func evaluateNonStandardLink(_ link: NodeLink, targetNode: RefineryNode) {
        switch (link.condition, link.action) {
        case (.selected, .show):
            targetNode.isVisible = hasValue
        case (.selected, .hide):
            targetNode.isVisible = !hasValue
        default:
            logger.warning("Unhandled link: \(link.debugDescription)")
        }
    }
    
    override public func reset() {
        children.forEach { $0.reset() }
    }
    
    // MARK: Compute
    
    func selectedOptionChanged(by child: BoolNode) {
        evaluateGroupSelections(afterChangeOf: child)
        evaluateLinks(sourceActionFilter: .selected)
    }
    
    func evaluateGroupSelections(afterChangeOf modifiedChild: BoolNode) {
        defer {
            if selectedChildren.isEmpty {
                if let anyOption = boolChildren.first(where: { $0.isAllOption }) {
                    anyOption.isSelected = true
                } else if case .single(let allowsEmptySelection) = method, !allowsEmptySelection, !modifiedChild.isSelected {
                    modifiedChild.isSelected = true
                }
            }
        }
        
        guard modifiedChild.isSelected else {
            return
        }
        
        switch method {
        case .single:
            let otherSelectedBoolNodes = boolChildren
                .filter { $0.id != modifiedChild.id && $0.isSelected }
            for child in otherSelectedBoolNodes {
                child.isSelected = false
            }
        case .multiple:
            break
        }
    }
    
    func selectedOptionsCount(_ counter: Int = 0) -> Int {
        var mutableCounter = counter
        for node in children {
            if let selectionGroup = node as? SelectionGroup {
                mutableCounter += selectionGroup.selectedOptionsCount(mutableCounter)
            } else if let boolFilter = node as? BoolNode {
                mutableCounter += boolFilter.isSelected ? 1 : 0
            }
        }
        return mutableCounter
    }
    
    public func boolFilter(matchingID id: Int) -> BoolNode? {
        children.first(where: { $0.id == id }) as? BoolNode
    }
}
