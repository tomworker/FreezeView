//
//  ContentView.swift
//  FreezeView
//
//  Created by tomworker on 2025/07/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject var sharedScOffset = ScOffset(axes: [.vertical, .horizontal], origin: CGPoint(x: ConstManager.freezePoint.x, y: ConstManager.freezePoint.y))
    var body: some View {
        ZStack {
            if sharedScOffset.minX == .zero  && sharedScOffset.maxX == .zero && sharedScOffset.minY == .zero && sharedScOffset.maxY == .zero  {
                InitializingXView(sharedScOffset: sharedScOffset)
                InitializingYView(sharedScOffset: sharedScOffset)
            }
            ScOffsetView(sharedScOffset: sharedScOffset) {
                ZStack {
                    ForEach(Array(0..<ConstManager.totalRowNum).indices, id: \.self) { idx1 in
                        if (CGFloat(ConstManager.cellHeight) * (0) < (ConstManager.freezePoint.y + CGFloat(ConstManager.cellHeight) * CGFloat(idx1) - sharedScOffset.deltaPositionY)) && ((ConstManager.freezePoint.y + CGFloat(ConstManager.cellHeight) * CGFloat(idx1) - sharedScOffset.deltaPositionY) < CGFloat(ConstManager.cellHeight) * (10)) {
                            ForEach(Array(0..<ConstManager.totalColumnNum).indices, id: \.self) { idx2 in
                                if (CGFloat(ConstManager.cellWidth) * (0) < (ConstManager.freezePoint.x + CGFloat(ConstManager.cellWidth) * CGFloat(idx2) - sharedScOffset.deltaPositionX)) && ((ConstManager.freezePoint.x + CGFloat(ConstManager.cellWidth) * CGFloat(idx2) - sharedScOffset.deltaPositionX) < CGFloat(ConstManager.cellWidth) * (7)) {
                                    VStack(spacing: 0) {
                                        Text("D\(idx1)\(idx2)")
                                    }
                                    .frame(width: 60, height: 80)
                                    .background(idx1 % 2 == idx2 % 2 ? .purple.opacity(0.8) : .purple)
                                    .offset(x: CGFloat(ConstManager.cellWidth) * (CGFloat(idx2) + 0.5) - ConstManager.centerPosition.x, y: CGFloat(ConstManager.cellHeight) * (CGFloat(idx1) + 0.5) - ConstManager.centerPosition.y)
                                }
                            }
                        }
                    }
                }
                .position(x: ConstManager.freezePoint.x + ConstManager.centerPosition.x - sharedScOffset.deltaPositionX, y: ConstManager.freezePoint.y + ConstManager.centerPosition.y - sharedScOffset.deltaPositionY)
                .id(abs(Int(sharedScOffset.deltaPositionX)) + abs(Int(sharedScOffset.deltaPositionY)))
            }
            .onPanGesture()
            VStack(spacing: 0) {
                ScOffsetView(sharedScOffset: sharedScOffset) {
                    ZStack {
                        ForEach(Array(0..<ConstManager.totalColumnNum).indices, id: \.self) { idx in
                            if (CGFloat(ConstManager.cellWidth) * (0) < (ConstManager.freezePoint.x + CGFloat(ConstManager.cellWidth) * CGFloat(idx) - sharedScOffset.deltaPositionX)) && ((ConstManager.freezePoint.x + CGFloat(ConstManager.cellWidth) * CGFloat(idx) - sharedScOffset.deltaPositionX) < CGFloat(ConstManager.cellWidth) * (7)) {
                                VStack(spacing: 0) {
                                    Text("B\(idx)")
                                }
                                .frame(width: 60, height: 100)
                                .background(idx % 2 == 0 ? .brown : .brown.opacity(0.8))
                                .offset(x: CGFloat(ConstManager.cellWidth) * (CGFloat(idx) + 0.5) - ConstManager.centerPosition.x)
                            }
                        }
                    }
                    .position(x: ConstManager.freezePoint.x + ConstManager.centerPosition.x - sharedScOffset.deltaPositionX, y: 50)
                    .id(abs(Int(sharedScOffset.deltaPositionX)))
                }
                .onPanGesture()
                .frame(height: 100)
                Spacer()
            }
            HStack(spacing: 0) {
                ScOffsetView(sharedScOffset: sharedScOffset) {
                    ZStack {
                        ForEach(Array(0..<ConstManager.totalRowNum).indices, id: \.self) { idx in
                            if (CGFloat(ConstManager.cellHeight) * (0) < (ConstManager.freezePoint.y + CGFloat(ConstManager.cellHeight) * CGFloat(idx) - sharedScOffset.deltaPositionY)) && ((ConstManager.freezePoint.y + CGFloat(ConstManager.cellHeight) * CGFloat(idx) - sharedScOffset.deltaPositionY) < CGFloat(ConstManager.cellHeight) * (10)) {
                                VStack(spacing: 0) {
                                    Text("C\(idx)")
                                }
                                .frame(width: 100, height: 80)
                                .background(idx % 2 == 0 ? .cyan : .cyan.opacity(0.8))
                                .offset(y: CGFloat(ConstManager.cellHeight) * (CGFloat(idx) + 0.5) - ConstManager.centerPosition.y)
                            }
                        }
                    }
                    .frame(width: 100)
                    .position(x: 50, y: ConstManager.freezePoint.y + ConstManager.centerPosition.y - sharedScOffset.deltaPositionY)
                    .id(abs(Int(sharedScOffset.deltaPositionY)))
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
                    .position(x: ConstManager.freezePoint.x * 0.5, y: ConstManager.freezePoint.y * 0.5)
                    Spacer()
                }
                Spacer()
            }
        }
    }
    struct InitializingXView: View {
        @StateObject var sharedScOffset: ScOffset
        var body: some View {
            HStack(spacing: 0) {
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minX")
                ForEach(Array(0..<ConstManager.totalColumnNum).indices, id: \.self) { idx in
                    VStack(spacing: 0) {}
                        .frame(width: CGFloat(ConstManager.cellWidth), height: 0)
                }
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxX")
            }
            .position(x: ConstManager.freezePoint.x + ConstManager.centerPosition.x - sharedScOffset.deltaPositionX)
        }
    }
    struct InitializingYView: View {
        @StateObject var sharedScOffset: ScOffset
        var body: some View {
            VStack(spacing: 0) {
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minY")
                ForEach(Array(0..<ConstManager.totalRowNum).indices, id: \.self) { idx in
                    VStack(spacing: 0) {}
                    .frame(width: 0, height: CGFloat(ConstManager.cellHeight))
                }
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxY")
            }
            .position(y: ConstManager.freezePoint.y + ConstManager.centerPosition.y - sharedScOffset.deltaPositionY)
        }
    }
    struct SharedScOffsetInitializingView: View {
        @StateObject var sharedScOffset: ScOffset
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
