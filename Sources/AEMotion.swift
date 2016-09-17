//
// AEMotion.swift
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

import CoreMotion

public protocol AEMotionDelegate: class {
    func didUpdate(gyroData: CMGyroData)
}

open class AEMotion: CMMotionManager {
    
    // MARK: - Properties
    
    open weak var delegate: AEMotionDelegate?
    
    open var isEnabled = false {
        didSet {
            if isEnabled != oldValue {
                isEnabled ? startTrackingMotion() : stopTrackingMotion()
            }
        }
    }
    
    // MARK: - API
    
    open func toggle() {
        isEnabled = !isEnabled
    }
    
    // MARK: - Helpers
    
    private func startTrackingMotion() {
        guard
            let queue = OperationQueue.current,
            isGyroAvailable,
            isGyroActive == false
        else { return }
        
        startGyroUpdates(to: queue, withHandler: { (gyroData, NSError) in
            guard let data = gyroData else { return }
            self.delegate?.didUpdate(gyroData: data)
        })
    }
    
    private func stopTrackingMotion() {
        stopGyroUpdates()
    }
    
}
