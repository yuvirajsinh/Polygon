//
//  PolygonAnchorView.swift
//  Polygon
//
//  Created by Yuvrajsinh Jadeja on 01/03/23.
//

import UIKit

final class PolygonAnchorView: UIView {
    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    private var shapeLayer: CAShapeLayer = CAShapeLayer()

    /// Anchor color
    var anchorColor: UIColor = .blue {
        didSet {
            shapeLayer.fillColor = anchorColor.cgColor
        }
    }

    /// Anchor size
    var anchorSize: CGSize = CGSizeMake(10.0, 10.0)

    /// Defines bounds for anchor. Anchor can be moved/dragged within given bounds only
    var dragBound: CGRect = CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0))

    /// Closure to be called on click of anchor
    var onClicked: ((UIView) -> Void)?

    /// Closure to be called on drag of anchor
    var onDrag: ((UIView, UIGestureRecognizer.State) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        setupShapeLayer()
        setupTapGesture()
        setupPanGesture()
    }

    private func setupShapeLayer() {
        if shapeLayer.superlayer == nil {
            shapeLayer.fillColor = anchorColor.cgColor
            let origin = CGPoint(x: bounds.width / 2 - anchorSize.width / 2.0, y: bounds.height / 2.0 - anchorSize.height / 2.0)
            shapeLayer.path = CGPath(ellipseIn: CGRect(origin: origin, size: anchorSize), transform: nil)
            layer.addSublayer(shapeLayer)
        }
    }

    private func setupTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDetected(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGesture)
    }

    private func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureDetected(_:)))
        addGestureRecognizer(panGesture)
    }

    @objc private func tapGestureDetected(_ gesture: UITapGestureRecognizer) {
        onClicked?(self)
    }

    @objc private func panGestureDetected(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view  else { return }
        let translation = gesture.translation(in: view)

        var newFrame = self.frame
        newFrame.origin.x += translation.x
        newFrame.origin.y += translation.y

        if dragBound.contains(newFrame) {
            self.frame = newFrame
            gesture.setTranslation(.zero, in: view)
        }
        onDrag?(self, gesture.state)
    }
}

extension PolygonAnchorView: UIGestureRecognizerDelegate {

}
