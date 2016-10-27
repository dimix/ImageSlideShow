//
//  ImageSlideViewController.swift
//
//  Created by Dimitri Giani on 02/11/15.
//  Copyright © 2015 Dimitri Giani. All rights reserved.
//

import UIKit

protocol ImageSlideViewControllerDelegate
{
	func imageSlideViewControllerWillBeginZoom(controller:ImageSlideViewController)
}

class ImageSlideViewController: UIViewController, UIScrollViewDelegate
{
	@IBOutlet weak var scrollView:UIScrollView?
	@IBOutlet weak var imageView:UIImageView?
	@IBOutlet weak var loadingIndicatorView:UIActivityIndicatorView?
	
	var slide:ImageSlideShowProtocol?
	var enableZoom = false
	var delegate:ImageSlideViewControllerDelegate?
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		if enableZoom
		{
			scrollView?.maximumZoomScale = 2.0
			scrollView?.minimumZoomScale = 1.0
			scrollView?.zoomScale = 1.0
		}
		
		scrollView?.hidden = true
		loadingIndicatorView?.startAnimating()
		
		slide?.image({ (image, error) -> Void in
			
			dispatch_async(dispatch_get_main_queue(), { 
				
				self.imageView?.image = image
				self.loadingIndicatorView?.stopAnimating()
				self.scrollView?.hidden = false
				
			})
			
		})
    }
	
	override func viewDidDisappear(animated: Bool)
	{
		super.viewDidDisappear(animated)
		
		//	Reset zoom scale when the controller is hidden
		
		scrollView?.zoomScale = 1.0
	}
	
	//	MARK: UIScrollViewDelegate
	
	func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?)
	{
		self.delegate?.imageSlideViewControllerWillBeginZoom(self)
	}
	
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
	{
		if enableZoom
		{
			return imageView
		}
		
		return nil
	}
}
