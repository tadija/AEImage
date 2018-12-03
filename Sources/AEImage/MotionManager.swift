/**
 *  https://github.com/tadija/AEImage
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import CoreMotion

/// Forwards gyro data.
public protocol MotionDelegate: class {
    /// Every gyro update is forwared to `delegate` through this method.
    func didUpdate(gyroData: CMGyroData)
}

/**
    Simple subclass of `CMMotionManager` which sends gyro updates
    to its `delegate` and can be toggled ON and OFF.
*/
open class MotionManager: CMMotionManager {
    
    // MARK: - Properties
    
    /// Set delegate to receive gyro data.
    open weak var delegate: MotionDelegate?
    
    /// Defines if gyro updates are enabled or not. Defaults to `false`.
    open var isEnabled = false {
        didSet {
            if isEnabled != oldValue {
                isEnabled ? startTrackingMotion() : stopTrackingMotion()
            }
        }
    }
    
    // MARK: - Helpers

    private let operationQueue = OperationQueue()
    
    private func startTrackingMotion() {
        guard isGyroAvailable, !isGyroActive else {
            return
        }
        startGyroUpdates(to: operationQueue) { [weak self] gyroData, _ in
            if let gyroData = gyroData {
                DispatchQueue.main.async {
                    self?.delegate?.didUpdate(gyroData: gyroData)
                }
            }
        }
    }
    
    private func stopTrackingMotion() {
        stopGyroUpdates()
    }
    
}
