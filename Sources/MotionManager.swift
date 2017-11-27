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
    
    // MARK: - API
    
    /// Toggles gyro updates ON and OFF.
    open func toggle() {
        isEnabled = !isEnabled
    }
    
    // MARK: - Helpers
    
    private func startTrackingMotion() {
        guard isGyroAvailable, !isGyroActive, let queue = OperationQueue.current else {
            return
        }
        startGyroUpdates(to: queue, withHandler: { [weak self] (gyroData, NSError) in
            if let gyroData = gyroData {
                self?.delegate?.didUpdate(gyroData: gyroData)
            }
        })
    }
    
    private func stopTrackingMotion() {
        stopGyroUpdates()
    }
    
}
