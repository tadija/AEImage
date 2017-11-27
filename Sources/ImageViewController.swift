import UIKit
import CoreMotion

/**
    Minimalistic view controller which just adds `ImageScrollView`
    to its view hierarchy, and has `image` property to set its content.
    It will also center content offset on the first call of `viewDidLayoutSubviews`.

    It may be used out of the box from code or storyboard, but it might also be subclassed for custom functionality. 
    It provides default implementation for `MotionScrollDelegate` which can be overriden if needed.
*/
open class ImageViewController: UIViewController, MotionScrollDelegate {
    
    // MARK: - Outlets
    
    /// Zoomable image view which displays the image.
    public let imageScrollView = ImageScrollView()
    
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
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imageScrollView.enableMotion()
    }
    
    /// `imageScrollView.centerContentOffset()` will be called here, but only the first time (initial layout).
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if initialLayout {
            initialLayout = false
            imageScrollView.centerContentOffset()
        }
    }
    
    // MARK: Helpers
    
    private var initialLayout = true
    
    private func configureImageScrollView() {
        imageScrollView.image = image
        imageScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageScrollView.frame = view.frame
        imageScrollView.motionScrollDelegate = self
        view.insertSubview(imageScrollView, at: 0)
    }
    
    // MARK: - MotionScrollDelegate
    
    open var motionSettings = MotionSettings()
    
    open func calculatedContentOffset(with gyroData: CMGyroData) -> CGPoint? {
        let settings = motionSettings
        let rotationRate = self.rotationRate(with: gyroData)
        
        guard abs(rotationRate) >= settings.threshold else {
            return nil
        }

        let motionRate = motionFactor * settings.sensitivity
        var offsetX = imageScrollView.contentOffset.x - rotationRate * motionRate
        offsetX = constrainedOffsetX(with: offsetX)
        
        let offset = CGPoint(x: offsetX, y: imageScrollView.contentOffset.y)
        return offset
    }
    
    // MARK: Helpers
    
    private func rotationRate(with gyroData: CMGyroData) -> CGFloat {
        let orientation = UIDevice.current.orientation
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
