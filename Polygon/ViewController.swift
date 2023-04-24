//
//  ViewController.swift
//  Polygon
//
//  Created by Yuvrajsinh Jadeja on 01/03/23.
//

import UIKit

class ViewController: UIViewController {
    private let polygonView: PolygonView = PolygonView()
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addCameraDetectionView()
    }

    private func addCameraDetectionView() {
        let zoneView = DetectionZoneView(frame: imageView.frame)
        zoneView.overlayColor = .black.withAlphaComponent(0.5)
        zoneView.borderColor = .white
        zoneView.anchorColor = .white
        zoneView.lineWidth = 1.0
        zoneView.anchorSize = CGSize(width: 12.0, height: 12.0)
        zoneView.maxPoints = 8

        zoneView.autoresizingMask = [.flexibleWidth]
        self.view.addSubview(zoneView)
    }
}

