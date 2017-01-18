//
//  ImageSlideViewController.swift
//
//  Created by Dimitri Giani on 02/11/15.
//  Copyright © 2015 Dimitri Giani. All rights reserved.
//

import UIKit

open  class ImageSlideViewController: UIViewController, UIScrollViewDelegate
{
	@IBOutlet weak var scrollView:UIScrollView?
	@IBOutlet weak var imageView:UIImageView?
	@IBOutlet weak var loadingIndicatorView:UIActivityIndicatorView?
	
	var slide:ImageSlideShowProtocol?
	var enableZoom = false
	
	var willBeginZoom:() -> Void = {}
	
	override open func viewDidLoad()
	{
		super.viewDidLoad()
		
		if enableZoom
		{
			scrollView?.maximumZoomScale = 2.0
			scrollView?.minimumZoomScale = 1.0
			scrollView?.zoomScale = 1.0
		}
		
		scrollView?.isHidden = true
		loadingIndicatorView?.startAnimating()
		
		slide?.image(completion: { (image, error) -> Void in
			
			DispatchQueue.main.async {
			
				self.imageView?.image = image
				self.loadingIndicatorView?.stopAnimating()
				self.scrollView?.isHidden = false
				
			}
			
		})
    }
	
	override open func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
		
		if enableZoom
		{
			//	Reset zoom scale when the controller is hidden
		
			scrollView?.zoomScale = 1.0
		}
	}
	
	//	MARK: UIScrollViewDelegate
	
	open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?)
	{
		willBeginZoom()
	}
	
	open func viewForZooming(in scrollView: UIScrollView) -> UIView?
	{
		if enableZoom
		{
			return imageView
		}
		
		return nil
	}
}
