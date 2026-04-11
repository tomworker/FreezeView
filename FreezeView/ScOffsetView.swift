//
//  ScOffsetView.swift
//  FreezeView
//
//  Created by tomworker on 2025/07/27.
//

import SwiftUI

struct ScOffsetView<Content: View>: UIViewControllerRepresentable {
    @State var viewController: UIViewController
    private let sharedScOffset: ScOffset
    @State var content: () -> Content

    init(sharedScOffset: ScOffset, @ViewBuilder _ content: @escaping () -> Content) {
        self.sharedScOffset = sharedScOffset
        self.content = content
        self.viewController = UIHostingController(rootView: content())
    }
    func makeUIViewController(context: Context) -> UIViewController {
        (viewController as! UIHostingController).rootView = content()
       return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        (viewController as! UIHostingController).rootView = content()
    }
    func onPanGesture() -> Self {
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: sharedScOffset, action: #selector(sharedScOffset.onPanGesture(_:)))
        viewController.view.addGestureRecognizer(panGesture)
        return self
    }
}
@MainActor
class ScOffset: NSObject, ObservableObject {
    @Published var deltaPositionX: CGFloat = .zero
    @Published var deltaPositionY: CGFloat = .zero
    @Published var minX: CGFloat = .zero
    @Published var minY: CGFloat = .zero
    @Published var maxX: CGFloat = .zero {
        didSet { checkInitialization() }
    }
    @Published var maxY: CGFloat = .zero {
        didSet { checkInitialization() }
    }
    var initialValueX: CGFloat = .zero
    var initialValueY: CGFloat = .zero
    var changedValueX: CGFloat = .zero
    var changedValueY: CGFloat = .zero
    var endedValueX: CGFloat = .zero
    var endedValueY: CGFloat = .zero
    private let axes: Axis.Set
    private let origin: CGPoint
    var axesMode = ""
    private var velocityX: CGFloat = .zero
    private var velocityY: CGFloat = .zero
    private var velocity: CGPoint = .zero
    private var decelerationRate: CGFloat = 0.95
    private var velocityThreshold: CGFloat = 5
    private var deltaInertiaPositionX: CGFloat = .zero
    private var deltaInertiaPositionY: CGFloat = .zero
    @Published var contentOffsetX: CGFloat = .zero
    @Published var contentOffsetY: CGFloat = .zero
    private var displayLink: CADisplayLink?
    @Published var visibleRowRange: UnitRange = 0...15
    @Published var visibleColRange: UnitRange = 0...10
    @Published var isInitialized: Bool = false
    private var lastUpdatePosition: CGPoint = .zero

