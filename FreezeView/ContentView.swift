//
//  ContentView.swift
//  FreezeView
//
//  Created by tomworker on 2025/07/27.
//

import SwiftUI

struct ContentView: View {
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
            contentA: {
                VStack(spacing: 0) {
                    Text("A")
                }
                .frame(width: freezeSize.width, height: freezeSize.height)
                .background(.green)
            },
            contentB: { _, idx in
                VStack(spacing: 0) {
                    Text("B\(idx)")
                }
                .frame(width: cellSize.width, height: freezeSize.height)
                .background(idx % 2 == 0 ? .brown : .brown.opacity(0.8))
            },
            contentC: { _, idx in
                VStack(spacing: 0) {
                    Text("C\(idx)")
                }
                .frame(width: freezeSize.width, height: cellSize.height)
                .background(idx % 2 == 0 ? .cyan : .cyan.opacity(0.8))
            },
            contentD: { _, _, idx1, idx2 in
                VStack(spacing: 0) {
                    Text("D\(idx1)\(idx2)")
                }
                .frame(width: cellSize.width, height: cellSize.height)
                .background(idx1 % 2 == idx2 % 2 ? .purple.opacity(0.8) : .purple)
            }
        )
    }
}
