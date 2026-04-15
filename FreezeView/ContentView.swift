//
//  ContentView.swift
//  FreezeView
//
//  Created by tomworker on 2025/07/27.
//

import SwiftUI

/// A sample implementation using `FreezeScrollView` to display a large grid.
struct ContentView: View {
    // Configuration constants for the grid layout
    let cellSize = CGSize(width: 60, height: 80)
    let freezeSize = CGSize(width: 100, height: 100)
    let initialScroll: CGPoint = .zero
    
    var body: some View {
        FreezeScrollView(
            rowCount: 1000,
            columnCount: 100,
            cellSize: cellSize,
            freezeSize: freezeSize,
            initialScroll: initialScroll,
            anchor: {
                Text("Anchor")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.green)
            },
            col: { _, idx in
                Text("Col\n\(idx)")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(idx % 2 == 0 ? .brown : .brown.opacity(0.8))
            },
            row: { _, idx in
                Text("Row\n\(idx)")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(idx % 2 == 0 ? .cyan : .cyan.opacity(0.8))
            },
            cell: { _, _, idx1, idx2 in
                Text("Cell\n\(idx1)\(idx2)")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(idx1 % 2 == idx2 % 2 ? .purple.opacity(0.8) : .purple)
            }
        )
    }
}