    init(axes: Axis.Set, origin: CGPoint, initialScroll: CGPoint = .zero) {
        self.axes = axes
        self.origin = origin
        self.deltaPositionX = initialScroll.x
        self.deltaPositionY = initialScroll.y
        self.endedValueX = initialScroll.x
        self.endedValueY = initialScroll.y
            super.init()
    }
    @objc func onPanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            if axes == .vertical {
                initialValueY = -sender.location(in: sender.view).y - deltaInertiaPositionY
            } else if axes == .horizontal {
                initialValueX = -sender.location(in: sender.view).x - deltaInertiaPositionX
            } else if axes == [.vertical, .horizontal] {
                if abs(sender.velocity(in:sender.view).x) > abs(sender.velocity(in:sender.view).y) {
                    axesMode = "H"
                    initialValueX = -sender.location(in: sender.view).x - deltaInertiaPositionX
                } else if abs(sender.velocity(in:sender.view).x) < abs(sender.velocity(in:sender.view).y) {
                    axesMode = "V"
                    initialValueY = -sender.location(in: sender.view).y - deltaInertiaPositionY
                }
            }
        case .changed:
            changedValueX = -sender.location(in: sender.view).x
            changedValueY = -sender.location(in: sender.view).y
            if axes == .vertical {
                deltaPositionY = (changedValueY - initialValueY + endedValueY)
            } else if axes == .horizontal {
                deltaPositionX = (changedValueX - initialValueX + endedValueX)
            } else if axes == [.vertical, .horizontal] {
                if axesMode == "H" {
                    deltaPositionX = (changedValueX - initialValueX + endedValueX)
                } else if axesMode == "V" {
                    deltaPositionY = (changedValueY - initialValueY + endedValueY)
                }
            }
        case .ended, .cancelled:
            velocityX = -sender.velocity(in: sender.view).x * 0.064
            velocityY = -sender.velocity(in: sender.view).y * 0.064
            if abs(velocityX) > abs(velocityY) {
                velocityY = .zero
            } else {
                velocityX = .zero
            }
            velocity = CGPoint(x: velocityX, y: velocityY)
            startInertiaScrolling(senderView: sender.view!)
            endedValueX = deltaPositionX
            endedValueY = deltaPositionY
        default:
            break
        }
        let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
        if axes.contains(.horizontal) {
            if deltaPositionX < 0 {
                deltaPositionX = 0
            } else if maxX != 0 {
                let limitX = maxX - minX + origin.x - screenWidth
                if deltaPositionX > limitX {
                    deltaPositionX = limitX
                }
            }
        }
        if axes.contains(.vertical) {
            if deltaPositionY < 0 {
                deltaPositionY = 0
            } else if maxY != 0 {
                let limitY = maxY - minY + origin.y - screenHeight
                if deltaPositionY > limitY {
                    deltaPositionY = limitY
                }
            }
        }
        self.updatePosition()
    }
    private func startInertiaScrolling(senderView: UIView) {
        deltaInertiaPositionX = .zero
        deltaInertiaPositionY = .zero
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateInertia))
        displayLink?.add(to: .main, forMode: .common)
    }
    @objc private func updateInertia() {
        self.velocity.x *= self.decelerationRate
        self.velocity.y *= self.decelerationRate
        let nextX = self.deltaPositionX + self.velocity.x
        if nextX < 0 {
            self.deltaPositionX = 0
        } else if isInitialized {
            let limitX = self.maxX - self.minX + self.origin.x - UIScreen.main.bounds.width
            if nextX > limitX {
                self.deltaPositionX = limitX
                self.velocity.x = 0
            } else {
                self.deltaPositionX = nextX
                self.deltaInertiaPositionX += self.velocity.x
            }
        } else {
            self.deltaPositionX = nextX
            self.deltaInertiaPositionX += self.velocity.x
        }
        let nextY = self.deltaPositionY + self.velocity.y
        if nextY < 0 {
            self.deltaPositionY = 0
        } else if isInitialized {
            let limitY = self.maxY - self.minY + self.origin.y - UIScreen.main.bounds.height
            if nextY > limitY {
                self.deltaPositionY = limitY
                self.velocity.y = 0
            } else {
                self.deltaPositionY = nextY
                self.deltaInertiaPositionY += self.velocity.y
            }
        } else {
            self.deltaPositionY = nextY
            self.deltaInertiaPositionY += self.velocity.y
        }
        self.updatePosition()
        if abs(self.velocity.x) < self.velocityThreshold && abs(self.velocity.y) < self.velocityThreshold {
            stopInertia()
        }
    }
    private func stopInertia() {
        displayLink?.invalidate()
        displayLink = nil
    }
    private func updatePosition() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let newX = ConstManager.freezePoint.x + ConstManager.centerPosition.x - deltaPositionX
        if contentOffsetX != newX { contentOffsetX = newX }
        let newY = ConstManager.freezePoint.y + ConstManager.centerPosition.y - deltaPositionY
        if contentOffsetY != newY { contentOffsetY = newY }
        let threshold: CGFloat = 20
        if abs(lastUpdatePosition.x - deltaPositionX) > threshold || abs(lastUpdatePosition.y - deltaPositionY) > threshold {
            let startRow = max(0, Int(deltaPositionY / CGFloat(ConstManager.cellHeight)))
            let startCol = max(0, Int(deltaPositionX / CGFloat(ConstManager.cellWidth)))
            let endRow = min(ConstManager.totalRowNum - 1, startRow + Int(screenHeight / CGFloat(ConstManager.cellHeight)) + 2)
            let endCol = min(ConstManager.totalColumnNum - 1, startCol + Int(screenWidth / CGFloat(ConstManager.cellWidth)) + 2)
            //print("startCol: \(startCol), deltaX: \(deltaPositionX)")
            lastUpdatePosition = CGPoint(x: deltaPositionX, y: deltaPositionY)
            visibleRowRange = startRow...endRow
            visibleColRange = startCol...endCol
            //print("deltaX: \(deltaPositionX), colRange: \(visibleColRange)")
        }
    }
    private func checkInitialization() {
        if maxX != .zero && maxY != .zero && !isInitialized {
            isInitialized = true
            self.updatePosition()
        }
    }
    typealias UnitRange = ClosedRange<Int>
}
