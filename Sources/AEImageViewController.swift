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

/**
    Minimalistic view controller which just adds `AEImageScrollView` 
    to its view hierarchy, and has `image` property to set its content.
    It will also center content offset on the first call of `viewDidLayoutSubviews`.
 
    It may be used as is from code or storyboard, 
    but it's meant to be subclassed for custom funcionality, handling gyro motion data etc.
*/
open class AEImageViewController: UIViewController {
    
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
    
    /// Instance of `AEMotion`, become its `delegate` for getting gyro updates.
    open let motion = AEMotion()
    
    private var initialLayout = true
    
    // MARK: - Lifecycle

    /// Image is set on `imageScrollView` which is then added as a subview to this view controller's view.
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        configureImageScrollView()
    }
    
    private func configureImageScrollView() {
        imageScrollView.image = image
        imageScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageScrollView.frame = view.frame
        view.insertSubview(imageScrollView, at: 0)
    }

    /// `imageScrollView.centerContentOffset()` will be called here, but only the first time (initial layout).
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if initialLayout {
            initialLayout = false
            imageScrollView.centerContentOffset()
        }
    }

}
