
//
//  FreezeScrollView.swift
//  FreezeView
//
//  Created by tomworker on 2026/04/12.
//

import SwiftUI

struct FreezeScrollView<A: View, B: View, C: View, D: View>: View {
    let rowCount: Int
    let columnCount: Int
    let cellSize: CGSize
    let freezeSize: CGSize
    let initialScroll: CGPoint
    let contentA: () -> A
    let contentB: (ClosedRange<Int>, Int) -> B
    let contentC: (ClosedRange<Int>, Int) -> C
    let contentD: (ClosedRange<Int>, ClosedRange<Int>, Int, Int) -> D
    @StateObject private var sharedScOffset: ScOffset
    private var centerPosition: CGPoint {
        CGPoint(x: (cellSize.width * CGFloat(columnCount)) / 2, y: (cellSize.height * CGFloat(rowCount)) / 2)
    }
    
    init(
        rowCount: Int,
        columnCount: Int,
        cellSize: CGSize,
        freezeSize: CGSize,
        initialScroll: CGPoint,
        @ViewBuilder contentA: @escaping () -> A,
        @ViewBuilder contentB: @escaping (ClosedRange<Int>, Int) -> B,
        @ViewBuilder contentC: @escaping (ClosedRange<Int>, Int) -> C,
        @ViewBuilder contentD: @escaping (ClosedRange<Int>, ClosedRange<Int>, Int, Int) -> D
    ) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.cellSize = cellSize
        self.freezeSize = freezeSize
        self.initialScroll = initialScroll
        self.contentA = contentA
        self.contentB = contentB
        self.contentC = contentC
        self.contentD = contentD
        _sharedScOffset = StateObject(wrappedValue: ScOffset(
            axes: [.vertical, .horizontal],
            rowCount: rowCount,
            columnCount: columnCount,
            cellSize: cellSize,
            freezeSize: freezeSize,
            initialScroll: initialScroll
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if sharedScOffset.minX == .zero  && sharedScOffset.maxX == .zero && sharedScOffset.minY == .zero && sharedScOffset.maxY == .zero  {
                    InitializingXView(sharedScOffset: sharedScOffset, columnCount: self.columnCount, cellSize: self.cellSize)
                    InitializingYView(sharedScOffset: sharedScOffset, rowCount: self.rowCount, cellSize: self.cellSize)
                }
                ScOffsetView(sharedScOffset: sharedScOffset) {
                    ZStack(alignment: .topLeading) {
                        let vRowRng = sharedScOffset.visibleRowRange
                        let vColRng = sharedScOffset.visibleColRange
                        ForEach(vRowRng, id: \.self) { idx1 in
                            ForEach(vColRng, id: \.self) { idx2 in
                                contentD(sharedScOffset.visibleRowRange, sharedScOffset.visibleColRange, idx1, idx2)
                                    .frame(width: cellSize.width, height: cellSize.height)
                                    .position(
                                        x: CGFloat(idx2) * cellSize.width + (cellSize.width / 2),
                                        y: CGFloat(idx1) * cellSize.height + (cellSize.height / 2)
                                    )
                            }
                        }
                        .offset(
                            x: sharedScOffset.contentOffsetX - centerPosition.x,
                            y: sharedScOffset.contentOffsetY - centerPosition.y
                        )
                    }
                }
                .onPanGesture()
                .onLongPressGesture()
                VStack(spacing: 0) {
                    ScOffsetView(sharedScOffset: sharedScOffset) {
                        ZStack(alignment: .topLeading) {
                            ForEach(sharedScOffset.visibleColRange, id: \.self) { idx in
                                contentB(sharedScOffset.visibleColRange, idx)
                                    .frame(width: cellSize.width, height: freezeSize.height)
                                    .position(x: CGFloat(idx) * cellSize.width + (cellSize.width / 2), y: freezeSize.height / 2)
                            }
                        }
                        .offset(x: sharedScOffset.contentOffsetX - centerPosition.x)
                    }
                    .onPanGesture()
                    .onLongPressGesture()
                    .frame(height: freezeSize.height)
                    Spacer()
                }
                HStack(spacing: 0) {
                    ScOffsetView(sharedScOffset: sharedScOffset) {
                        ZStack(alignment: .topLeading) {
                            ForEach(Array(0..<rowCount).indices, id: \.self) { idx in
                                contentC(sharedScOffset.visibleRowRange, idx)
                                    .frame(width: freezeSize.width, height: cellSize.height)
                                    .position(x: freezeSize.width / 2, y: CGFloat(idx) * cellSize.height + (cellSize.height / 2))
                            }
                        }
                        .frame(width: freezeSize.width)
                        .offset(y: sharedScOffset.contentOffsetY - centerPosition.y)
                    }
                    .onPanGesture()
                    .onLongPressGesture()
                    .frame(width: freezeSize.width)
                    Spacer()
                }
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        contentA()
                            .frame(width: freezeSize.width, height: freezeSize.height)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .onAppear {
                sharedScOffset.viewSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
                sharedScOffset.viewSize = newSize
            }
        }
    }
    private struct InitializingXView: View {
        @ObservedObject var sharedScOffset: ScOffset
        let columnCount: Int
        let cellSize: CGSize
        
        var body: some View {
            HStack(spacing: 0) {
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minX")
                ForEach(Array(0..<columnCount).indices, id: \.self) { idx in
                    VStack(spacing: 0) {}
                        .frame(width: cellSize.width, height: 0)
                }
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxX")
            }
        }
    }
    private struct InitializingYView: View {
        @ObservedObject var sharedScOffset: ScOffset
        let rowCount: Int
        let cellSize: CGSize
        
        var body: some View {
            VStack(spacing: 0) {
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minY")
                ForEach(Array(0..<rowCount).indices, id: \.self) { idx in
                    VStack(spacing: 0) {}
                        .frame(width: 0, height: cellSize.height)
                }
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxY")
            }
        }
    }
    struct SharedScOffsetInitializingView: View {
        @ObservedObject var sharedScOffset: ScOffset
        var boundingBox: String
        var body: some View {
            VStack(spacing: 0) {}
                .background(GeometryReader { proxy -> Color in
                    DispatchQueue.main.async {
                        switch boundingBox {
                        case "minX":
                            if sharedScOffset.minX == .zero { sharedScOffset.minX = proxy.frame(in: .named("")).origin.x }
                        case "maxX":
                            if sharedScOffset.maxX == .zero { sharedScOffset.maxX = proxy.frame(in: .named("")).origin.x }
                        case "minY":
                            if sharedScOffset.minY == .zero { sharedScOffset.minY = proxy.frame(in: .named("")).origin.y }
                        case "maxY":
                            if sharedScOffset.maxY == .zero { sharedScOffset.maxY = proxy.frame(in: .named("")).origin.y }
                        default:
                            print("error")
                        }
                    }
                    return Color.clear
                })
        }
    }
}
