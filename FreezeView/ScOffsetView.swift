//
//  ScOffsetView.swift
//  FreezeView
//
//  Created by tomworker on 2025/07/27.
//

import SwiftUI

struct ScOffsetView<Content: View>: UIViewControllerRepresentable {
    @State var viewController: UIViewController
    private let scOffset: ScOffset
    private let sharedScOffset: ScOffset
    @State var content: () -> Content

    init(scOffset: ScOffset, sharedScOffset: ScOffset, @ViewBuilder _ content: @escaping () -> Content) {
        self.scOffset = scOffset
        self.sharedScOffset = sharedScOffset
        self.content = content
        self.viewController = UIHostingController(rootView: content())
    }
    func makeUIViewController(context: Context) -> UIViewController {
        (viewController as! UIHostingController).rootView = content()
        //print("viewController:",viewController.view.frame.origin.x, ",",viewController.view.frame.origin.y, ",",viewController.view.frame.size.width, ",",viewController.view.frame.size.height)
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        (viewController as! UIHostingController).rootView = content()
        //print("viewController:",viewController.view.frame.origin.x, ",",viewController.view.frame.origin.y, ",",viewController.view.frame.size.width, ",",viewController.view.frame.size.height)
    }
    func onPanGesture() -> Self {
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: sharedScOffset, action: #selector(sharedScOffset.onPanGesture(_:)))
        viewController.view.addGestureRecognizer(panGesture)
        return self
    }
}
class ScOffset: NSObject, ObservableObject {
    //@Published var deltaPosition = CGFloat(0.0)
    @Published var deltaPositionX: CGFloat = .zero
    @Published var deltaPositionY: CGFloat = .zero
    @Published var minX: CGFloat = .zero
    @Published var minY: CGFloat = .zero
    @Published var maxX: CGFloat = .zero
    @Published var maxY: CGFloat = .zero
    //var initialValue = CGFloat(0.0)
    var initialValueX: CGFloat = .zero
    var initialValueY: CGFloat = .zero
    //var endedValue = CGFloat(0.0)
    var changedValueX: CGFloat = .zero
    var changedValueY: CGFloat = .zero
    var endedValueX: CGFloat = .zero
    var endedValueY: CGFloat = .zero
    private let axes: Axis.Set
    private let origin: CGPoint
    var axesMode = ""
    var timer: Timer?
    private var velocityX: CGFloat = .zero
    private var velocityY: CGFloat = .zero
    private var velocity: CGPoint = .zero
    private var decelerationRate: CGFloat = 0.97
    private var velocityThreshold: CGFloat = 5
    private var deltaInertiaPositionX: CGFloat = .zero
    private var deltaInertiaPositionY: CGFloat = .zero

    init(axes: Axis.Set, origin: CGPoint) {
        self.axes = axes
        self.origin = origin
    }
    @objc func onPanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            timer?.invalidate()
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
            timer?.invalidate()
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
            timer?.invalidate()
            velocityX = -sender.velocity(in: sender.view).x * 0.016
            velocityY = -sender.velocity(in: sender.view).y * 0.016
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
        if axes == .horizontal || axes == [.vertical, .horizontal] {
            if deltaPositionX < 0 {
                deltaPositionX = 0
                velocity = .zero
                timer?.invalidate()
            } else if deltaPositionX > maxX - minX + origin.x - UIScreen.main.bounds.width {
                deltaPositionX = maxX - minX + origin.x - UIScreen.main.bounds.width
                velocity = .zero
                timer?.invalidate()
            }
        }
        if axes == .vertical || axes == [.vertical, .horizontal] {
            if deltaPositionY < 0 {
                deltaPositionY = 0
                velocity = .zero
                timer?.invalidate()
            } else if deltaPositionY > maxY - minY + origin.y - UIScreen.main.bounds.height {
                deltaPositionY = maxY - minY + origin.y - UIScreen.main.bounds.height
                velocity = .zero
                timer?.invalidate()
            }
        }
    }
    private func startInertiaScrolling(senderView: UIView) {
        deltaInertiaPositionX = .zero
        deltaInertiaPositionY = .zero
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.velocity.x *= self.decelerationRate
            self.velocity.y *= self.decelerationRate
            if deltaPositionX + self.velocity.x < 0 {
                deltaPositionX = 0
            } else if deltaPositionX + self.velocity.x > maxX - minX + origin.x - UIScreen.main.bounds.width {
                deltaPositionX = maxX - minX + origin.x - UIScreen.main.bounds.width
            } else {
                self.deltaPositionX += self.velocity.x
                self.deltaInertiaPositionX += self.velocity.x
            }
            if deltaPositionY + self.velocity.y < 0 {
                deltaPositionY = 0
            } else if deltaPositionY + self.velocity.y > maxY - minY + origin.y - UIScreen.main.bounds.height {
                deltaPositionY = maxY - minY + origin.y - UIScreen.main.bounds.height
            } else {
                self.deltaPositionY += self.velocity.y
                self.deltaInertiaPositionY += self.velocity.y
            }
            if abs(self.velocity.x ) < self.velocityThreshold && abs(self.velocity.y) < self.velocityThreshold {
                self.timer?.invalidate()
            }
        }
    }
}
