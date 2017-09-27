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
	fileprivate let url:URL
	
	init(url:URL) {
		self.url = url
	}
	
	func slideIdentifier() -> String {
		return String(describing: url)
	}
	
	func image(completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
		
		let session = URLSession(configuration: URLSessionConfiguration.default)
		session.dataTask(with: self.url) { data, response, error in
			
			if let data = data, error == nil
			{
				let image = UIImage(data: data)
				completion(image, nil)
			}
			else
			{
				completion(nil, error)
			}
			
		}.resume()
		
	}
}

class ViewController: UIViewController {

	fileprivate var images:[Image] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.generateImages()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	fileprivate func generateImages()
	{
		let scale:Int = Int(UIScreen.main.scale)
		let height:Int = Int(view.frame.size.height) * scale
		let width:Int = Int(view.frame.size.width) * scale
		
		images = [
			Image(url: URL(string: "https://dummyimage.com/\(width)x\(height)/09a/fff.png&text=Image+1")!),
			Image(url: URL(string: "https://dummyimage.com/\(600)x\(600)/09b/fff.png&text=Image+2")!),
			Image(url: URL(string: "https://dummyimage.com/\(width)x\(height)/09c/fff.png&text=Image+3")!),
			Image(url: URL(string: "https://dummyimage.com/\(600)x\(600)/09d/fff.png&text=Image+4")!),
			Image(url: URL(string: "https://dummyimage.com/\(width)x\(height)/09e/fff.png&text=Image+5")!),
			Image(url: URL(string: "https://dummyimage.com/\(width)x\(height)/09f/fff.png&text=Image+6")!),
		]
	}
	
	@IBAction func presentSlideShow(_ sender:AnyObject?)
	{
		ImageSlideShowViewController.presentFrom(self){ [weak self] controller in
			
			controller.dismissOnPanGesture = true
			controller.slides = self?.images
			controller.enableZoom = true
			controller.controllerDidDismiss = {
				debugPrint("Controller Dismissed")
				
				debugPrint("last index viewed: \(controller.currentIndex)")
			}
			
		}
	}
}

