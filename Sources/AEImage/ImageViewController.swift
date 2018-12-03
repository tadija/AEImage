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
    @IBInspectable
    open var image: UIImage? {
        didSet {
            imageScrollView.image = image
        }
    }

    /// Defines if gyro updates are enabled or not. Defaults to `false`.
    open var isMotionEnabled = false {
        didSet {
            if isMotionEnabled != oldValue {
                isMotionEnabled ? startMotionUpdates() : stopMotionUpdates()
            }
        }
    }

    /// Used in the content offset calculation to define sensitivity of gyro movement.
    public var motionSensitivity: CGFloat = 1.0

    /// Current gyroscope data (if motion is enabled).
    /// If motion is not enabled or gyroscope data is not available, the value of this property is `nil`.
    public var motionGyroData: CMGyroData? {
        return motion.gyroData
    }

    private let motion = CMMotionManager()
    private var displayLink: CADisplayLink?
    
    // MARK: Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.delegate = self
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
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if initialLayout {
            initialLayout = false
            imageScrollView.centerContentOffset()
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startMotionUpdates()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopMotionUpdates()
    }
}

// MARK: - Motion Logic

extension ImageViewController: UIScrollViewDelegate {
    /// Calling this method will only start tracking motion if `isMotionEnabled` is set to `true`.
    /// This method is called internally in some `UIScrollViewDelegate` methods and when the app becomes active.
    @objc
    open func startMotionUpdates() {
        guard isMotionEnabled, motion.isGyroAvailable, !motion.isGyroActive else {
            return
        }
        motion.startGyroUpdates()
        displayLink = CADisplayLink(target: self, selector: #selector(updateWithMotionGyroData))
        displayLink?.add(to: .main, forMode: .common)
    }

    /// This method is called internally in some `UIScrollViewDelegate` methods and when the app resigns being active.
    @objc
    open func stopMotionUpdates() {
        motion.stopGyroUpdates()
        displayLink?.invalidate()
        displayLink = nil
    }

    /// Main logic for updating UI based on the current gyroscope data. Override if needed.
    @objc
    open func updateWithMotionGyroData() {
        guard
            let gyroData = motionGyroData,
            let offset = calculatedContentOffset(with: gyroData)
            else {
                return
        }
        let options: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut]
        UIView.animate(withDuration: 0.3, delay: 0.0, options: options, animations: { [weak self] () in
            self?.imageScrollView.setContentOffset(offset, animated: false)
            }, completion: nil)
    }

    // MARK: UIScrollViewDelegate

    /// View used for zooming must be `stackView`.
    /// Be sure to keep this logic in case of custom `UIScrollViewDelegate` implementation.
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageScrollView.stackView
    }

    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        stopMotionUpdates()
    }

    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        startMotionUpdates()
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopMotionUpdates()
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            startMotionUpdates()
        }
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startMotionUpdates()
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
