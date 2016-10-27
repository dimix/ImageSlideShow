# ImageSlideShow
A Swift Image SlideShow for iOS

ImageSlideShow is a simple Slideshow for images (Picture, Photos) for your apps.

![alt tag](https://github.com/dimix/ImageSlideShow/blob/master/demo.gif)

## Features
- All in one slideshow with generic protocol to provide images directly from the model
- Pan-gesture-to-dismiss behaviour (like Facebook)

## How to Use

#### 1. Import ImageSlideShow folder in your project
#### 2. Instantiate the controller

```swift
let navController = ImageSlideShowViewController.imageSlideShowNavigationController()
if let controller = navController.visibleViewController as? ImageSlideShowViewController
{
	controller.dismissOnPanGesture = true
	controller.slides = self.images
	controller.enableZoom = true
	
	self.presentViewController(navController, animated: true, completion: nil)
}
```

You need to provide an array of `[ImageSlideShowProtocol]` objects.
You can use the Demo project to watch details.

## To Do

- Create module
- Add CocoaPods and Carthage support
- Create a Swift 3 version
- Improve Instance creation
- Improve ImageSlidehowProtocol
