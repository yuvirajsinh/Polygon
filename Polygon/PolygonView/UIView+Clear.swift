//
//  UIView+Clear.swift
//  Polygon
//
//  Created by Yuvrajsinh Jadeja on 24/04/23.
//

import UIKit

extension UIView {
    func makeClearHole(path: CGPath) {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.fillColor = UIColor.black.cgColor

        let pathToOverlay = UIBezierPath(rect: self.bounds)
        pathToOverlay.append(UIBezierPath(cgPath: path))
        pathToOverlay.usesEvenOddFillRule = true
        maskLayer.path = pathToOverlay.cgPath

        layer.mask = maskLayer
    }
}
