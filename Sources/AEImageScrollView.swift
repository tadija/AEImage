//
// AEImageScrollView.swift
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

/**
 This is base class which consists from `UIImageView` inside `UIScrollView`.
 It will update current zoom scale on `imageView` whenever its `frame` changes.
 
 It may be used directly from code or storyboard with auto layout,
 just set its `image` property and it will do the rest.
 */
open class AEImageScrollView: UIScrollView, UIScrollViewDelegate {
    
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
    
    // MARK: - Outlets
    
    private let stackView = UIStackView()
    
    /// Image view which displays the image.
    public let imageView = UIImageView()
    
    private let leftImageView = UIImageView()
    private let rightImageView = UIImageView()
    
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
            if displayMode != oldValue {
                configureZoomScales()
            }
        }
    }
    
    /// Whenever frame property is changed zoom scales are gonna be re-calculated.
    override open var frame: CGRect {
        willSet {
            if !frame.size.equalTo(newValue.size) {
                prepareToResize()
            }
        }
        didSet {
            if !frame.size.equalTo(oldValue.size) {
                configureZoomScales()
                recoverFromResizing()
            }
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
    
    // MARK: - UIScrollViewDelegate
    
    /// View used for zooming is `imageView`, be sure to keep that logic.
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return stackView
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating {
            updateContentOffsetRelative()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateContentOffsetRelative()
    }
    
    private func updateContentOffsetRelative() {
        let xOffset = contentOffset.x
        let width = contentSize.width / 3
        
        let maxOffset = width * 2
        if xOffset > maxOffset {
            let diff = xOffset - maxOffset
            let newOffset = CGPoint(x: width + diff, y: 0)
            UIView.performWithoutAnimation {
                setContentOffset(newOffset, animated: false)
            }
        }
        
        let minOffset = width - bounds.width
        if xOffset < minOffset {
            let diff = minOffset - xOffset
            let newOffset = CGPoint(x: width + minOffset - diff, y: 0)
            UIView.performWithoutAnimation {
                setContentOffset(newOffset, animated: false)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func configureSelf() {
        backgroundColor = UIColor.black
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        delegate = self
        
        stackView.addArrangedSubview(leftImageView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(rightImageView)
        
        addSubview(stackView)
    }
    
    private func updateUI() {
        resetImage()
        resetZoomScales()
        
        configureImage()
        configureZoomScales()
        
        centerContentOffset()
    }
    
    private func resetImage() {
        contentSize = CGSize.zero
        imageView.image = nil
        leftImageView.image = nil
        rightImageView.image = nil
    }
    
    private func resetZoomScales() {
        minimumZoomScale = 1.0
        maximumZoomScale = 1.0
        zoomScale = 1.0
    }
    
    private func configureImage() {
        guard let image = image else { return }
        imageView.image = image
        leftImageView.image = image
        rightImageView.image = image
        
        let size = CGSize(width: image.size.width * 3, height: image.size.height)
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        stackView.frame = frame
        
        contentSize = size
    }
    
    private func configureZoomScales() {
        guard let image = image else { return }
        
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
    
    // MARK: - Helpers
    
    private var pointToCenterAfterResize: CGPoint?
    
    private func prepareToResize() {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        pointToCenterAfterResize = convert(boundsCenter, to: imageView)
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
    
}
