//
//  ViewController.swift
//  Demo
//
//  Created by Dimitri Giani on 16/10/2016.
//  Copyright © 2016 Dimitri Giani. All rights reserved.
//

import UIKit

//	Very bad Class, but just for Demo ;-)

class Image:NSObject, ImageSlideShowProtocol
{
	private let url:NSURL
	
	init(url:NSURL) {
		self.url = url
	}
	
	func slideIdentifier() -> String {
		return self.url.absoluteString!
	}
	
	func image(completion: (image: UIImage?, error: NSError?) -> Void) {
		
		let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
		session.dataTaskWithURL(self.url) { (data:NSData?, response:NSURLResponse?, error:NSError?) in
			
			if let data = data where error == nil
			{
				let image = UIImage(data: data)
				completion(image: image, error: nil)
			}
			else
			{
				completion(image: nil, error: error)
			}
			
		}.resume()
		
	}
}

class ViewController: UIViewController {

	private var images:[Image] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.generateImages()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func generateImages()
	{
		let scale:Int = Int(UIScreen.mainScreen().scale)
		let height:Int = Int(self.view.frame.size.height) * scale
		let width:Int = Int(self.view.frame.size.width) * scale
		
		images = [
			Image(url: NSURL(string: "https://dummyimage.com/\(width)x\(height)/09a/fff.png&text=Image+1")!),
			Image(url: NSURL(string: "https://dummyimage.com/\(600)x\(600)/09b/fff.png&text=Image+2")!),
			Image(url: NSURL(string: "https://dummyimage.com/\(width)x\(height)/09c/fff.png&text=Image+3")!),
			Image(url: NSURL(string: "https://dummyimage.com/\(600)x\(600)/09d/fff.png&text=Image+4")!),
			Image(url: NSURL(string: "https://dummyimage.com/\(width)x\(height)/09e/fff.png&text=Image+5")!),
			Image(url: NSURL(string: "https://dummyimage.com/\(width)x\(height)/09f/fff.png&text=Image+6")!),
		]
	}
	
	@IBAction func presentSlideShow(withSender sender:AnyObject?)
	{
		ImageSlideShowViewController.presentFrom(self){ [weak self] controller in
			
			controller.dismissOnPanGesture = true
			controller.slides = self?.images
			controller.enableZoom = true
			controller.controllerDidDismiss = {
				print("Controller Dismissed")
			}
			
		}
		
		/*
		let navController = ImageSlideShowViewController.imageSlideShowNavigationController()
		if let controller = navController.visibleViewController as? ImageSlideShowViewController
		{
			controller.dismissOnPanGesture = true
			controller.slides = self.images
			controller.enableZoom = true
			controller.controllerDidDismiss = {
				print("Controller Dismissed")
			}
			
			self.presentViewController(navController, animated: true, completion: nil)
		}
		*/
	}
}

