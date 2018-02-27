//
//  ImageSlideViewController.swift
//
//  Created by Dimitri Giani on 02/11/15.
//  Copyright © 2015 Dimitri Giani. All rights reserved.
//

import UIKit

class ImageSlideViewController: UIViewController, UIScrollViewDelegate
{
	@IBOutlet weak var scrollView:UIScrollView?
	@IBOutlet weak var imageView:UIImageView?
	@IBOutlet weak var loadingIndicatorView:UIActivityIndicatorView?
    @IBOutlet weak var imageDescription: UILabel?
	
	var slide:ImageSlideShowProtocol?
	var enableZoom = false
	
	var willBeginZoom:() -> Void = {}
	
	override func viewDidLoad()
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
		
		slide?.image(completion: { (image,imageDescription,error) -> Void in
			
			DispatchQueue.main.async {
			
				self.imageView?.image = image
                self.imageDescription?.text = imageDescription
				self.loadingIndicatorView?.stopAnimating()
				self.scrollView?.isHidden = false
				
			}
			
		})
    }
	
	override func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
		
		if enableZoom
		{
			//	Reset zoom scale when the controller is hidden
		
			scrollView?.zoomScale = 1.0
		}
	}
	
	//	MARK: UIScrollViewDelegate
	
	func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?)
	{
		willBeginZoom()
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView?
	{
		if enableZoom
		{
			return imageView
		}
		
		return nil
	}
}
