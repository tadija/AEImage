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

open class AEImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    // MARK: - Types
    
    public enum DisplayMode: Int {
        case automatic, fit, fill, fillWidth, fillHeight
    }
    
    // MARK: - Outlets
    
    public let imageView = UIImageView()
    
    // MARK: - Properties
    
    @IBInspectable open var image: UIImage? {
        didSet {
            configureImage()
        }
    }
    
    open var displayMode: DisplayMode = .automatic {
        didSet {
            configureZoomScaleForCurrentBounds()
        }
    }
    
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
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: - API
    
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
    
    private var automaticZoomToFill: Bool = false
    
    private func configureZoomScaleForCurrentBounds() {
        guard let image = image else { return }
        
        // reset automaticZoomToFill
        automaticZoomToFill = false
        
        // get scales needed to perfectly fit the image
        let xScale = bounds.size.width / image.size.width
        let yScale = bounds.size.height / image.size.height
        
        var scale: CGFloat
        
        // calculate minimum zoom scale
        switch displayMode {
        case .automatic:
            automaticZoomToFill = abs(xScale - yScale) < 0.15
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
