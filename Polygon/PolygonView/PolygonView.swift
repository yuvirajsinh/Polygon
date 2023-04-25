//
//  PolygonView.swift
//  Polygon
//
//  Created by Yuvrajsinh Jadeja on 01/03/23.
//

import UIKit

final class PolygonView: UIView {
    // MARK: - UI elements
    private let shapeLayer: CAShapeLayer = CAShapeLayer()
    private var tapGesture: UITapGestureRecognizer!

    // MARK: - Vars
    private var _points: [CGPoint] = []
    private var anchors: [PolygonAnchorView] = []

    /// Returns Bool to check if anchor points form a valid polygon or not.
    /// Return `true` if at least 3 points are available, else returns `false`
    var isValid: Bool {
        return _points.count > 2
    }

    /// Returns polygon points
    var polygonPoints: [CGPoint] {
        return _points
    }

    /// Maximum anchor points allowed
    var maxPoints: Int = 8

    /// Size of anchor view. Default is (10,10)
    var anchorSize: CGSize = CGSize(width: 10.0, height: 10.0)

    /// Border color for polygon
    var borderColor: UIColor = .white {
        didSet {
            shapeLayer.strokeColor = borderColor.cgColor
        }
    }

    /// Line width for polygon
    var lineWidth: CGFloat = 1 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }

    /// Fill color for polygon
    var fillColor: UIColor? = nil {
        didSet {
            shapeLayer.fillColor = fillColor?.cgColor
        }
    }

    /// Color for anchor view
    var anchorColor: UIColor = .white {
        didSet {
            redrawPolygonAndAnchors()
        }
    }

    var gridSize: CGFloat = 40.0
    var gridEnabled: Bool = false

    /// Closure which will ge called when polygon points are changed
    var polygonDidChange: ((_ path: CGPath?) -> Void)?

    // MARK: - Init and overrides
    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil, tapGesture != nil {
            self.removeGestureRecognizer(tapGesture)
        }
    }

    // MARK: - UI setup and Helpers
    private func commonInit() {
        isUserInteractionEnabled = true
        setupShapeLayer()
        setupTapGesture()
    }

    private func setupShapeLayer() {
        layer.addSublayer(shapeLayer)

        shapeLayer.opacity = 1.0
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .butt
        shapeLayer.lineJoin = .miter
        shapeLayer.strokeColor = borderColor.withAlphaComponent(0.3).cgColor
        shapeLayer.fillColor = fillColor?.withAlphaComponent(0.3).cgColor
    }

    private func setupTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDetected(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGesture)
    }

    @objc private func tapGestureDetected(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        addNewPoint(point)
        redrawPolygonAndAnchors()
    }

    private func addNewPoint(_ newPoint: CGPoint) {
        let nearestPoint = gridEnabled ? findSnapToPoint(for: newPoint) : newPoint
        guard _points.count < maxPoints else {
            return
        }
        guard _points.count > 3 else {
            _points.append(nearestPoint)
            return
        }

        var minDistanceIndex: Int = 0
        var minDistance: CGFloat = distance(nearestPoint, _points[0])
        for i in 1..<_points.count {
            let currDistance = distance(nearestPoint, _points[i])
            if currDistance < minDistance {
                minDistance = currDistance
                minDistanceIndex = i
            }
        }

        let prevIndex = minDistanceIndex == 0 ? _points.count - 1 : minDistanceIndex - 1
        let nextIndex = minDistanceIndex == _points.count - 1 ? 0 : minDistanceIndex + 1

        if doIntersect(p1: _points[prevIndex], q1: nearestPoint, p2: _points[minDistanceIndex], q2: _points[nextIndex]) {
            _points.insert(nearestPoint, at: minDistanceIndex + 1)
        } else {
            _points.insert(nearestPoint, at: minDistanceIndex)
        }
    }

    private func findSnapToPoint(for point: CGPoint) -> CGPoint {
        let xDiff = point.x.truncatingRemainder(dividingBy: gridSize)
        let yDiff = point.y.truncatingRemainder(dividingBy: gridSize)

        let topLeft = CGPoint(x: point.x - xDiff, y: point.y - yDiff)
        let topRight = CGPoint(x: topLeft.x + gridSize, y: topLeft.y)
        let bottomRight = CGPoint(x: topRight.x, y: topRight.y + gridSize)
        let bottomLeft = CGPoint(x: topLeft.x, y: bottomRight.y)

        let allPoints = [topRight, bottomRight, bottomLeft]
        var minDiff: CGFloat = distance(point, topLeft)
        var nearPoint = topLeft

        for corner in allPoints {
            let diff = distance(point, corner)
            if diff < minDiff {
                minDiff = diff
                nearPoint = corner
            }
        }
        return nearPoint
    }

    private func redrawPolygonAndAnchors() {
        createPolygon()
        createAnchors()
        polygonDidChange?(shapeLayer.path)
    }

    private func createPolygon() {
        guard !_points.isEmpty else {
            shapeLayer.path = UIBezierPath().cgPath
            return
        }
        let path = UIBezierPath()
        for (index, point) in _points.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        shapeLayer.path = path.cgPath
    }

    private func createAnchors() {
        anchors.forEach({ $0.removeFromSuperview() })
        for (index, point) in _points.enumerated() {
            let anchor = PolygonAnchorView(frame: CGRect(x: 0.0, y: 0.0, width: anchorSize.width * 2.5, height: anchorSize.height * 2.5))
            anchor.center = point
            anchor.tag = index
            anchor.anchorColor = anchorColor
            anchor.anchorSize = anchorSize
            anchor.dragBound = self.bounds
            // anchor.backgroundColor = .gray
            anchor.onClicked = { [unowned self] view in
                self._points.remove(at: view.tag)
                view.removeFromSuperview()
                self.redrawPolygonAndAnchors()
            }

            anchor.onDrag = { [unowned self] (view, state) in
                let nearestPoint = state == .ended && gridEnabled ? findSnapToPoint(for: view.center) : view.center
                if state == .ended {
                    anchor.center = nearestPoint
                }
                self._points[view.tag] = nearestPoint
                createPolygon()
                polygonDidChange?(shapeLayer.path)
            }

            anchors.append(anchor)
            addSubview(anchor)
        }
    }
}

