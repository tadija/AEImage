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
    
    /// Image view which displays the image.
    public let imageView = UIImageView()
    
    // MARK: - Properties
    
    /// Image to be displayed. UI will be updated whenever you set this property.
    @IBInspectable open var image: UIImage? {
        didSet {
            configureImage()
        }
    }
    
    /// Mode to be used when calculating zoom scale. Default value is `.automatic`.
    open var displayMode: DisplayMode = .automatic {
        didSet {
            configureZoomScaleForCurrentBounds()
        }
    }
    
    /// Whenever frame property is changed zoom scales are gonna be re-calculated.
    override open var frame: CGRect {
        didSet {
            configureZoomScaleForCurrentBounds()
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
        configureImage()
    }
    
    // MARK: - UIScrollViewDelegate
    
    /// View used for zooming is `imageView`, be sure to keep that logic.
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: - API
    
    /// This will center content offset horizontally and verticaly. 
    /// It's also called whenever `image` property is set.
    open func centerContentOffset() {
        let centerX = (imageView.frame.size.width - bounds.size.width) / 2.0
        let centerY = (imageView.frame.size.height - bounds.size.height) / 2.0
        let offset = CGPoint(x: centerX, y: centerY)
        setContentOffset(offset, animated: false)
    }
    
    // MARK: - Helpers
    
    private func configureSelf() {
        backgroundColor = UIColor.black
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        delegate = self
        
        addSubview(imageView)
    }
    
    private func configureImage() {
        resetImage()
        
        guard let image = image else { return }
        
        zoomScale = 1.0
        contentSize = image.size
        
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        centerContentOffset()
    }
    
    private func resetImage() {
        contentSize = CGSize.zero
        imageView.image = nil
    }
    
    private func configureZoomScaleForCurrentBounds() {
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
    
}
