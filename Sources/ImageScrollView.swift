import UIKit
import CoreMotion

/**
    This is base class which consists from `UIStackView` (contanining `UIImageView`) inside of a `UIScrollView`.
    It will automatically update to correct zoom scale (depending on `displayMode`) whenever its `frame` changes.

    It may be used directly from code or from storyboard with auto layout,
    just set its `image` and `displayMode` properties and it will do the rest.
    
    It will automatically receive gyro data and update its content offset based on `motionDelegate` configuration.
    It's also possible to enable `infiniteScroll` effect by property (useful for 360 panorama images or similar).
*/
open class ImageScrollView: UIScrollView, UIScrollViewDelegate, MotionDelegate {
    
    // MARK: - Types
    
    /// Modes for calculating zoom scale.
    public enum DisplayMode {
        /// switches between `fit` and `fill` depending of the image ratio.
        case automatic
        /// Fits entire image.
        case fit
        /// Fills entire `imageView`.
        case fill
        /// Fills width of the `imageView`.
        case fillWidth
        /// Fills height of the `imageView`.
        case fillHeight
    }
    
    /// Modes for infinite scroll effect.
    public enum InfiniteScroll {
        /// Disabled infinite scroll effect.
        case disabled
        /// Horizontal infinite scroll effect.
        case horizontal
        /// Vertical infinite scroll effect.
        case vertical
    }
    
    // MARK: - Outlets
    
    /// Stack view is placeholder for imageView.
    public let stackView = UIStackView()
    
    /// Image view which displays the image.
    public let imageView = UIImageView()
    
    /// Duplicated image views for faking `infiniteScroll` effect.
    private let leadingImageView = UIImageView()
    private let trailingImageView = UIImageView()
    
    // MARK: - Properties
    
    /// Image to be displayed. UI will be updated whenever you set this property.
    @IBInspectable open var image: UIImage? {
        didSet {
            updateUI()
        }
    }
    
    /// Mode to be used when calculating zoom scale. Default value is `.automatic`.
    open var displayMode: DisplayMode = .automatic {
        didSet {
            if displayMode != oldValue, let image = image {
                updateZoomScales(with: image)
            }
        }
    }
    
    /// Infinite scroll effect (think of 360 panorama). Defaults to `false`.
    open var infiniteScroll: InfiniteScroll = .disabled {
        didSet {
            if infiniteScroll != oldValue {
                resetStackView()
            }
        }
    }

    /// Flag that determines if vertical scrolling of image is enabled. Defaults to true.
    open var isVerticalScrollEnabled: Bool = true

    /// Flag that determines if horizontal scrolling of image is enabled. Defaults to true.
    open var isHorizontalScrollEnabled: Bool = true
    
    /// Gyro motion delegate
    public weak var motionScrollDelegate: MotionScrollDelegate?
    
    /// Gyro motion manager
    private let motionManager = MotionManager()
    
    // MARK: - Override
    
    /// Whenever frame property is changed zoom scales are gonna be re-calculated.
    override open var frame: CGRect {
        willSet {
            if !frame.size.equalTo(newValue.size) {
                prepareToResize()
            }
        }
        didSet {
            if !frame.size.equalTo(oldValue.size), let image = image {
                updateZoomScales(with: image)
                recoverFromResizing()
            }
        }
    }

    /// Whenever bounds are changed zoom scales are gonna be re-calculated.
    override open var bounds: CGRect {
        willSet {
            if !bounds.size.equalTo(newValue.size) {
                prepareToResize()
            }
        }
        didSet {
            if !bounds.size.equalTo(oldValue.size), let image = image {
                updateZoomScales(with: image)
                recoverFromResizing()
            }
        }
    }
    
    // MARK: Helpers
    
    private var pointToCenterAfterResize: CGPoint?
    
    private func prepareToResize() {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        pointToCenterAfterResize = convert(boundsCenter, to: stackView)
    }
    