private extension PolygonView {
    /*func resolvePolygon() {
        guard points.count > 2 else {
            return
        }

        points.sort(by: { $0.x < $1.x })
        var newPoints: [CGPoint] = []
//        let leftMost = points.min(by: { $0.x < $1.x })!
        let leftMost = points[0]
//        var pointOnHull = leftMost
//        var endPoint: CGPoint? = nil

        newPoints.append(leftMost)

        var currentPoint = leftMost
        repeat {
            var nextPoint = points[0]
            for i in 1..<points.count where points[i] != nextPoint {
                let cross = crossProductLength(currentPoint, points[i], nextPoint)
                if (nextPoint == currentPoint || cross > 0 ||
                    // Handle collinear points
                    (cross == 0 && distance(points[i], currentPoint) > distance(nextPoint, currentPoint))) {
                    nextPoint = points[i];
                }
            }
            newPoints.append(nextPoint)
            currentPoint = nextPoint
        } while currentPoint == newPoints[0]

        points = newPoints
    }

    func crossProductLength(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> CGFloat {
        // Get the vectors' coordinates.
        let BAx = a.x - b.x
        let BAy = a.y - b.y
        let BCx = c.x - b.x
        let BCy = c.y - b.y

        // Calculate the Z coordinate of the cross product.
        return BAx * BCy - BAy * BCx
    }*/


    /// Finds distance between given two points
    /// - Parameters:
    ///   - p1: First Point
    ///   - p2: Second Point
    /// - Returns: Distance between two points
    ///
    /// Reference: https://andreygordeev.com/2017/03/13/uibezierpath-closest-point/
    func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y)
    }
}

// MARK: - Helper to add new points
// Reference: https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
private extension PolygonView {
    // Given three collinear points p, q, r, the function checks if
    // point q lies on line segment 'pr'
    func onSegment(_ p: CGPoint, _ q: CGPoint, _ r: CGPoint) -> Bool {
        if (q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) &&
            q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y)) {
            return true
        }
        return false
    }

    // To find orientation of ordered triplet (p, q, r).
    // The function returns following values
    // 0 --> p, q and r are collinear
    // 1 --> Clockwise
    // 2 --> Counterclockwise
    func orientation(_ p: CGPoint, _ q: CGPoint, _ r: CGPoint) -> Int {
        // See https://www.geeksforgeeks.org/orientation-3-ordered-points/
        // for details of below formula.
        let val = (q.y - p.y) * (r.x - q.x) -
                  (q.x - p.x) * (r.y - q.y);

        if (val == 0) {
            return 0 // collinear
        }

        return (val > 0) ? 1 : 2 // clock or counterclock wise
    }

    // The main function that returns true if line segment 'p1q1'
    // and 'p2q2' intersect.
    func doIntersect(p1: CGPoint, q1: CGPoint, p2: CGPoint, q2: CGPoint) -> Bool {
        // Find the four orientations needed for general and
        // special cases
        let o1 = orientation(p1, q1, p2);
        let o2 = orientation(p1, q1, q2);
        let o3 = orientation(p2, q2, p1);
        let o4 = orientation(p2, q2, q1);

        // General case
        if (o1 != o2 && o3 != o4) {
            return true
        }

        // Special Cases
        // p1, q1 and p2 are collinear and p2 lies on segment p1q1
        if (o1 == 0 && onSegment(p1, p2, q1)) {
            return true
        }

        // p1, q1 and q2 are collinear and q2 lies on segment p1q1
        if (o2 == 0 && onSegment(p1, q2, q1)) {
            return true
        }

        // p2, q2 and p1 are collinear and p1 lies on segment p2q2
        if (o3 == 0 && onSegment(p2, p1, q2)) {
            return true
        }

         // p2, q2 and q1 are collinear and q1 lies on segment p2q2
        if (o4 == 0 && onSegment(p2, q1, q2)) {
            return true
        }

        return false // Doesn't fall in any of the above cases
    }
}
