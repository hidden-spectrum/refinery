//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Combine
import Foundation
import os.log


@MainActor
public class RefineryNode: ObservableObject, Identifiable {
    
    // MARK: Public
    
    public enum DisplayLocation {
        case fullView
        case quickFilterBar(index: Int, title: String?)
        case popover
        
        var context: DisplayContext {
            switch self {
            case .fullView:       .fullView
            case .quickFilterBar: .quickFilterBar
            case .popover:        .popover
            }
        }
    }
    
    public typealias StoreUpdatedClosure = (() async -> Int?)
    
    // MARK: Public private(set)
    
    public private(set) var id: Int = UUID().hashValue
    
    // MARK: Internal
    
    @Published var estimatedItemsCount: Int?
    
    // MARK: Internal
    
    @Published var isEnabled: Bool = true
    @Published var isVisible: Bool = true {
        willSet {
            children.forEach { $0.isVisible = newValue }
        }
    }
    
    let title: String
    
    var cancellables: [AnyCancellable] = []
    var displayLocations: [DisplayLocation] = [.fullView]
    var hasValue: Bool {
        assertionFailure("hasSelections must be overridden in all subclasses")
        return false
    }
    var isInInitialState: Bool {
        children.allSatisfy { $0.isInInitialState }
    }
    var quickFilterBarPosition: Int? {
        displayLocations.compactMap {
            if case .quickFilterBar(let index, _) = $0 {
                return index
            }
            return nil
        }.first
    }
    var shouldShowInQuickFilterBar: Bool {
        quickFilterBarPosition != nil
    }
    var shouldShowInFullView: Bool {
        displayLocations.map { $0.context }.contains(.fullView)
    }
    var shouldShowInPopover: Bool {
        displayLocations.map { $0.context }.contains(.popover)
    }
    
    // MARK: Internal private(set)
    
    private(set) var hide: Bool = false
    private(set) var value: String?
    
    // MARK: Private(set)
    
    private(set) var children: [RefineryNode] = []
    private(set) var hideCloseButton = false
    private(set) var links: [NodeLink] = []
    private(set) var seeResultsButtonTitle = NSLocalizedString("See results", comment: "")
    private(set) var storeKeyPath: AnyKeyPath?
    
    private(set) weak var parent: RefineryNode?
    
    // MARK: Private
    
    private let logger = Logger(subsystem: "io.hiddenspectrum.refinery", category: "RefineryNode")
    
    // MARK: Lifecycle
    
    init(title: String = "", children: [RefineryNode] = []) {
        self.title = title
        
        addChildren(children)
        setupObservers()
    }
    
    func setupObservers() {
        $isEnabled
            .removeDuplicates()
            .sink { [unowned self] _ in
                self.evaluateLinks(sourceActionFilter: .enabled)
            }
            .store(in: &cancellables)
        
        $isVisible
            .removeDuplicates()
            .sink { [unowned self] _ in
                self.evaluateLinks(sourceActionFilter: .visible)
            }
            .store(in: &cancellables)
    }
    
    // MARK: Tree Management
    
    func addChildren(_ nodes: [RefineryNode]) {
        for node in nodes {
            addChild(node)
        }
    }
    
