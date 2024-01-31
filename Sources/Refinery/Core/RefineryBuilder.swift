//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


@resultBuilder
public enum RefineryBuilder {
    public static func buildBlock(_ components: Any...) -> [RefineryNode] {
        var result = [RefineryNode]()
        for component in components {
            if let node = component as? RefineryNode {
                result.append(node)
            } else if let nodes = component as? [RefineryNode] {
                result.append(contentsOf: nodes)
            }
        }
        return result
    }
    
    public static func buildBlock(_ components: [RefineryNode]...) -> [RefineryNode] {
        components.flatMap { $0 }
    }
    
    public static func buildEither(first component: [RefineryNode]) -> [RefineryNode] {
        component
    }
    
    public static func buildEither(second component: [RefineryNode]) -> [RefineryNode] {
        component
    }
    
    public static func buildOptional(_ component: [RefineryNode]?) -> [RefineryNode] {
        component ?? []
    }
    
    public static func buildArray(_ components: [[RefineryNode]]) -> [RefineryNode] {
        var finalComponents = [RefineryNode]()
        components.forEach {
            finalComponents.append(contentsOf: $0)
        }
        return finalComponents
    }
}
