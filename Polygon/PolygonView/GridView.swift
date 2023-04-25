//
//  GridView.swift
//  Polygon
//
//  Created by Yuvrajsinh Jadeja on 24/04/23.
//

import UIKit

/// Creates view with grid lines
final class GridView: UIView {
    var gridSize: CGFloat = 40.0
    var gridColor: UIColor = .white {
        didSet {
            gridLayer.strokeColor = gridColor.cgColor
        }
    }
    private var gridPoits: [[CGPoint]] = []
    private var gridLayer: CAShapeLayer = CAShapeLayer()

    convenience init(gridSize: CGFloat) {
        self.init(frame: .zero)
        self.gridSize = gridSize
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        createGrid()
    }

    private func commonInit() {
        setupGridLayer()
        createGrid()
        backgroundColor = UIColor.black
    }

    private func setupGridLayer() {
        layer.addSublayer(gridLayer)

        gridLayer.opacity = 1.0
        gridLayer.lineWidth = 1.0
        gridLayer.lineCap = .butt
        gridLayer.lineJoin = .miter
        gridLayer.strokeColor = gridColor.cgColor
    }

    private func createGrid() {
        gridPoits.removeAll()
        var yPoint: CGFloat = 0

        let viewSize = frame.size

        let path = UIBezierPath()
        while yPoint < viewSize.height {
            let startPoint: CGPoint = CGPoint(x: 0.0, y: yPoint)
            let endPoint: CGPoint = CGPoint(x: viewSize.width, y: yPoint)

            path.move(to: startPoint)
            path.addLine(to: endPoint)

            yPoint += gridSize
        }
        var xPoint: CGFloat = 0
        while xPoint < viewSize.width {
            let startPoint: CGPoint = CGPoint(x: xPoint, y: 0.0)
            let endPoint: CGPoint = CGPoint(x: xPoint, y: viewSize.height)

            path.move(to: startPoint)
            path.addLine(to: endPoint)

            xPoint += gridSize
        }
        gridLayer.path = path.cgPath
    }
}
