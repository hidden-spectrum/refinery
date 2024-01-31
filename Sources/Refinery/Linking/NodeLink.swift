//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct NodeLink {
    
    // MARK: Internal
    
    let action: NodeLinkAction
    let condition: NodeLinkCondition
    let sourceId: Int
    let targetId: Int
    
    // MARK: Lifecycle
    
    init(sourceId: Int, condition: NodeLinkCondition, targetId: Int, action: NodeLinkAction) {
        self.action = action
        self.condition = condition
        self.sourceId = sourceId
        self.targetId = targetId
    }
}

extension NodeLink: CustomDebugStringConvertible {
    var debugDescription: String {
        "NodeLink(sourceId: \(sourceId), condition: \(condition), targetId: \(targetId), action: \(action))"
    }
}
