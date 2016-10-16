//
//  ImageViewController.swift
//  AEImageDemo
//
//  Created by Marko Tadic on 9/17/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import AEImage

class ImageViewController: AEImageViewController, AEMotionDelegate, UIScrollViewDelegate {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        image = UIImage(named: "demo1")
        
        imageScrollView.delegate = self
        motion.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMotionSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        motion.isEnabled = true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageScrollView.viewForZooming(in: scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        motion.isEnabled = false
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateMotionSettings()
        motion.isEnabled = true
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        motion.isEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        motion.isEnabled = true
    }
    
    // MARK: - Motion Logic
    
    var isLandscape: Bool {
        let orientation = UIApplication.shared.statusBarOrientation
        let landscape = UIInterfaceOrientationIsLandscape(orientation)
        return landscape
    }
    
    let minimumRotationThreshold = 0.1
    var rotationFactor: Double { return isLandscape ? 1.5 : 1.0 }
    var minimumXOffset = 0.0
    var maximumXOffset: Double!
    var motionRate: Double!
    
    func updateMotionSettings() {
        maximumXOffset = Double(imageScrollView.contentSize.width - imageScrollView.bounds.size.width)
        motionRate = Double(imageScrollView.contentSize.width / imageScrollView.bounds.size.width) * rotationFactor
    }
    
    // MARK: - AEMotionDelegate
    
    func didUpdate(gyroData: CMGyroData) {
        let rotationRate = isLandscape ? -gyroData.rotationRate.x : gyroData.rotationRate.y
        
        if abs(rotationRate) >= minimumRotationThreshold {
            let currentOffsetX = Double(imageScrollView.contentOffset.x)
            let currentOffsetY = Double(imageScrollView.contentOffset.y)
            
            var newOffsetX = currentOffsetX - rotationRate * motionRate
            if newOffsetX > maximumXOffset {
                newOffsetX = maximumXOffset
            } else if newOffsetX < minimumXOffset {
                newOffsetX = minimumXOffset
            }
            
            let offset = CGPoint(x: newOffsetX, y: currentOffsetY)
            
            let options: UIViewAnimationOptions = [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut]
            UIView.animate(withDuration: 0.3, delay: 0.0, options: options, animations: { () in
                self.imageScrollView.setContentOffset(offset, animated: false)
            }, completion: nil)
        }
    }
    
}
