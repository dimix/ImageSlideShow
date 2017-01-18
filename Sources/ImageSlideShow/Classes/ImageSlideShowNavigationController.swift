//
//  ImageSlideShowNavigationController.swift
//
//  Created by Dimitri Giani on 27/10/2016.
//  Copyright © 2016 Dimitri Giani. All rights reserved.
//

import UIKit

open class ImageSlideShowNavigationController: UINavigationController
{
	override open var childViewControllerForStatusBarStyle: UIViewController?
	{
		return topViewController
	}
	
	override open var prefersStatusBarHidden:Bool
	{
		if let prefersStatusBarHidden = viewControllers.last?.prefersStatusBarHidden
		{
			return prefersStatusBarHidden
		}
		
		return false
	}
}
