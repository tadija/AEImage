//
// AEImageViewController.swift
//
// Copyright (c) 2016 Marko Tadić <tadija@me.com> http://tadija.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import CoreMotion

/**
    Minimalistic view controller which just adds `AEImageScrollView`
    to its view hierarchy, and has `image` property to set its content.
    It will also center content offset on the first call of `viewDidLayoutSubviews`.

    It may be used out of the box from code or storyboard,
    but it might also be subclassed for custom funcionality or handling gyro motion data etc.
*/
open class AEImageViewController: UIViewController, AEImageMotionDelegate {
    
    public typealias MotionSettings = AEImageScrollView.MotionSettings
    
    // MARK: - Outlets
    
    /// Zoomable image view which displays the image.
    public let imageScrollView = AEImageScrollView()
    
    // MARK: - Properties
    
    /// Facade to `image` property of the `imageScrollView`.
    @IBInspectable open var image: UIImage? {
        didSet {
            imageScrollView.image = image
        }
    }
    
    // MARK: - Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        configureImageScrollView()
    }
    
    private func configureImageScrollView() {
        imageScrollView.image = image
        imageScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageScrollView.frame = view.frame
        imageScrollView.motionDelegate = self
        view.insertSubview(imageScrollView, at: 0)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imageScrollView.enableMotion()
    }
    
    private var initialLayout = true
    
    /// `imageScrollView.centerContentOffset()` will be called here, but only the first time (initial layout).
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if initialLayout {
            initialLayout = false
            imageScrollView.centerContentOffset()
        }
    }
    
    // MARK: - AEImageMotionDelegate
    
    open var motionSettings: MotionSettings {
        return MotionSettings()
    }
    
    open func contentOffset(with gyroData: CMGyroData) -> CGPoint? {
        let settings = motionSettings
        let orientation = UIApplication.shared.statusBarOrientation
        let rotationRate: CGFloat
        
        if orientation.isLandscape {
            if orientation == .landscapeLeft {
                rotationRate = CGFloat(-gyroData.rotationRate.x)
            } else {
                rotationRate = CGFloat(gyroData.rotationRate.x)
            }
        } else {
            rotationRate = CGFloat(gyroData.rotationRate.y)
        }
        
        if abs(rotationRate) >= settings.minimumThreshold {
            let maxOffsetX = imageScrollView.contentSize.width - imageScrollView.bounds.size.width
            let motionRate = imageScrollView.contentSize.width / imageScrollView.bounds.size.width * settings.rotationFactor
            var offsetX = imageScrollView.contentOffset.x - rotationRate * motionRate
            
            if offsetX > maxOffsetX {
                offsetX = maxOffsetX
            } else if offsetX < 0.0 {
                offsetX = 0.0
            }
            
            let offset = CGPoint(x: offsetX, y: imageScrollView.contentOffset.y)
            return offset
        } else {
            return nil
        }
    }
    
}
