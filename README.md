# AEImage

**Adaptive image viewer for iOS (with support for zoom, gyro motion and infinite scroll)**

[![Language Swift 4.0](https://img.shields.io/badge/Language-Swift%204.0-orange.svg?style=flat)](https://swift.org)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](LICENSE)

[![CocoaPods Version](https://img.shields.io/cocoapods/v/AEImage.svg?style=flat)](https://cocoapods.org/pods/AEImage)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

> Super awesome lightweight and easy to use image viewer with all the standard options + some more. It may be used from code or storyboard and as it frame changes, it will always rescale image appropriately based on its settings.  

> It has standard zoom support, but also integrated gyro motion tracking and image scrolling based on device movement. Last but not least, it has "infinite scroll" effect in both horizontal and vertical direction which may be useful for 360 panorama images or whatever you may think of.

![AEImage](http://tadija.net/public/AEImage.gif)

## Index
- [Features](#features)
- [Usage](#usage)
- [Installation](#installation)
- [License](#license)

## Features
- Adaptive image viewer with multiple display modes
- Gyro motion based scrolling *(optional)*
- Infinite scroll effect - horizontal and vertical *(optional)*

## Usage

- Use `ImageScrollView` directly as any `UIImageView` but with all additional options, or:

- Subclass `ImageViewController ` and configure its `imageScrollView` and `motionSettings` as you need.

```swift
import AEImage

class ReadmeViewController: ImageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.displayMode = .fillHeight
        imageScrollView.infiniteScroll = .horizontal
        
        motionSettings.isEnabled = true
        motionSettings.sensitivity = 1.5
        
        image = UIImage(named: "demo")
    }
    
}
```

> For more details check out [Sources](Sources) and [Example](Example).

## Installation

- [Swift Package Manager](https://swift.org/package-manager/):

```
.Package(url: "https://github.com/tadija/AEImage.git", from: "2.2.0")
```

- [Carthage](https://github.com/Carthage/Carthage):

```ogdl
github "tadija/AEImage"
```

- [CocoaPods](http://cocoapods.org/):

```ruby
pod 'AEImage'
```

## License
This code is released under the MIT license. See [LICENSE](LICENSE) for details.
