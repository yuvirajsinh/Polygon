//
//  ViewController.swift
//  Polygon
//
//  Created by Yuvrajsinh Jadeja on 01/03/23.
//

import UIKit

class ViewController: UIViewController {
    private let polygonView: PolygonView = PolygonView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addCameraDetectionView()
    }

    private func addCameraDetectionView() {
        polygonView.backgroundColor = .orange.withAlphaComponent(0.5)
        polygonView.frame = CGRect(x: 50.0, y: 50.0, width: 300.0, height: 300.0)
        polygonView.borderColor = .brown.withAlphaComponent(0.8)
        polygonView.fillColor = .green.withAlphaComponent(0.3)
        polygonView.anchorColor = .brown
        polygonView.lineWidth = 1.0
        polygonView.anchorSize = CGSize(width: 12.0, height: 12.0)
        polygonView.maxPoints = 5
        self.view.addSubview(polygonView)
    }
}

