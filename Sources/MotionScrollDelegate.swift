import CoreMotion

/// Conformer to this protocol should provide gyro motion settings and calculate content offset based on gyro data.
public protocol MotionScrollDelegate: class {
    /// Gyro motion settings
    var motionSettings: MotionSettings { get set }
    /// Calculated content offset to which `ImageScrollView` should be moved (based on gyro data).
    func calculatedContentOffset(with gyroData: CMGyroData) -> CGPoint?
}

/// Gyro motion settings
public struct MotionSettings {
    /// Gyro motion is tracked only if `isEnabled` is `true`. Default value is `false`.
    public var isEnabled: Bool = false
    /// Used in calculation for content offset to define threshold for which gyro updates are tracked.
    public var threshold: CGFloat = 0.1
    /// Used in calculation for content offset to define sensitivity of gyro movement.
    public var sensitivity: CGFloat = 1.0
    /// Designated initializer.
    public init() {}
}
