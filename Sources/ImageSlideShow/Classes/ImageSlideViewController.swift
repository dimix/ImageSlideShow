//
//  ImageSlideViewController.swift
//
//  Created by Dimitri Giani on 02/11/15.
//  Copyright © 2015 Dimitri Giani. All rights reserved.
//

import UIKit

class ImageSlideViewController: UIViewController
{
	@IBOutlet weak var imageView:UIImageView?
	@IBOutlet weak var loadingIndicatorView:UIActivityIndicatorView?
	
	var slide:ImageSlideShowProtocol?
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.loadingIndicatorView?.startAnimating()
		
		self.slide?.image({ (image, error) -> Void in
			
			dispatch_async(dispatch_get_main_queue(), { 
				
				self.imageView?.image = image
				self.loadingIndicatorView?.stopAnimating()
				
			})
			
		})
    }
}
