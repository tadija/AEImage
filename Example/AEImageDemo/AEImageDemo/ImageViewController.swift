//
//  ImageViewController.swift
//  AEImageDemo
//
//  Created by Marko Tadic on 9/17/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import AEImage

class ImageViewController: AEImageViewController {
    
    // MARK: AEImageMotionDelegate
    
    override var motionSettings: MotionSettings {
        var settings = MotionSettings()
        settings.isEnabled = true
        settings.sensitivity = 1.5
        return settings
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.infiniteScroll = .horizontal
        image = UIImage(named: "demo1")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