    func addChild(_ node: RefineryNode) {
        assert(node !== self, "Cannot add node as a child to itself: \(nodeDescription)")
        assert(node.parent == nil, "Node \(nodeDescription) already added to another parent: \(parent?.nodeDescription ?? "<error>")")
        
        if node.parent === self {
            return
        }
        
        node.parent = self
        children.append(node)
        
        node.objectWillChange
            .sink { [unowned self] _ in
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func findChildNode(withId targetId: Int) -> RefineryNode? {
        if id == targetId {
            return self
        }
        
        for child in children {
            if let foundNode = child.findChildNode(withId: targetId) {
                return foundNode
            }
        }
        
        return nil
    }
    
    func findRoot() -> RefineryNode {
        if let parent = parent {
            return parent.findRoot()
        } else {
            return self
        }
    }
    
    func removeChild(_ node: RefineryNode) {
        guard let index = children.firstIndex(where: { $0 === node }) else {
            return
        }
        children.remove(at: index)
        node.parent = nil
    }
    
    func removeFromParent() {
        guard let parent else {
            return
        }
        parent.removeChild(self)
    }
    
    // MARK: Display Locations
    
    func quickFilterNodes(using array: [RefineryNode]) -> [RefineryNode] {
        var mutableArray = array
        if shouldShowInQuickFilterBar {
            mutableArray.append(self)
        }
        for child in children {
            mutableArray.append(contentsOf: child.quickFilterNodes(using: array))
        }
        return mutableArray
    }
    
    // MARK: Config
    
    public func assignId<T: RawRepresentable<Int>>(_ id: T) -> Self {
        self.id = id.rawValue
        return self
    }
    
    public func assignStorage<Store: RefineryStore>(to keyPath: PartialKeyPath<Store>) -> Self {
        storeKeyPath = keyPath
        return self
    }
    
    public func disable() -> Self {
        isEnabled = false
        return self
    }
    
    public func display(in displayLocations: DisplayLocation...) -> Self {
        self.displayLocations = displayLocations
        return self
    }
    
    // MARK: Node Links
    
    private func link<ID: RawRepresentable<Int>>(sourceId: ID, condition: NodeLinkCondition, action: NodeLinkAction) -> Self {
        links.append(
            NodeLink(
                sourceId: sourceId.rawValue,
                condition: condition,
                targetId: id,
                action: action
            )
        )
        return self
    }
    
    public func enable<ID: RawRepresentable<Int>>(when sourceId: ID, meetsCondition condition: NodeLinkCondition) -> Self {
        return link(sourceId: sourceId, condition: condition, action: .enable)
    }
    
    public func disable<ID: RawRepresentable<Int>>(when sourceId: ID, meetsCondition condition: NodeLinkCondition) -> Self {
        return link(sourceId: sourceId, condition: condition, action: .disable)
    }
    
    public func show<ID: RawRepresentable<Int>>(when sourceId: ID, meetsCondition condition: NodeLinkCondition) -> Self {
        return link(sourceId: sourceId, condition: condition, action: .show)
    }
    
    public func hide<ID: RawRepresentable<Int>>(when sourceId: ID, meetsCondition condition: NodeLinkCondition) -> Self {
        return link(sourceId: sourceId, condition: condition, action: .hide)
    }
    
    public func filter(matchingID id: any RawRepresentable<Int>) -> RefineryNode? {
        findChildNode(withId: id.rawValue)
    }
    
    // MARK: Link Management
    
    func migrateLinks() {
        let root = findRoot()
        let immutableLinks = links
        
        for (index, link) in immutableLinks.enumerated() {
            guard let sourceNode = root.findChildNode(withId: link.sourceId) else {
                logger.error("Could not find source node with ID: \(link.sourceId)")
                return
            }
            guard sourceNode !== self else {
                continue
            }
            sourceNode.links.append(link)
            links.remove(at: index)
            logger.debug("Migrated \(link.debugDescription) to \(sourceNode.debugDescription)")
        }
        
        for child in children {
            child.migrateLinks()
        }
    }
    
    func evaluateAllLinks() {
        evaluateLinks()
        for child in children {
            child.evaluateAllLinks()
        }
    }
    
    func evaluateLinks(sourceActionFilter: NodeLinkCondition? = nil) {
        if links.isEmpty {
            return
        }
        
        let filteredLinks = {
            if let sourceActionFilter {
                return links.filter { $0.condition == sourceActionFilter }
            } else {
                return links
            }
        }()
        let root = findRoot()
        
        for link in filteredLinks {
            guard let targetNode = root.findChildNode(withId: link.targetId) else {
                logger.error("Could not find target node with ID: \(link.targetId)")
                continue
            }
            switch (link.condition, link.action) {
            case (.enabled, .show):
                targetNode.isVisible = isEnabled
            case (.enabled, .hide):
                targetNode.isVisible = !isEnabled
            case (.enabled, .enable):
                targetNode.isEnabled = isEnabled
            case (.enabled, .disable):
                targetNode.isEnabled = !isEnabled
            case (.visible, .show):
                targetNode.isVisible = isVisible
            case (.visible, .hide):
                targetNode.isVisible = !isVisible
            case (.visible, .enable):
                targetNode.isEnabled = isVisible
            case (.visible, .disable):
                targetNode.isEnabled = !isVisible
            default:
                evaluateNonStandardLink(link, targetNode: targetNode)
            }
        }
    }
    
    func evaluateNonStandardLink(_ link: NodeLink, targetNode: RefineryNode) {
    }
    
    func updateValue<Store: RefineryStore>(in store: inout Store) {
        assertionFailure("storeValue must be overridden in all subclasses")
    }
    
    func reset() {
        assertionFailure("reset must be overridden in all subclasses")
    }
}

extension RefineryNode: CustomDebugStringConvertible {
    public var debugDescription: String {
        recursiveBuildDebugDescription().joined(separator: "\n")
    }
    
    var nodeDescription: String {
        "<Node \(Unmanaged.passUnretained(self).toOpaque())> (title: \"\(title)\", id: \(id)))"
    }
    
    func recursiveBuildDebugDescription() -> [String] {
        return [nodeDescription] + children
            .flatMap { $0.recursiveBuildDebugDescription() }
            .map { "\t" + $0 }
    }
}

extension RefineryNode: Equatable, Hashable {
    public static func == (lhs: RefineryNode, rhs: RefineryNode) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
