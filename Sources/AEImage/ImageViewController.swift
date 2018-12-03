/**
 *  https://github.com/tadija/AEImage
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit

/**
    Minimalistic view controller which just adds `ImageScrollView`
    to its view hierarchy, and has `image` property to set its content.
    It will also center content offset on the first call of `viewDidLayoutSubviews`.

    It may be used out of the box from code or storyboard, but it might also be subclassed for custom functionality. 
*/
open class ImageViewController: UIViewController {

    /// Zoomable image view which displays the image.
    public let imageScrollView = ImageScrollView()
    
    /// Facade to `image` property of the `imageScrollView`.
    @IBInspectable
    public var image: UIImage? {
        didSet {
            imageScrollView.image = image
        }
    }
    
    // MARK: Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.image = image
        imageScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageScrollView.frame = view.frame
        view.insertSubview(imageScrollView, at: 0)
    }

    /// `imageScrollView.centerContentOffset()` will be called here, but only the first time (for initial layout).
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if initialLayout {
            initialLayout = false
            imageScrollView.centerContentOffset()
        }
    }

    private var initialLayout = true
}
