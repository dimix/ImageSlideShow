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

class ImageSlideShowCache: NSCache
{
	override init()
	{
		super.init()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(NSMutableArray.removeAllObjects), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
	}
	
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self);
	}
}

class ImageSlideShowViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
	static var imageSlideShowStoryboard:UIStoryboard = UIStoryboard(name: "ImageSlideShow", bundle: nil)
	
	var slides:[ImageSlideShowProtocol]?
	var initialIndex:Int = 0
	var pageSpacing:CGFloat = 10.0
	var panDismissTolerance:CGFloat = 30.0
	var dismissOnPanGesture:Bool = false
	var enableZoom:Bool = false
	var statusBarStyle:UIStatusBarStyle = .LightContent
	var navigationBarTintColor:UIColor = .whiteColor()
	
	var controllerDidDismiss:() -> Void = {}
	
	private var originPanViewCenter = CGPointZero
	private var panViewCenter = CGPointZero
	private var navigationBarHidden = false
	private var toggleBarButtonItem:UIBarButtonItem?
	private var currentIndex = 0
	private let slidesViewControllerCache = ImageSlideShowCache()
	
	//	MARK: - Class methods
	
	class func imageSlideShowNavigationController() -> ImageSlideShowNavigationController
	{
		let controller = ImageSlideShowViewController.imageSlideShowStoryboard.instantiateViewControllerWithIdentifier("ImageSlideShowNavigationController") as! ImageSlideShowNavigationController
		controller.modalPresentationStyle = .OverCurrentContext
		controller.modalPresentationCapturesStatusBarAppearance = true
		
		return controller
	}
	
	class func imageSlideShowViewController() -> ImageSlideShowViewController
	{
		let controller = ImageSlideShowViewController.imageSlideShowStoryboard.instantiateViewControllerWithIdentifier("ImageSlideShowViewController") as! ImageSlideShowViewController
		controller.modalPresentationStyle = .OverCurrentContext
		controller.modalPresentationCapturesStatusBarAppearance = true
		
		return controller
	}
	
	class func presentFrom(viewController:UIViewController, configure:((controller: ImageSlideShowViewController) -> ())?)
	{
		let navController = self.imageSlideShowNavigationController()
		if let issViewController = navController.visibleViewController as? ImageSlideShowViewController
		{
			configure?(controller: issViewController)
			
			viewController.presentViewController(navController, animated: true, completion: nil)
		}
	}
	
	//	MARK: - Instance methods
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		delegate = self
		dataSource = self
		
		hidesBottomBarWhenPushed = true
		
		navigationController?.navigationBar.tintColor = navigationBarTintColor
		navigationController?.view.backgroundColor = .blackColor()
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismiss(_:)))
		
		//	Manage Gestures
		
		var gestures = gestureRecognizers
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
		gestures.append(tapGesture)
		
		if (dismissOnPanGesture)
		{
			let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
			gestures.append(panGesture)
			
			//	If dismiss on pan lock horizontal direction and disable vertical pan to avoid strange behaviours
			
			scrollView()?.directionalLockEnabled = true
			scrollView()?.alwaysBounceVertical = false
		}
		
		view.gestureRecognizers = gestures
	}
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		setPageWithIndex(initialIndex)
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle
	{
		return statusBarStyle
	}
	
	override func prefersStatusBarHidden() -> Bool
	{
		return navigationBarHidden
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
		dismissViewControllerAnimated(true, completion: nil)
		
		controllerDidDismiss()
	}
	
	func goToPageIndex(index:Int)
	{
		if index != currentIndex
		{
			setPageWithIndex(index)
		}
	}
	
	func goToNextPage()
	{
		let index = currentIndex + 1
		if index < slides?.count
		{
			setPageWithIndex(index)
		}
	}
	
	func goToPreviousPage()
	{
		let index = currentIndex - 1
		if index >= 0
		{
			setPageWithIndex(index)
		}
	}
	
	func setPageWithIndex(index:Int)
	{
		if	let viewController = slideViewControllerForPage(index)
		{
			setViewControllers([viewController], direction: (index > currentIndex ? .Forward : .Reverse), animated: true, completion: nil)
			
			currentIndex = index
		}
	}
	
	func setNavigationBarVisible(visible:Bool)
	{
		navigationBarHidden = !visible
		
		UIView.animateWithDuration(0.23,
		                           delay: 0.0,
		                           options: .BeginFromCurrentState,
		                           animations: { () -> Void in
									
									self.navigationController?.navigationBar.alpha = (visible ? 1.0 : 0.0)
									
			}, completion: nil)
		
		self.setNeedsStatusBarAppearanceUpdate()
	}
	
	// MARK: UIPageViewControllerDataSource
	
	func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController])
	{
		self.setNavigationBarVisible(false)
	}
	
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
	{
		if completed
		{
			currentIndex = indexOfSlideForViewController((pageViewController.viewControllers?.last)!)
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
		
		if let slides = slides where index < slides.count - 1
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
			let slides = slides
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
		guard let viewControllerIndex = indexOfProtocolObjectInSlideViewController(viewController) else { fatalError("View controller's data item not found.") }
		
		return viewControllerIndex
	}
	
	private func slideViewControllerForPage(pageIndex: Int) -> ImageSlideViewController?
	{
		if let slides = slides where slides.count > 0
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
				controller.enableZoom = enableZoom
				controller.willBeginZoom = {
					self.setNavigationBarVisible(false)
				}
				
				slidesViewControllerCache.setObject(controller, forKey: slide.slideIdentifier())
				
				return controller
			}
		}
		
		return nil
	}
	
	// MARK: Gestures
	
	@objc private func tapGesture(gesture:UITapGestureRecognizer)
	{
		setNavigationBarVisible(navigationBarHidden == true);
	}
	
	@objc private func panGesture(gesture:UIPanGestureRecognizer)
	{
		let viewController = slideViewControllerForPage(currentIndex)
		
		switch gesture.state
		{
		case .Began:
			presentingViewController?.view.transform = CGAffineTransformMakeScale(0.95, 0.95)
			
			originPanViewCenter = view.center
			panViewCenter = view.center
			viewController?.imageView?.layer.shadowRadius = 10
			viewController?.imageView?.layer.shadowOpacity = 0.3
			
		case .Changed:
			let translation = gesture.translationInView(view)
			panViewCenter = CGPointMake(panViewCenter.x + translation.x, panViewCenter.y + translation.y)
			
			gesture.setTranslation(CGPointZero, inView: view)
			
			let distanceX = fabs(originPanViewCenter.x - panViewCenter.x)
			let distanceY = fabs(originPanViewCenter.y - panViewCenter.y)
			let distance = max(distanceX, distanceY)
			let center = max(originPanViewCenter.x, originPanViewCenter.y)
			
			let distanceNormalized = max(0, min((distance / center), 1.0))
			let alpha = CGFloat(1.0 - distanceNormalized)
			
			navigationController?.navigationBar.alpha = 0.0
			navigationController?.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(max(0.2, alpha * 0.9))
			
			let scale = max(0.8, alpha)
			
			viewController?.imageView?.center = panViewCenter
			viewController?.imageView?.transform = CGAffineTransformMakeScale(scale, scale)
			
		case .Ended, .Cancelled, .Failed:
			let distanceY = fabs(originPanViewCenter.y - panViewCenter.y)
			
			if (distanceY >= panDismissTolerance)
			{
				let velocity = gesture.velocityInView(gesture.view).y
				
				UIView.animateWithDuration(0.3,
					delay: 0.0,
					options: .BeginFromCurrentState,
					animations: { () -> Void in
						
						self.navigationController?.view.alpha = 0.0
						self.presentingViewController?.view.transform = CGAffineTransformIdentity
						
						if var frame = viewController?.imageView?.frame
						{
							frame.origin.y = (velocity > 0 ? self.view.frame.size.height : -frame.size.height)
							viewController?.imageView?.frame = frame
						}
						
						viewController?.imageView?.alpha = 0.0
						
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
						self.navigationController?.view.backgroundColor = .blackColor()
						self.presentingViewController?.view.transform = CGAffineTransformIdentity
						
						viewController?.imageView?.center = self.originPanViewCenter
						viewController?.imageView?.transform = CGAffineTransformMakeScale(1.0, 1.0)
						viewController?.imageView?.layer.shadowRadius = 0
						viewController?.imageView?.layer.shadowOpacity = 0
						
				}, completion: nil)
			}
			
		default:
			break;
		}
	}
}
