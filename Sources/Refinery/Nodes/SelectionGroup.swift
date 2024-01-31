//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


public enum SelectableOptionStyle {
    case single
    case multiple
}


public enum SelectGroupMethod {
    case single
    case multiple
    
    var selectableOptionStyle: SelectableOptionStyle {
        switch self {
        case .single:
            return .single
        case .multiple:
            return .multiple
        }
    }
}

extension SelectGroupMethod: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .single:
            return "single"
        case .multiple:
            return "multiple"
        }
    }
}


public final class SelectionGroup: RefineryNode {
    
    // MARK: Public
    
    public enum Style {
        case grid(itemWidth: CGFloat)
        case inline
        case scrolling
        case list
        case disclosure
    }
    
    public var selectedChildren: [BoolNode] {
        children
            .compactMap { $0 as? BoolNode }
            .filter { $0.isSelected }
    }
    
    // MARK: Internal
    
    let method: SelectGroupMethod
    
    var allOption: RefineryNode? {
        children.first(where: { ($0 as? BoolNode)?.isAllOption == true })
    }
    
    override var hasSelections: Bool {
        !selectedChildren.isEmpty
    }
    var selectedIndexes: [Int] {
        children
            .enumerated()
            .filter { ($0.element as? BoolNode)?.isSelected ?? false }
            .map { Int($0.offset) + 1 }
    }
    
    // MARK: Private(set)
    
    private(set) var style: Style = .disclosure
    
    // MARK: Private
    
    let logger = Logger(subsystem: "io.hiddenspectrum.refinery", category: "SelectionGroup")
    
    // MARK: Lifecycle
    
    public init(title: String, method: SelectGroupMethod, @RefineryBuilder _ builder: () -> [RefineryNode]) {
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
    
    // MARK: Node Lifecycle
    
    override func setupObservers() {
        super.setupObservers()
        children.compactMap({ $0 as? BoolNode }).forEach { child in
            child.$isSelected
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    self.selectedOptionChanged(child)
                }
                .store(in: &cancellables)
        }
        
    
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
    
    // MARK: Data Storage
    
    override func updateValue<Store: RefineryStore>(in store: inout Store) {
        guard let storeKeyPath else {
            return
        }

        let storeValues = selectedChildren.map { $0.storeValue }
        switch method {
        case .multiple:
            store.update(storeValues.isEmpty ? nil : storeValues, at: storeKeyPath)
        case .single:
            store.update(storeValues.first, at: storeKeyPath)
        }
    }
    
    // MARK: Compute
    
    func selectedOptionChanged(_ child: RefineryNode) {
        self.findRoot().initialLinkEvaluation()
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
    
    override func evaluateNonStandardLink(_ link: NodeLink, targetNode: RefineryNode) {
        switch (link.condition, link.action) {
        case (.selected, .show):
            targetNode.isVisible = isSelected
        case (.selected, .hide):
            targetNode.isVisible = !isSelected
        default:
            logger.warning("Unhandled link: \(link.debugDescription)")
        }
    }
    
    private var isSelected: Bool {
        children.compactMap({ $0 as? BoolNode }).contains(where: { $0.isSelected })
    }
    
    override public func reset() {
        children.forEach { $0.reset() }
    }
    
    public func boolFilter(matchingID id: Int) -> BoolNode? {
        children.first(where: { $0.id == id }) as? BoolNode
    }
}
