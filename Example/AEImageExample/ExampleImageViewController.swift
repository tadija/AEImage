//
//  ImageViewController.swift
//  AEImageExample
//
//  Created by Marko Tadic on 9/17/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import AEImage

class ExampleImageViewController: ImageViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.displayMode = .fillHeight
        imageScrollView.infiniteScroll = .horizontal
        
        motionSettings.isEnabled = true
        motionSettings.sensitivity = 1.5
        
        image = #imageLiteral(resourceName: "demo")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
