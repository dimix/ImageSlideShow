//
//  ImageSlideShowViewController.swift
//
//  Created by Dimitri Giani on 02/11/15.
//  Copyright © 2015 Dimitri Giani. All rights reserved.
//

import UIKit

@objc public protocol ImageSlideShowProtocol
{
	func slideIdentifier() -> String
	func image(completion: @escaping (_ image:UIImage?, _ error:Error?) -> Void)
}

class ImageSlideShowCache: NSCache<AnyObject, AnyObject>
{
	override init()
	{
		super.init()
		
		NotificationCenter.default.addObserver(self, selector:#selector(NSMutableArray.removeAllObjects), name: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
	}
	
	deinit
	{
		NotificationCenter.default.removeObserver(self);
	}
}

open class ImageSlideShowViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
	static var imageSlideShowStoryboard:UIStoryboard = UIStoryboard(name: "ImageSlideShow", bundle: Bundle(for: ImageSlideShowViewController.self))
	
	open var slides:[ImageSlideShowProtocol]?
	open var initialIndex:Int = 0
	open var pageSpacing:CGFloat = 10.0
	open var panDismissTolerance:CGFloat = 30.0
	open var dismissOnPanGesture:Bool = false
	open var enableZoom:Bool = false
	open var statusBarStyle:UIStatusBarStyle = .lightContent
	open var navigationBarTintColor:UIColor = .white
	
	open var controllerDidDismiss:() -> Void = {}
	open var stepAnimate:((_ offset:CGFloat, _ viewController:UIViewController) -> Void) = { _,_ in }
	open var restoreAnimation:((_ viewController:UIViewController) -> Void) = { _ in }
	open var dismissAnimation:((_ viewController:UIViewController, _ panDirection:CGPoint, _ completion: @escaping ()->()) -> Void) = { _,_,_ in }
    
    //Give the user the ability to customize UIViewController lifecycle methods
    open var customViewDidLoad: (() -> ())? = nil
    open var customViewWillAppear: ((Bool) -> ())? = nil
	
	fileprivate var originPanViewCenter:CGPoint = .zero
	fileprivate var panViewCenter:CGPoint = .zero
	fileprivate var navigationBarHidden = false
	fileprivate var toggleBarButtonItem:UIBarButtonItem?
	fileprivate var currentIndex = 0
	fileprivate let slidesViewControllerCache = ImageSlideShowCache()
	
	override open var preferredStatusBarStyle:UIStatusBarStyle
	{
		return statusBarStyle
	}
	
	override open var prefersStatusBarHidden:Bool
	{
		return navigationBarHidden
	}
	
	override open var shouldAutorotate:Bool
	{
		return true
	}
	
	override open var supportedInterfaceOrientations:UIInterfaceOrientationMask
	{
		return .all
	}
	
	//	MARK: - Class methods
	
	class func imageSlideShowNavigationController() -> ImageSlideShowNavigationController
	{
		let controller = ImageSlideShowViewController.imageSlideShowStoryboard.instantiateViewController(withIdentifier: "ImageSlideShowNavigationController") as! ImageSlideShowNavigationController
		controller.modalPresentationStyle = .overCurrentContext
		controller.modalPresentationCapturesStatusBarAppearance = true
		
		return controller
	}
	
	class func imageSlideShowViewController() -> ImageSlideShowViewController
	{
		let controller = ImageSlideShowViewController.imageSlideShowStoryboard.instantiateViewController(withIdentifier: "ImageSlideShowViewController") as! ImageSlideShowViewController
		controller.modalPresentationStyle = .overCurrentContext
		controller.modalPresentationCapturesStatusBarAppearance = true
		
		return controller
	}
	
	class open func presentFrom(_ viewController:UIViewController, configure:((_ controller: ImageSlideShowViewController) -> ())?)
	{
		let navController = self.imageSlideShowNavigationController()
		if let issViewController = navController.visibleViewController as? ImageSlideShowViewController
		{
			configure?(issViewController)
			
			viewController.present(navController, animated: true, completion: nil)
		}
	}
	
	required public init?(coder: NSCoder)
	{
		super.init(coder: coder)
		
		prepareAnimations()
	}
	
	//	MARK: - Instance methods
	
