/**
 *  https://github.com/tadija/AEImage
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit
import CoreMotion

/**
    Minimalistic view controller which just adds `ImageScrollView`
    to its view hierarchy, and has `image` property to set its content.
    It will also center content offset on the first call of `viewDidLayoutSubviews`.

    It may be used out of the box from code or storyboard, but it might also be subclassed for custom functionality. 
    It provides default implementation for handling gyro updates which can be overriden if needed.
*/
open class ImageViewController: UIViewController {
    // MARK: Outlets
    
    /// Zoomable image view which displays the image.
    public let imageScrollView = ImageScrollView()
    
    // MARK: Properties
    
    /// Facade to `image` property of the `imageScrollView`.
    @IBInspectable open var image: UIImage? {
        didSet {
            imageScrollView.image = image
        }
    }

    /// Used in the content offset calculation to define sensitivity of gyro movement if `isMotionEnabled` is `true`.
    public var motionSensitivity: CGFloat = 1.0

    private var displayLink: CADisplayLink?
    
    // MARK: Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        imageScrollView.image = image
        imageScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageScrollView.frame = view.frame
        view.insertSubview(imageScrollView, at: 0)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addObservers()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeObservers()
    }

    private var initialLayout = true

    /// `imageScrollView.centerContentOffset()` will be called here, but only the first time (for initial layout).
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if initialLayout {
            initialLayout = false
            imageScrollView.centerContentOffset()
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startMotionUpdates()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopMotionUpdates()
    }
}

// MARK: - Motion Logic

extension ImageViewController {
    @objc
    open func startMotionUpdates() {
        imageScrollView.startTrackingMotion()
        displayLink = CADisplayLink(target: self, selector: #selector(updateWithMotionGyroData))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc
    open func stopMotionUpdates() {
        imageScrollView.stopTrackingMotion()
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc
    open func updateWithMotionGyroData() {
        guard
            let gyroData = imageScrollView.motionGyroData,
            let offset = calculatedContentOffset(with: gyroData)
            else {
                return
        }
        let options: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut]
        UIView.animate(withDuration: 0.3, delay: 0.0, options: options, animations: { [weak self] () in
            self?.imageScrollView.setContentOffset(offset, animated: false)
            }, completion: nil)
    }
    
    // MARK: Helpers

    private func addObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(startMotionUpdates),
                           name: UIApplication.didBecomeActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(stopMotionUpdates),
                           name: UIApplication.willResignActiveNotification, object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    private func calculatedContentOffset(with gyroData: CMGyroData) -> CGPoint? {
        let rotationRate = self.rotationRate(with: gyroData)
        guard abs(rotationRate) >= 0.1 else {
            return nil
        }

        let motionRate = motionFactor * motionSensitivity
        var offsetX = imageScrollView.contentOffset.x - rotationRate * motionRate
        offsetX = constrainedOffsetX(with: offsetX)

        let offset = CGPoint(x: offsetX, y: imageScrollView.contentOffset.y)
        return offset
    }
    
    private func rotationRate(with gyroData: CMGyroData) -> CGFloat {
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
        
        return rotationRate
    }
    
    private var motionFactor: CGFloat {
        let boundsSize = imageScrollView.bounds.size
        let contentSize = imageScrollView.contentSize
        
        let motionFactor: CGFloat
        if imageScrollView.infiniteScroll == .disabled {
            motionFactor = contentSize.width / boundsSize.width
        } else {
            motionFactor = (contentSize.width / 3) / boundsSize.width
        }
        
        return motionFactor
    }
    
    private func constrainedOffsetX(with offsetX: CGFloat) -> CGFloat {
        let minOffsetX: CGFloat = 0.0
        let maxOffsetX = imageScrollView.contentSize.width - imageScrollView.bounds.size.width
        
        if offsetX > maxOffsetX {
            return maxOffsetX
        } else if offsetX < minOffsetX {
            return minOffsetX
        } else {
            return offsetX
        }
    }
}
