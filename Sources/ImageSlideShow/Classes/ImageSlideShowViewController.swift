//
//  ImageSlideShowViewController.swift
//
//  Created by Dimitri Giani on 02/11/15.
//  Copyright © 2015 Dimitri Giani. All rights reserved.
//

import UIKit

@objc protocol ImageSlideShowProtocol
{
	func slideIdentifier() -> String
	func image(completion: (image:UIImage?, error:NSError?) -> Void)
}

protocol ImageSlideShowViewControllerDelegate
{
	func imageSlideShowViewControllerDidDismiss(controller:ImageSlideShowViewController)
}

class ImageSlideShowViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
	static var imageSlideShowStoryboard:UIStoryboard = UIStoryboard(name: "ImageSlideShow", bundle: nil)
	
	var imageSlideShowDelegate:ImageSlideShowViewControllerDelegate?
	var slides:[ImageSlideShowProtocol]?
	var initialIndex = 0
	var pageSpacing:CGFloat = 10.0
	var panDismissTolerance:CGFloat = 100.0
	var dismissOnPanGesture = false
	
	internal var pageViewControllerCenter = CGPointZero
	internal var navigationBarHidden = false
	internal var toggleBarButtonItem:UIBarButtonItem?
	internal var currentIndex = 0
	internal let slidesViewControllerCache = NSCache()
	
	//	MARK: - Class methods
	
	class func imageSlideShowNavigationController() -> UINavigationController
	{
		let controller = ImageSlideShowViewController.imageSlideShowStoryboard.instantiateViewControllerWithIdentifier("ImageSlideShowNavigationController") as! UINavigationController
		controller.modalPresentationStyle = .OverCurrentContext
		
		return controller
	}
	
	class func imageSlideShowViewController() -> ImageSlideShowViewController
	{
		let controller = ImageSlideShowViewController.imageSlideShowStoryboard.instantiateViewControllerWithIdentifier("ImageSlideShowViewController") as! ImageSlideShowViewController
		controller.modalPresentationStyle = .OverCurrentContext
		
		return controller
	}
	
	//	MARK: - Instance methods
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.delegate = self
		self.dataSource = self
		
		self.hidesBottomBarWhenPushed = true
		
		self.navigationController?.view.backgroundColor = .blackColor()
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismiss(_:)))
		
		//	Manage Gestures
		
		var gestures = self.gestureRecognizers
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
		gestures.append(tapGesture)
		
		if (self.dismissOnPanGesture)
		{
			let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
			gestures.append(panGesture)
			
			//	If dismiss on pan lock horizontal direction and disable vertical pan to avoid strange behaviours
			
			self.scrollView()?.directionalLockEnabled = true
			self.scrollView()?.alwaysBounceVertical = false
		}
		
		self.view.gestureRecognizers = gestures
	}
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.setPageWithIndex(self.initialIndex)
	}
	
	override func prefersStatusBarHidden() -> Bool
	{
		return true
	}
	
	override func shouldAutorotate() -> Bool
	{
		return true
	}
	
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
	{
		return .All
	}
	
	//	MARK: Actions
	
	func dismiss(sender:AnyObject?)
	{
		self.dismissViewControllerAnimated(true, completion: nil)
		
		self.imageSlideShowDelegate?.imageSlideShowViewControllerDidDismiss(self)
	}
	
	func goToPageIndex(index:Int)
	{
		if index != self.currentIndex
		{
			self.setPageWithIndex(index)
		}
	}
	
	func goToNextPage()
	{
		let index = self.currentIndex + 1
		if index < self.slides?.count
		{
			self.setPageWithIndex(index)
		}
	}
	
	func goToPreviousPage()
	{
		let index = self.currentIndex - 1
		if index >= 0
		{
			self.setPageWithIndex(index)
		}
	}
	
	func setPageWithIndex(index:Int)
	{
		if	let viewController = slideViewControllerForPage(index)
		{
			self.setViewControllers([viewController], direction: (index > self.currentIndex ? .Forward : .Reverse), animated: true, completion: nil)
			
			self.currentIndex = index
		}
	}
	
	// MARK: UIPageViewControllerDataSource
	
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
	{
		if completed
		{
			self.currentIndex = indexOfSlideForViewController((pageViewController.viewControllers?.last)!)
		}
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
	{
		let index = indexOfSlideForViewController(viewController)
		
		if index > 0
		{
			return slideViewControllerForPage(index - 1)
		}
		else
		{
			return nil
		}
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
	{
		let index = indexOfSlideForViewController(viewController)
		
		if let slides = self.slides where index < slides.count - 1
		{
			return slideViewControllerForPage(index + 1)
		}
		else
		{
			return nil
		}
	}
	
	// MARK: Accessories
	
	private func indexOfProtocolObjectInSlideViewController(controller: ImageSlideViewController) -> Int?
	{
		var index = 0
		
		if	let object = controller.slide,
			let slides = self.slides
		{
			for slide in slides
			{
				if slide.slideIdentifier() == object.slideIdentifier()
				{
					return index
				}
				
				index += 1
			}
		}
		
		return nil
	}
	
	private func indexOfSlideForViewController(viewController: UIViewController) -> Int
	{
		guard let viewController = viewController as? ImageSlideViewController else { fatalError("Unexpected view controller type in page view controller.") }
		guard let viewControllerIndex = self.indexOfProtocolObjectInSlideViewController(viewController) else { fatalError("View controller's data item not found.") }
		
		return viewControllerIndex
	}
	
	private func slideViewControllerForPage(pageIndex: Int) -> ImageSlideViewController?
	{
		if let slides = self.slides where slides.count > 0
		{
			let slide = slides[pageIndex]
			
			if let cachedController = slidesViewControllerCache.objectForKey(slide.slideIdentifier()) as? ImageSlideViewController
			{
				return cachedController
			}
			else
			{
				guard let controller = storyboard?.instantiateViewControllerWithIdentifier("ImageSlideViewController") as? ImageSlideViewController else { fatalError("Unable to instantiate a ImageSlideViewController.") }
				controller.slide = slide
				
				slidesViewControllerCache.setObject(controller, forKey: slide.slideIdentifier())
				
				return controller
			}
		}
		
		return nil
	}
	
	// MARK: Gestures
	
	@objc private func tapGesture(gesture:UITapGestureRecognizer)
	{
		self.navigationBarHidden = !self.navigationBarHidden;
		
		UIView.animateWithDuration(0.23,
			delay: 0.0,
			options: .BeginFromCurrentState,
			animations: { () -> Void in
				
				self.navigationController?.navigationBar.alpha = (self.navigationBarHidden ? 0.0 : 1.0)
				
			}, completion: nil)
	}
	
	@objc private func panGesture(gesture:UIPanGestureRecognizer)
	{
		switch gesture.state
		{
		case .Began:
			self.pageViewControllerCenter = self.view.center
			
		case .Changed:
			let translation = gesture.translationInView(self.view)
			var origin = self.view.frame.origin
			origin = CGPointMake(self.view.frame.origin.x + translation.x, self.view.frame.origin.y + translation.y)
			self.view.frame = CGRect(origin: origin, size: self.view.frame.size)
			
			gesture.setTranslation(CGPointZero, inView: self.view)
			
			
			let distanceX = fabs(self.pageViewControllerCenter.x - self.view.center.x)
			let distanceY = fabs(self.pageViewControllerCenter.y - self.view.center.y)
			let distance = max(distanceX, distanceY)
			let center = max(self.pageViewControllerCenter.x, self.pageViewControllerCenter.y)
			
			let alpha = CGFloat(1.0 - (distance / center))
			
			self.navigationController?.navigationBar.alpha = 0.0
			self.navigationController?.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(alpha)
			
		case .Ended, .Cancelled, .Failed:
			let distanceX = fabs(self.pageViewControllerCenter.x - self.view.center.x)
			let distanceY = fabs(self.pageViewControllerCenter.y - self.view.center.y)
			
			if (distanceY >= self.panDismissTolerance || distanceX >= self.panDismissTolerance)
			{
				UIView.animateWithDuration(0.1,
					delay: 0.0,
					options: .BeginFromCurrentState,
					animations: { () -> Void in
						
						self.navigationController?.view.alpha = 0.0
						
					}, completion: { (completed:Bool) -> Void in
						
						self.dismiss(nil)
						
					})
			}
			else
			{
				UIView.animateWithDuration(0.2,
					delay: 0.0,
					options: .BeginFromCurrentState,
					animations: { () -> Void in
						
						self.navigationBarHidden = true
						self.navigationController?.navigationBar.alpha = 0.0
						self.navigationController?.view.backgroundColor = UIColor.blackColor()
						self.view.center = self.pageViewControllerCenter;
						
				}, completion: nil)
			}
			
		default:
			break;
		}
	}
}
