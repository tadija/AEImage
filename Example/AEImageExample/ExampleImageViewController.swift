/**
 *  https://github.com/tadija/AEImage
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit
import AEImage

class ExampleImageViewController: ImageViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.displayMode = .fillHeight
        imageScrollView.infiniteScroll = .horizontal

        motionSettings.isEnabled = true
        motionSettings.sensitivity = 1.5

        image = #imageLiteral(resourceName: "demo")
    }
}
