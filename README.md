![License](https://img.shields.io/cocoapods/l/ImageSlideShowSwift.svg?style=flat)
![Platform](https://img.shields.io/badge/platform-ios-lightgray.svg?style=flat)
![Version](https://img.shields.io/cocoapods/v/ImageSlideShowSwift.svg?style=flat)
![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)

# Swift ImageSlideShow for iOS
ImageSlideShow is a simple Slideshow for images (Picture, Photos) for your iOS apps written in Swift 3.
You can use this class on iPhone and iPad as well.

![alt tag](https://raw.githubusercontent.com/dimix/ImageSlideShow/e6e9a62db2b4c82b58d5b298ef6802c0a8125970/demo.gif)

## Features
- All in one slideshow with generic protocol to provide images directly from the model
- Pan-gesture-to-dismiss behaviour (like Facebook)

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like ImageSlideShow in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.0.1+ is required to build ImageSlideShow (along with Swift 3 and Xcode 8).

#### Podfile

To integrate ImageSlideShow into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'TargetName' do
  use_frameworks!
  pod 'ImageSlideShowSwift'
end
```

Then, run the following command:

```bash
$ pod install
```

## Installation with Carthage
Currently only iOS is supported.

1. Add the following to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

    ```
    github "dimix/ImageSlideShow"
    ```

2. Run `carthage update --platform ios`

3. Copy the framework into your project and you are good to go.

## How to Use

#### 1. Import ImageSlideShowSwift module
#### 2. Instantiate the controller

```swift
ImageSlideShowViewController.presentFrom(self){ [weak self] controller in
			
	controller.dismissOnPanGesture = true
	controller.slides = self?.images
	controller.enableZoom = true
	controller.controllerDidDismiss = {
		print("Controller Dismissed")
	}
			
}
```

You need to provide an array of `[ImageSlideShowProtocol]` objects.
You can use the Demo project to watch details.

## Requirements

Current version is compatible with:

* Swift 3.0+
* iOS 9 or later

Are you searching for an old (unsupported) version? Check out:

* [Swift 2.3](https://github.com/dimix/ImageSlideShow/tree/feature/swift2.3)

## To Do

* Add Carthage support
* Create module
