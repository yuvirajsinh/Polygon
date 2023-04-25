//
//  DetectionZoneView.swift
//  Polygon
//
//  Created by Yuvrajsinh Jadeja on 24/04/23.
//

import UIKit

final class DetectionZoneView: UIView {
    // MARK: - UI elements
    private let polygonView: PolygonView = PolygonView()
    private let overlayView: GridView = GridView()

    // MARK: - Public vars
    /// Returns polygon points
    var polygonPoints: [CGPoint] {
        return polygonView.polygonPoints
    }

    /// Maximum anchor points allowed
    var maxPoints: Int {
        get {
            polygonView.maxPoints
        }
        set {
            polygonView.maxPoints = newValue
        }
    }

    /// Size of anchor view. Default is (10,10)
    var anchorSize: CGSize {
        get {
            polygonView.anchorSize
        }
        set {
            polygonView.anchorSize = newValue
        }
    }

    /// Border color for polygon
    var borderColor: UIColor {
        get {
            polygonView.borderColor
        }
        set {
            polygonView.borderColor = newValue
        }
    }

    /// Line width for polygon
    var lineWidth: CGFloat {
        get {
            polygonView.lineWidth
        }
        set {
            polygonView.lineWidth = newValue
        }
    }

    /// Fill color for polygon
    var fillColor: UIColor? {
        get {
            polygonView.fillColor
        }
        set {
            polygonView.fillColor = newValue
        }
    }

    /// Color for anchor view
    var anchorColor: UIColor {
        get {
            polygonView.anchorColor
        }
        set {
            polygonView.anchorColor = newValue
        }
    }

    /// Color of the overlay view
    var overlayColor: UIColor? {
        get {
            overlayView.backgroundColor
        }
        set {
            overlayView.backgroundColor = newValue
        }
    }

    /// Grid size
    var gridSize: CGFloat {
        get {
            overlayView.gridSize
        }
        set {
            overlayView.gridSize = newValue
            polygonView.gridSize = newValue
        }
    }

    /// Color for the grid
    var gridColor: UIColor {
        get {
            overlayView.gridColor
        }
        set {
            overlayView.gridColor = newValue
        }
    }

    /// If grid is enabled or not
    var gridEnabled: Bool = false {
        didSet {
            overlayView.gridEnabled = gridEnabled
            polygonView.gridEnabled = gridEnabled
        }
    }

    // MARK: - Init and Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupOverlay()
        setupPolygon()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPolygon() {
        polygonView.frame = CGRect(origin: .zero, size: frame.size)
        polygonView.borderColor = borderColor
        polygonView.fillColor = fillColor
        polygonView.anchorColor = anchorColor
        polygonView.lineWidth = lineWidth
        polygonView.anchorSize = anchorSize
        polygonView.maxPoints = maxPoints
        polygonView.gridSize = gridSize

        polygonView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        addSubview(polygonView)

        polygonView.polygonDidChange = { path in
            self.overlayView.makeClearHole(path: path!)
        }
    }

    private func setupOverlay() {
        overlayView.backgroundColor = .black.withAlphaComponent(0.5)
        overlayView.frame = self.bounds
        overlayView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        addSubview(overlayView)
    }
}
