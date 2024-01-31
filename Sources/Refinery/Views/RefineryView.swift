//
//  SwiftUIView.swift
//  
//
//  Created by Andrew Theis on 1/31/24.
//

import SwiftUI


public struct RefineryView<Store: RefineryStore>: View {
    
    // MARK: Private
    
    @StateObject private var refinery: Refinery<Store>
    
    // MARK: Lifecycle
    
    public init(with refinery: Refinery<Store>) {
        _refinery = StateObject(wrappedValue: refinery)
    }
    
    // MARK: View
    
    public var body: some View {
        Form {
            ForEach(refinery.refiners) { refiner in
                if !refiner.hide {
                    Text(refiner.displayText)
                }
            }
        }
    }
}
