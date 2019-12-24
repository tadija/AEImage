/**
 *  https://github.com/tadija/AEImage
 *  Copyright © 2016-2019 Marko Tadić
 *  Licensed under the MIT license
 */

import UIKit
import AEImage

class ExampleImageViewController: ImageMotionViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.displayMode = .fillHeight
        imageScrollView.infiniteScroll = .horizontal

        isMotionEnabled = true
        motionSensitivity = 1.5

        image = #imageLiteral(resourceName: "demo")
    }

    @IBAction func didRecognizeDoubleTapGesture(_ sender: UITapGestureRecognizer) {
        let imageScrollView = self.imageScrollView

        imageScrollView.isInfiniteScrollEnabled = false

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [
                .allowUserInteraction, .beginFromCurrentState, .curveEaseOut,
            ],
            animations: {
                let minScale = imageScrollView.minimumZoomScale
                if imageScrollView.zoomScale > minScale {
                    imageScrollView.setZoomScale(minScale, animated: false)
                } else {
                    let point = sender.location(in: imageScrollView.stackView)
                    let rect = CGRect(origin: point, size: .zero)
                    imageScrollView.zoom(to: rect, animated: false)
                }
        }) { _ in
            imageScrollView.isInfiniteScrollEnabled = true
        }
    }
}