    private func recoverFromResizing() {
        if let pointToCenter = pointToCenterAfterResize {
            // calculate min and max content offset
            let minimumContentOffset = CGPoint.zero
            let maxOffsetX = contentSize.width - bounds.size.width
            let maxOffsetY = contentSize.height - bounds.size.height
            let maximumContentOffset = CGPoint(x: maxOffsetX, y: maxOffsetY)
            
            // convert our desired center point back to our own coordinate space
            let boundsCenter = convert(pointToCenter, from: stackView)
            
            // calculate the content offset that would yield that center point
            let offsetX = boundsCenter.x - bounds.size.width / 2.0
            let offsetY = boundsCenter.y - bounds.size.height / 2.0
            var offset = CGPoint(x: offsetX, y: offsetY)
            
            // calculate offset, adjusted to be within the allowable range
            var realMaxOffset = min(maximumContentOffset.x, offset.x)
            offset.x = max(minimumContentOffset.x, realMaxOffset)
            
            realMaxOffset = min(maximumContentOffset.y, offset.y)
            offset.y = max(minimumContentOffset.y, realMaxOffset)
            
            // restore offset
            contentOffset = offset
        }
    }
    
    // MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    private func commonInit() {
        configureSelf()
        updateUI()
    }
    
    // MARK: Helpers
    
    private func configureSelf() {
        configureScrollView()
        configureStackView()
    }
    
    private func configureScrollView() {
        backgroundColor = UIColor.black
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        
        delegate = self
        motionManager.delegate = self
    }
    
    private func configureStackView() {
        resetStackView()
        addSubview(stackView)
    }
    
    private func resetStackView() {
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
        switch infiniteScroll {
        case .disabled:
            stackView.addArrangedSubview(imageView)
        case .horizontal:
            stackView.axis = .horizontal
            stackView.addArrangedSubview(leadingImageView)
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(trailingImageView)
        case .vertical:
            stackView.axis = .vertical
            stackView.addArrangedSubview(leadingImageView)
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(trailingImageView)
        }
    }
    
    private func updateUI() {
        resetImage()
        resetZoomScales()
        
        if let image = image {
            updateImage(image)
            updateContentSize(with: image)
            updateZoomScales(with: image)
        }
        
        centerContentOffset()
    }
    
    private func resetImage() {
        contentSize = CGSize.zero
        imageView.image = nil
        leadingImageView.image = nil
        trailingImageView.image = nil
    }
    
    private func resetZoomScales() {
        minimumZoomScale = 1.0
        maximumZoomScale = 1.0
        zoomScale = 1.0
    }
    
    private func updateImage(_ image: UIImage) {
        imageView.image = image
        if infiniteScroll != .disabled {
            leadingImageView.image = image
            trailingImageView.image = image
        }
    }
    
    private func updateContentSize(with image: UIImage) {
        let size: CGSize
        switch infiniteScroll {
        case .disabled:
            size = CGSize(width: image.size.width, height: image.size.height)
        case .horizontal:
            size = CGSize(width: image.size.width * 3, height: image.size.height)
        case .vertical:
            size = CGSize(width: image.size.width, height: image.size.height * 3)
        }
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        stackView.frame = frame
        contentSize = size
    }
    
    private func updateZoomScales(with image: UIImage) {
        // get scales needed to perfectly fit the image
        let xScale = bounds.size.width / image.size.width
        let yScale = bounds.size.height / image.size.height
        
        let scale: CGFloat
        
        // calculate minimum zoom scale
        switch displayMode {
        case .automatic:
            let automaticZoomToFill = abs(xScale - yScale) < 0.15
            scale = automaticZoomToFill ? max(xScale, yScale) : min(xScale, yScale)
        case .fit:
            scale = min(xScale, yScale)
        case .fill:
            scale = max(xScale, yScale)
        case .fillWidth:
            scale = xScale
        case .fillHeight:
            scale = yScale
        }
        
        // set minimum and maximum scale for scrollView
        minimumZoomScale = scale
        maximumZoomScale = minimumZoomScale * 3.0
        
        zoomScale = minimumZoomScale

        if !isVerticalScrollEnabled {
            disableVerticalScroll()
        }

        if !isHorizontalScrollEnabled {
            disableHorizontalScroll()
        }
    }

    private func disableVerticalScroll() {
        let newContentSize = CGSize(width: contentSize.width, height: frame.size.height)
        contentSize = newContentSize
    }

    private func disableHorizontalScroll() {
        let newContentSize = CGSize(width: frame.size.width, height: contentSize.height)
        contentSize = newContentSize
    }
    
    // MARK: - Lifecycle
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        fakeContentOffsetIfNeeded()
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        addObservers()
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        removeObservers()
    }
    
    // MARK: Helpers
    
    private func fakeContentOffsetIfNeeded() {
        var newOffset: CGPoint?
        let xOffset = contentOffset.x
        let yOffset = contentOffset.y
        let width = contentSize.width / 3
        let height = contentSize.height / 3
        
        switch infiniteScroll {
        case .disabled:
            break
        case .horizontal:
            let maxOffset = width * 2
            if xOffset > maxOffset {
                let diff = xOffset - maxOffset
                let newX = width + diff
                newOffset = CGPoint(x: newX, y: yOffset)
            }
            let minOffset = width - bounds.width
            if xOffset < minOffset {
                let diff = minOffset - xOffset
                let newX = width + minOffset - diff
                newOffset = CGPoint(x: newX, y: yOffset)
            }
        case .vertical:
            let maxOffset = height * 2
            if yOffset > maxOffset {
                let diff = yOffset - maxOffset
                let newY = height + diff
                newOffset = CGPoint(x: xOffset, y: newY)
            }
            let minOffset = height - bounds.height
            if yOffset < minOffset {
                let diff = minOffset - yOffset
                let newY = height + minOffset - diff
                newOffset = CGPoint(x: xOffset, y: newY)
            }
        }
        
        if let newOffset = newOffset {
            UIView.performWithoutAnimation {
                contentOffset = newOffset
            }
        }
    }
    
    private func addObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(enableMotion), name: .UIApplicationDidBecomeActive, object: nil)
        center.addObserver(self, selector: #selector(disableMotion), name: .UIApplicationWillResignActive, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - API
    
    /// This will center content offset horizontally and verticaly.
    /// It's also called whenever `image` property is set.
    open func centerContentOffset() {
        let centerX = (stackView.frame.size.width - bounds.size.width) / 2.0
        let centerY = (stackView.frame.size.height - bounds.size.height) / 2.0
        let offset = CGPoint(x: centerX, y: centerY)
        setContentOffset(offset, animated: false)
    }
    
    /// Calling this method will only enable motion if it's enabled in `motionSettings` returned by `motionDelegate`.
    /// This method is called internally in some of `UIScrollViewDelegate` methods and when app becomes active.
    @objc public func enableMotion() {
        if motionScrollDelegate?.motionSettings.isEnabled ?? false {
            motionManager.isEnabled = true
        }
    }
    
    /// Calling this method will only disble motion if it's enabled in `motionSettings` returned by `motionDelegate`.
    /// This method is called internally in some of `UIScrollViewDelegate` methods and when app resigns being active.
    @objc public func disableMotion() {
        if motionScrollDelegate?.motionSettings.isEnabled ?? false {
            motionManager.isEnabled = false
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    /// View used for zooming must be `stackView`.
    /// Be sure to keep this logic in case of custom `UIScrollViewDelegate` implementation.
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return stackView
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        disableMotion()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        enableMotion()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        disableMotion()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            enableMotion()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        enableMotion()
    }
    
    // MARK: - MotionDelegate
    
    /// Gyro motion will be reported, here then based on calculation from `motionDelegate` content offset will update.
    public func didUpdate(gyroData: CMGyroData) {
        guard let offset = motionScrollDelegate?.calculatedContentOffset(with: gyroData) else {
            return
        }
        let options: UIViewAnimationOptions = [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut]
        UIView.animate(withDuration: 0.3, delay: 0.0, options: options, animations: { () in
            self.setContentOffset(offset, animated: false)
        }, completion: nil)
    }
    
}