	override open func viewDidLoad()
	{
		super.viewDidLoad()
		
		delegate = self
		dataSource = self
		
		hidesBottomBarWhenPushed = true
		
		navigationController?.navigationBar.tintColor = navigationBarTintColor
		navigationController?.view.backgroundColor = .black
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss(sender:)))
		
		//	Manage Gestures
		
		var gestures = gestureRecognizers
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
		gestures.append(tapGesture)
		
		if (dismissOnPanGesture)
		{
			let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
			gestures.append(panGesture)
			
			//	If dismiss on pan lock horizontal direction and disable vertical pan to avoid strange behaviours
			
			scrollView()?.isDirectionalLockEnabled = true
			scrollView()?.alwaysBounceVertical = false
		}
		
		view.gestureRecognizers = gestures
        
        if let customFunction = self.customViewDidLoad {
            customFunction()
        }
	}
	
	override open func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
		setPage(withIndex: initialIndex)
        
        if let customFunction = self.customViewWillAppear{
            customFunction(animated)
        }
	}
	
	//	MARK: Actions
	
	open func dismiss(sender:AnyObject?)
	{
		dismiss(animated: true, completion: nil)
		
		controllerDidDismiss()
	}
	
	open func goToPage(withIndex index:Int)
	{
		if index != currentIndex
		{
			setPage(withIndex: index)
		}
	}
	
	open func goToNextPage()
	{
		let index = currentIndex + 1
		if index < (slides?.count)!
		{
			setPage(withIndex: index)
		}
	}
	
	open func goToPreviousPage()
	{
		let index = currentIndex - 1
		if index >= 0
		{
			setPage(withIndex: index)
		}
	}
	
	func setPage(withIndex index:Int)
	{
		if	let viewController = slideViewController(forPageIndex: index)
		{
			setViewControllers([viewController], direction: (index > currentIndex ? .forward : .reverse), animated: true, completion: nil)
			
			currentIndex = index
		}
	}
	
	func setNavigationBar(visible:Bool)
	{
		navigationBarHidden = !visible
		
		UIView.animate(withDuration: 0.23,
		                           delay: 0.0,
		                           options: .beginFromCurrentState,
		                           animations: { () -> Void in
									
									self.navigationController?.navigationBar.alpha = (visible ? 1.0 : 0.0)
									
			}, completion: nil)
		
		self.setNeedsStatusBarAppearanceUpdate()
	}
    
    func getCurrentSlide() -> ImageSlideShowProtocol? {
        return self.slides?.get(self.currentIndex)
    }
	
	// MARK: UIPageViewControllerDataSource
	
	public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
	{
		self.setNavigationBar(visible: false)
	}
	
	public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
	{
		if completed
		{
			currentIndex = indexOfSlideForViewController(viewController: (pageViewController.viewControllers?.last)!)
		}
	}
	
	public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
	{
		let index = indexOfSlideForViewController(viewController: viewController)
		
		if index > 0
		{
			return slideViewController(forPageIndex: index - 1)
		}
		else
		{
			return nil
		}
	}
	
	public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
	{
		let index = indexOfSlideForViewController(viewController: viewController)
		
		if let slides = slides, index < slides.count - 1
		{
			return slideViewController(forPageIndex: index + 1)
		}
		else
		{
			return nil
		}
	}
	
	// MARK: Accessories
	
	fileprivate func indexOfProtocolObject(inSlideViewController controller: ImageSlideViewController) -> Int?
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
	
	fileprivate func indexOfSlideForViewController(viewController: UIViewController) -> Int
	{
		guard let viewController = viewController as? ImageSlideViewController else { fatalError("Unexpected view controller type in page view controller.") }
		guard let viewControllerIndex = indexOfProtocolObject(inSlideViewController: viewController) else { fatalError("View controller's data item not found.") }
		
		return viewControllerIndex
	}
	
	fileprivate func slideViewController(forPageIndex pageIndex: Int) -> ImageSlideViewController?
	{
		if let slides = slides, slides.count > 0
		{
			let slide = slides[pageIndex]
			
			if let cachedController = slidesViewControllerCache.object(forKey: slide.slideIdentifier() as AnyObject) as? ImageSlideViewController
			{
				return cachedController
			}
			else
			{
				guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImageSlideViewController") as? ImageSlideViewController else { fatalError("Unable to instantiate a ImageSlideViewController.") }
				controller.slide = slide
				controller.enableZoom = enableZoom
				controller.willBeginZoom = {
					self.setNavigationBar(visible: false)
				}
				
				slidesViewControllerCache.setObject(controller, forKey: slide.slideIdentifier() as AnyObject)
				
				return controller
			}
		}
		
		return nil
	}
	
	fileprivate func prepareAnimations()
	{
		stepAnimate = { step, viewController in
			
			if let viewController = viewController as? ImageSlideViewController
			{
				if step == 0
				{
					viewController.imageView?.layer.shadowRadius = 10
					viewController.imageView?.layer.shadowOpacity = 0.3
				}
				else
				{
					let alpha = CGFloat(1.0 - step)
					
					self.navigationController?.navigationBar.alpha = 0.0
					self.navigationController?.view.backgroundColor = UIColor.black.withAlphaComponent(max(0.2, alpha * 0.9))
					
					let scale = max(0.8, alpha)
					
					viewController.imageView?.center = self.panViewCenter
					viewController.imageView?.transform = CGAffineTransform(scaleX: scale, y: scale)
				}
			}
		}
		restoreAnimation = { viewController in
			
			if let viewController = viewController as? ImageSlideViewController
			{
				UIView.animate(withDuration: 0.2,
				                           delay: 0.0,
				                           options: .beginFromCurrentState,
				                           animations: { () -> Void in
											
											self.presentingViewController?.view.transform = CGAffineTransform.identity
											
											viewController.imageView?.center = self.originPanViewCenter
											viewController.imageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
											viewController.imageView?.layer.shadowRadius = 0
											viewController.imageView?.layer.shadowOpacity = 0
											
					}, completion: nil)
			}
		}
		dismissAnimation = {  viewController, panDirection, completion in
			
			if let viewController = viewController as? ImageSlideViewController
			{
				let velocity = panDirection.y
				
				UIView.animate(withDuration: 0.3,
				                           delay: 0.0,
				                           options: .beginFromCurrentState,
				                           animations: { () -> Void in
											
											self.presentingViewController?.view.transform = CGAffineTransform.identity
											
											if var frame = viewController.imageView?.frame
											{
												frame.origin.y = (velocity > 0 ? self.view.frame.size.height : -frame.size.height)
												viewController.imageView?.frame = frame
											}
											
											viewController.imageView?.alpha = 0.0
											
					}, completion: { (completed:Bool) -> Void in
						
						completion()
						
				})
			}
		}
	}
	
	// MARK: Gestures
	
	@objc fileprivate func tapGesture(gesture:UITapGestureRecognizer)
	{
		setNavigationBar(visible: navigationBarHidden == true);
	}
	
	@objc fileprivate func panGesture(gesture:UIPanGestureRecognizer)
	{
		let viewController = slideViewController(forPageIndex: currentIndex)
		
		switch gesture.state
		{
		case .began:
			presentingViewController?.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			
			originPanViewCenter = view.center
			panViewCenter = view.center
			
			stepAnimate(0, viewController!)
			
		case .changed:
			let translation = gesture.translation(in: view)
			panViewCenter = CGPoint(x: panViewCenter.x + translation.x, y: panViewCenter.y + translation.y)
			
			gesture.setTranslation(.zero, in: view)
			
			let distanceX = fabs(originPanViewCenter.x - panViewCenter.x)
			let distanceY = fabs(originPanViewCenter.y - panViewCenter.y)
			let distance = max(distanceX, distanceY)
			let center = max(originPanViewCenter.x, originPanViewCenter.y)
			
			let distanceNormalized = max(0, min((distance / center), 1.0))
			
			stepAnimate(distanceNormalized, viewController!)
			
		case .ended, .cancelled, .failed:
			let distanceY = fabs(originPanViewCenter.y - panViewCenter.y)
			
			if (distanceY >= panDismissTolerance)
			{
				UIView.animate(withDuration: 0.3,
				                           delay: 0.0,
				                           options: .beginFromCurrentState,
				                           animations: { () -> Void in
											
											self.navigationController?.view.alpha = 0.0
					}, completion:nil)
				
				dismissAnimation(viewController!, gesture.velocity(in: gesture.view), {
					
					self.dismiss(sender: nil)
					
				})
			}
			else
			{
				UIView.animate(withDuration: 0.2,
				                           delay: 0.0,
				                           options: .beginFromCurrentState,
				                           animations: { () -> Void in
											
											self.navigationBarHidden = true
											self.navigationController?.navigationBar.alpha = 0.0
											self.navigationController?.view.backgroundColor = .black
											
					}, completion: nil)
				
				restoreAnimation(viewController!)
			}
			
		default:
			break;
		}
	}
}
