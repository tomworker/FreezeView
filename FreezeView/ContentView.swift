//
//  ContentView.swift
//  FreezeView
//
//  Created by tomworker on 2025/07/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject var sharedScOffset = ScOffset(
        axes: [.vertical, .horizontal],
        origin: CGPoint(x: ConstManager.freezePoint.x, y: ConstManager.freezePoint.y),
        initialScroll: CGPoint(
            x: CGFloat(0 * ConstManager.cellWidth),
            y: CGFloat(0 * ConstManager.cellHeight)
        )
    )
    var body: some View {
        ZStack {
            if sharedScOffset.minX == .zero  && sharedScOffset.maxX == .zero && sharedScOffset.minY == .zero && sharedScOffset.maxY == .zero  {
                InitializingXView(sharedScOffset: sharedScOffset)
                InitializingYView(sharedScOffset: sharedScOffset)
            }
            ScOffsetView(sharedScOffset: sharedScOffset) {
                 ZStack(alignment: .topLeading) {
                     let vRowRng = sharedScOffset.visibleRowRange
                     let vColRng = sharedScOffset.visibleColRange
                     ForEach(vRowRng, id: \.self) { idx1 in
                         ForEach(vColRng, id: \.self) { idx2 in
                             VStack(spacing: 0) {
                                 Text("D\(idx1)\(idx2)")
                             }
                             .frame(width: 60, height: 80)
                             .background(idx1 % 2 == idx2 % 2 ? .purple.opacity(0.8) : .purple)
                             .position(
                                x: CGFloat(idx2 * ConstManager.cellWidth) + 30,
                                y: CGFloat(idx1 * ConstManager.cellHeight) + 40
                             )
                         }
                     }
                     .offset(
                         x: sharedScOffset.contentOffsetX - ConstManager.centerPosition.x,
                         y: sharedScOffset.contentOffsetY - ConstManager.centerPosition.y
                    )
                }
            }
            .onPanGesture()
            VStack(spacing: 0) {
                ScOffsetView(sharedScOffset: sharedScOffset) {
                    ZStack(alignment: .topLeading) {
                        ForEach(sharedScOffset.visibleColRange, id: \.self) { idx in
                            VStack(spacing: 0) {
                                Text("B\(idx)")
                            }
                            .frame(width: 60, height: 100)
                            .background(idx % 2 == 0 ? .brown : .brown.opacity(0.8))
                            .position(x: CGFloat(idx * ConstManager.cellWidth) + 30, y: 50)
                        }
                    }
                    .offset(x: sharedScOffset.contentOffsetX - ConstManager.centerPosition.x)
                }
                .onPanGesture()
                .frame(height: 100)
                Spacer()
            }
            HStack(spacing: 0) {
                ScOffsetView(sharedScOffset: sharedScOffset) {
                    ZStack(alignment: .topLeading) {
                        ForEach(Array(0..<ConstManager.totalRowNum).indices, id: \.self) { idx in
                            VStack(spacing: 0) {
                                Text("C\(idx)")
                            }
                            .frame(width: 100, height: 80)
                            .background(idx % 2 == 0 ? .cyan : .cyan.opacity(0.8))
                            .position(x: 50, y: CGFloat(idx * ConstManager.cellHeight) + 40)
                        }
                    }
                    .frame(width: 100)
                    .offset(y: sharedScOffset.contentOffsetY - ConstManager.centerPosition.y)
                }
                .onPanGesture()
                .frame(width: 100)
                Spacer()
            }
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text("A")
                    }
                    .frame(width: ConstManager.freezePoint.x, height: ConstManager.freezePoint.y)
                    .background(.green)
                    Spacer()
                }
                Spacer()
            }
        }
    }
    struct InitializingXView: View {
        @ObservedObject var sharedScOffset: ScOffset
        var body: some View {
            HStack(spacing: 0) {
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minX")
                ForEach(Array(0..<ConstManager.totalColumnNum).indices, id: \.self) { idx in
                    VStack(spacing: 0) {}
                        .frame(width: CGFloat(ConstManager.cellWidth), height: 0)
                }
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxX")
            }
        }
    }
    struct InitializingYView: View {
        @ObservedObject var sharedScOffset: ScOffset
        var body: some View {
            VStack(spacing: 0) {
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minY")
                ForEach(Array(0..<ConstManager.totalRowNum).indices, id: \.self) { idx in
                    VStack(spacing: 0) {}
                    .frame(width: 0, height: CGFloat(ConstManager.cellHeight))
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
struct ConstManager {
    static let freezePoint = CGPoint(x: 100, y: 100)
    static let totalRowNum = 999
    static let totalColumnNum = 99
    static let cellWidth = 60
    static let cellHeight = 80
    static let centerPosition = CGPoint(x: (cellWidth * totalColumnNum) / 2, y: (cellHeight * totalRowNum) / 2)
}
