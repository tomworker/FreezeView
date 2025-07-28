//
//  ContentView.swift
//  FreezeView
//
//  Created by tomworker on 2025/07/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject var scOffsetB = ScOffset(axes: .horizontal, origin: CGPoint(x: ConstManager.freezePoint.x, y: .zero))
    @StateObject var scOffsetC = ScOffset(axes: .vertical, origin: CGPoint(x: .zero, y: ConstManager.freezePoint.y))
    @StateObject var scOffsetD = ScOffset(axes: [.vertical, .horizontal], origin: CGPoint(x: ConstManager.freezePoint.x, y: ConstManager.freezePoint.y))
    @StateObject var sharedScOffset = ScOffset(axes: [.vertical, .horizontal], origin: CGPoint(x: ConstManager.freezePoint.x, y: ConstManager.freezePoint.y))
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScOffsetView(scOffset: scOffsetD, sharedScOffset: sharedScOffset) {
                    VStack(spacing: 0) {
                        if sharedScOffset.minY == .zero {
                            SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minY")
                        }
                        ForEach(Array(0..<ConstManager.totalRowNum).indices, id: \.self) { idx1 in
                            HStack(spacing: 0) {
                                ForEach(Array(0..<ConstManager.totalColumnNum).indices, id: \.self) { idx2 in
                                    if idx1 == 0 && idx2 == 0 {
                                        SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minX")
                                    }
                                    VStack(spacing: 0) {
                                        Text("D\(idx1)\(idx2)")
                                    }
                                    .frame(width: 60, height: 80)
                                    .background(idx1 % 2 == idx2 % 2 ? .purple.opacity(0.8) : .purple)
                                    if idx1 == ConstManager.totalRowNum - 1 && idx2 == ConstManager.totalColumnNum - 1 {
                                        SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxX")
                                    }
                                }
                            }
                        }
                        SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxY")
                    }
                    .position(x: ConstManager.freezePoint.x + ConstManager.centerPosition.x - sharedScOffset.deltaPositionX, y: ConstManager.freezePoint.y + ConstManager.centerPosition.y - sharedScOffset.deltaPositionY)
                }
                .onPanGesture()
                Spacer()
            }
            .onChange(of: sharedScOffset.deltaPositionX) {
                scOffsetB.deltaPositionX = sharedScOffset.deltaPositionX
                scOffsetB.endedValueX = sharedScOffset.endedValueX
                scOffsetB.initialValueX = sharedScOffset.initialValueX
                scOffsetD.deltaPositionX = sharedScOffset.deltaPositionX
                scOffsetD.endedValueX = sharedScOffset.endedValueX
                scOffsetD.initialValueX = sharedScOffset.initialValueX
            }
            .onChange(of: sharedScOffset.deltaPositionY) {
                scOffsetC.deltaPositionY = sharedScOffset.deltaPositionY
                scOffsetC.endedValueY = sharedScOffset.endedValueY
                scOffsetC.initialValueY = sharedScOffset.initialValueY
                scOffsetD.deltaPositionY = sharedScOffset.deltaPositionY
                scOffsetD.endedValueY = sharedScOffset.endedValueY
                scOffsetD.initialValueY = sharedScOffset.initialValueY
            }
            VStack(spacing: 0) {
                ScOffsetView(scOffset: scOffsetB, sharedScOffset: sharedScOffset) {
                    HStack(spacing: 0) {
                        SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minX")
                        ForEach(Array(0..<ConstManager.totalColumnNum).indices, id: \.self) { idx in
                            VStack(spacing: 0) {
                                Text("B\(idx)")
                            }
                            .frame(width: 60, height: 100)
                            .background(idx % 2 == 0 ? .brown : .brown.opacity(0.8))
                        }
                        SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxX")
                    }
                    .position(x: ConstManager.freezePoint.x + ConstManager.centerPosition.x - sharedScOffset.deltaPositionX, y: 50)
                }
                .onPanGesture()
                .frame(height: 100)
                Spacer()
            }
            HStack(spacing: 0) {
                ScOffsetView(scOffset: scOffsetC, sharedScOffset: sharedScOffset) {
                    VStack(spacing:0) {
                        SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minY")
                        ForEach(Array(0..<ConstManager.totalRowNum).indices, id: \.self) { idx in
                            VStack(spacing: 0) {
                                Text("C\(idx)")
                            }
                            .frame(width: 100, height: 80)
                            .background(idx % 2 == 0 ? .cyan : .cyan.opacity(0.8))
                        }
                        SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxY")
                    }
                    .position(x: 50, y: ConstManager.freezePoint.y + ConstManager.centerPosition.y - sharedScOffset.deltaPositionY)
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
                    .frame(width: 100, height: 100)
                    .background(.green)
                    .position(x: 50, y: 50)
                    Spacer()
                }
                Spacer()
            }
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
    static let totalRowNum = 30
    static let totalColumnNum = 20
    static let cellWidth = 60
    static let cellHeight = 80
    static let centerPosition = CGPoint(x: (cellWidth * totalColumnNum) / 2, y: (cellHeight * totalRowNum) / 2)
}
